#!/bin/python2

# See http://freshfoo.com/blog/pulseaudio_monitoring for information on how
# this module works.

import sys
from Queue import Queue
from ctypes import POINTER, c_ubyte, c_void_p, c_ulong, cast

# From https://github.com/Valodim/python-pulseaudio
from lib_pulseaudio import *

class PeakMonitor(object):

    def __init__(self, stream_type, stream_name, stream_index=-1, rate=30):
        self.stream_type = stream_type
        self.stream_name = stream_name
        self.stream_index = stream_index
        self.rate = rate

        if stream_type == 'sink':
            self.fn_pa_stream_info_cb_t = pa_sink_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_sink_info_list
        elif stream_type == 'source':
            self.fn_pa_stream_info_cb_t = pa_source_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_source_info_list

        # sinkinput and sourceoutput are bacically the same as sink/source but we pass a stream_index.
        # TODO: Test if protocol version is >= 13
        # https://github.com/pulseaudio/pavucontrol/blob/574139c10e70b63874bcb75fe4cdfd1f4644ad68/src/mainwindow.cc#L750
        # if (pa_context_get_server_protocol_version(get_context()) >= 13)
        elif stream_type == 'sinkinput':
            self.fn_pa_stream_info_cb_t = pa_sink_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_sink_info_list
        elif stream_type == 'sourceoutput':
            self.fn_pa_stream_info_cb_t = pa_source_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_source_info_list
        else:
            raise Exception("%0 stream_type must be [sink, source]" % stream_type)

        # Wrap callback methods in appropriate ctypefunc instances so
        # that the Pulseaudio C API can call them
        self._context_notify_cb = pa_context_notify_cb_t(self.context_notify_cb)
        self._sink_info_cb = self.fn_pa_stream_info_cb_t(self.sink_info_cb)
        self._stream_read_cb = pa_stream_request_cb_t(self.stream_read_cb)

        # stream_read_cb() puts peak samples into this Queue instance
        self._samples = Queue(maxsize=rate)

        # Create the mainloop thread and set our context_notify_cb
        # method to be called when there's updates relating to the
        # connection to Pulseaudio
        _mainloop = pa_threaded_mainloop_new()
        _mainloop_api = pa_threaded_mainloop_get_api(_mainloop)
        
        # context = pa_context_new(_mainloop_api, 'peak_demo')
        proplist = pa_proplist_new()
        pa_proplist_sets(proplist, PA_PROP_APPLICATION_ID, "org.PulseAudio.pavucontrol")
        context = pa_context_new_with_proplist(_mainloop_api, None, proplist)

        pa_context_set_state_callback(context, self._context_notify_cb, None)
        pa_context_connect(context, None, 0, None)
        pa_threaded_mainloop_start(_mainloop)

    def __iter__(self):
        while True:
            yield self._samples.get()

    def context_notify_cb(self, context, _):
        state = pa_context_get_state(context)

        if state == PA_CONTEXT_READY:
            # Connected to Pulseaudio. Now request that sink_info_cb
            # be called with information about the available sinks.
            o = self.fn_pa_context_get_stream_info_list(context, self._sink_info_cb, None)
            pa_operation_unref(o)

        elif state == PA_CONTEXT_FAILED :
            print "Connection failed"

        elif state == PA_CONTEXT_TERMINATED:
            print "Connection terminated"

    def sink_info_cb(self, context, sink_info_p, _, __):
        if not sink_info_p:
            return

        sink_info = sink_info_p.contents
        # print 'sink seen: %s / %s' % (sink_info.name, sink_info.description)
        # print 'sink seen: [%s] %s' % (sink_info.index, sink_info.name)

        if sink_info.name == self.stream_name:
            # Found the sink we want to monitor for peak levels.
            # Tell PA to call stream_read_cb with peak samples.
            # Eg: https://github.com/pulseaudio/pavucontrol/blob/574139c10e70b63874bcb75fe4cdfd1f4644ad68/src/mainwindow.cc#L574
            samplespec = pa_sample_spec()
            samplespec.channels = 1
            samplespec.format = PA_SAMPLE_U8
            samplespec.rate = self.rate

            pa_stream = pa_stream_new(context, "peak detect demo", samplespec, None)
            pa_stream_set_read_callback(pa_stream,
                                        self._stream_read_cb,
                                        sink_info.index)

            # sinkinput and sourceoutput
            if self.stream_index != -1:
                pa_stream_set_monitor_stream(pa_stream, self.stream_index)
                # print('pa_stream_set_monitor_stream', self.stream_index)

            flags = PA_STREAM_DONT_MOVE | PA_STREAM_PEAK_DETECT | PA_STREAM_ADJUST_LATENCY
            pa_stream_connect_record(pa_stream,
                                     self.getMonitorName(sink_info),
                                     None,
                                     flags)

    # def log(self, s):
    #     import os
    #     with open(os.path.expanduser("~/Desktop/peak_monitor.log"), 'a+') as f:
    #         f.write(str(s) + '\n')
        
    # def logStreamInfo(self, stream_info):
    #     import os
    #     with open(os.path.expanduser("~/Desktop/peak_monitor.log"), 'a+') as f:
    #         f.write(str(stream_info.name) + '\n')
    #         if self.stream_type == 'sink':
    #             f.write('\t' + str(stream_info.monitor_source_name) + '\n')
    #         elif self.stream_type == 'source':
    #             f.write('\t' + str(stream_info.monitor_of_sink_name) + '\n')

    def getMonitorName(self, stream_info):
        # self.logStreamInfo(stream_info)
        if self.stream_type == 'sink' or self.stream_type == 'sinkinput':
            return stream_info.monitor_source_name
        elif self.stream_type == 'source' or self.stream_type == 'sourceoutput':
            return stream_info.name
        else:
            raise NotImplementedError()

    def stream_read_cb(self, stream, length, index_incr):
        data = c_void_p()
        
        if pa_stream_peek(stream, data, c_ulong(length)) < 0:
            print("Failed to read data from stream")
            return

        if not data:
            # NULL data means either a hole or empty buffer
            # Only drop the stream when there is a hole (length > 0)
            if length:
                pa_stream_drop(stream)
            return

        assert(length > 0)
        assert(length % sizeof(c_ubyte) == 0)

        data = cast(data, POINTER(c_ubyte))
        for i in xrange(length):
            # When PA_SAMPLE_U8 is used, samples values range from 128
            # to 255 because the underlying audio data is signed but
            # it doesn't make sense to return signed peaks.
            self._samples.put(data[i] - 128)
        pa_stream_drop(stream)


if __name__ == '__main__':
    import sys
    stream_type = sys.argv[1].lower()
    stream_name = sys.argv[2]
    stream_index = int(sys.argv[3]) if len(sys.argv) >= 4 else -1
    peak = PeakMonitor(stream_type, stream_name, stream_index=stream_index, rate=30)
    for sample in peak:
        # samples = 0..127
        # 65536 = PulseAudio.NormalVolume = 100%
        # 128 = 2^7
        # 65536 = 2^16
        # 65536 = 2^7 * 2^9
        # 512 = 2^9
        sys.stdout.write(str(sample * 512) + "\n")
        sys.stdout.flush()
