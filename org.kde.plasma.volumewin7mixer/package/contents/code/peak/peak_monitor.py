#!/bin/python2

# See http://freshfoo.com/blog/pulseaudio_monitoring for information on how
# this module works.

import sys
from Queue import Queue
from ctypes import POINTER, c_ubyte, c_void_p, c_ulong, cast, sizeof

# From https://github.com/Valodim/python-pulseaudio
from lib_pulseaudio import *

class PeakMonitor(object):

    def __init__(self, stream_type, device_index, stream_index=-1, rate=30):
        self.stream_type = stream_type
        self.device_index = device_index
        self.stream_index = stream_index
        self.rate = rate

        # Wrap callback methods in appropriate ctypefunc instances so
        # that the Pulseaudio C API can call them
        self._context_notify_cb = pa_context_notify_cb_t(self.context_notify_cb)
        self._stream_read_cb = pa_stream_request_cb_t(self.stream_read_cb)
        self._stream_suspended_cb = pa_stream_notify_cb_t(self.stream_suspended_cb)

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
            # Connected to Pulseaudio. Register the peak monitor.
            self.register_peak_monitor(context)

        elif state == PA_CONTEXT_FAILED :
            print "Connection failed"

        elif state == PA_CONTEXT_TERMINATED:
            print "Connection terminated"

    def register_peak_monitor(self, context):
        # Tell PA to call stream_read_cb with peak samples.
        # Eg: https://github.com/pulseaudio/pavucontrol/blob/574139c10e70b63874bcb75fe4cdfd1f4644ad68/src/mainwindow.cc#L574
        samplespec = pa_sample_spec()
        samplespec.channels = 1
        samplespec.format = PA_SAMPLE_U8
        samplespec.rate = self.rate

        pa_stream = pa_stream_new(context, "Peak detect (plasma-pa-feedback)", samplespec, None)
        if not pa_stream:
            print("Failed to create monitoring stream")
            return

        pa_stream_set_read_callback(pa_stream, self._stream_read_cb, self.device_index)
        pa_stream_set_suspended_callback(pa_stream, self._stream_suspended_cb, self.device_index)

        # sinkinput and sourceoutput
        if self.stream_index != -1:
            pa_stream_set_monitor_stream(pa_stream, self.stream_index)

        flags = PA_STREAM_DONT_MOVE | PA_STREAM_PEAK_DETECT | PA_STREAM_ADJUST_LATENCY
        dev = STRING(str(self.device_index))
        attr = None
        result = pa_stream_connect_record(pa_stream, dev, attr, flags)
        if result < 0:
            print("Failed to connect monitoring stream")
            pa_stream_unref(pa_stream)
            return

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

    def stream_suspended_cb(self, stream, userdata):
        if pa_stream_is_suspended(stream):
            print("stream suspended")
            # w->updateVolumeMeter(pa_stream_get_device_index(s), PA_INVALID_INDEX, -1);



if __name__ == '__main__':
    import sys
    stream_type = sys.argv[1].lower()
    device_index = int(sys.argv[2])
    stream_index = int(sys.argv[3]) if len(sys.argv) >= 4 else -1
    
    peak = PeakMonitor(stream_type, device_index, stream_index=stream_index, rate=30)
    for sample in peak:
        # samples = 0..127
        # 65536 = PulseAudio.NormalVolume = 100%
        # 128 = 2^7
        # 65536 = 2^16
        # 65536 = 2^7 * 2^9
        # 512 = 2^9
        sys.stdout.write(str(sample * 512) + "\n")
        sys.stdout.flush()
