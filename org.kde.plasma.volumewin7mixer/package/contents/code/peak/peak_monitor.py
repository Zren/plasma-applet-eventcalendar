#!/bin/python2

# See http://freshfoo.com/blog/pulseaudio_monitoring for information on how
# this module works.

import sys
from Queue import Queue
from ctypes import POINTER, c_ubyte, c_void_p, c_ulong, cast

# From https://github.com/Valodim/python-pulseaudio
from lib_pulseaudio import *

class PeakMonitor(object):

    def __init__(self, stream_type, stream_name, rate):
        self.stream_type = stream_type
        self.stream_name = stream_name
        self.rate = rate

        if stream_type == 'sink':
            self.fn_pa_stream_info_cb_t = pa_sink_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_sink_info_list
        elif stream_type == 'source':
            self.fn_pa_stream_info_cb_t = pa_source_info_cb_t
            self.fn_pa_context_get_stream_info_list = pa_context_get_source_info_list
        # elif stream_type == 'sourceoutput':
        #     self.fn_pa_stream_info_cb_t = pa_source_output_info_cb_t
        #     self.fn_pa_context_get_stream_info_list = pa_context_get_source_output_info_list
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

        if sink_info.name == self.stream_name:
            # Found the sink we want to monitor for peak levels.
            # Tell PA to call stream_read_cb with peak samples.
            samplespec = pa_sample_spec()
            samplespec.channels = 1
            samplespec.format = PA_SAMPLE_U8
            samplespec.rate = self.rate

            pa_stream = pa_stream_new(context, "peak detect demo", samplespec, None)
            pa_stream_set_read_callback(pa_stream,
                                        self._stream_read_cb,
                                        sink_info.index)
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
        if self.stream_type == 'sink':
            return stream_info.monitor_source_name
        elif self.stream_type == 'source':
            return stream_info.name
        # elif self.stream_type == 'sourceoutput':
        #     return stream_info.name
        else:
            raise NotImplementedError()

    def stream_read_cb(self, stream, length, index_incr):
        data = c_void_p()
        pa_stream_peek(stream, data, c_ulong(length))
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
    peak = PeakMonitor(stream_type, stream_name, 30)
    for sample in peak:
        # samples = 0..127
        # 65536 = PulseAudio.NormalVolume = 100%
        # 128 = 2^7
        # 65536 = 2^16
        # 65536 = 2^7 * 2^9
        # 512 = 2^9
        sys.stdout.write(str(sample * 512) + "\n")
        sys.stdout.flush()
