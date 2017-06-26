# This file is from a python library
# by Vincent Breitmoser, released under LGPL
# https://github.com/Valodim/python-pulseaudio

# I (Zren) modified __all__ to export STRING

# generation commands
# h2xml.py -I $PWD -c -o pa.xml pulse/mainloop-api.h pulse/sample.h pulse/def.h pulse/operation.h pulse/context.h pulse/channelmap.h pulse/volume.h pulse/stream.h pulse/introspect.h pulse/subscribe.h pulse/scache.h pulse/version.h pulse/error.h pulse/xmalloc.h pulse/utf8.h pulse/thread-mainloop.h pulse/mainloop.h pulse/mainloop-signal.h pulse/util.h pulse/timeval.h
# xml2py.py -k efstd -o lib_pulseaudio.py -l 'pulse' -r '(pa|PA)_.+' pa.xml

from ctypes import *

_libraries = {}
_libraries['libpulse.so.0'] = CDLL('libpulse.so.0')
STRING = c_char_p


PA_CHANNEL_MAP_DEF_MAX = 5
PA_SAMPLE_S24_32BE = 12
PA_SOURCE_DECIBEL_VOLUME = 32
PA_SAMPLE_S24_32LE = 11
PA_SUBSCRIPTION_MASK_NULL = 0
PA_SAMPLE_S24BE = 10
PA_CHANNEL_POSITION_TOP_REAR_CENTER = 50
PA_CHANNEL_MAP_AIFF = 0
PA_CHANNEL_POSITION_TOP_REAR_LEFT = 48
PA_SAMPLE_S32LE = 7
PA_SOURCE_HARDWARE = 4
PA_CHANNEL_POSITION_TOP_FRONT_CENTER = 47
PA_CONTEXT_TERMINATED = 6
PA_CONTEXT_FAILED = 5
PA_CONTEXT_CONNECTING = 1
PA_CHANNEL_POSITION_TOP_FRONT_LEFT = 45
PA_UPDATE_REPLACE = 2
PA_UPDATE_MERGE = 1
PA_SOURCE_NOFLAGS = 0
PA_IO_EVENT_HANGUP = 4
PA_ERR_INVALID = 3
PA_CHANNEL_POSITION_AUX31 = 43
PA_STREAM_AUTO_TIMING_UPDATE = 8
PA_SAMPLE_ULAW = 2
PA_SAMPLE_ALAW = 1
PA_CHANNEL_POSITION_AUX28 = 40
PA_AUTOLOAD_SINK = 0
PA_SOURCE_FLAT_VOLUME = 128
PA_CHANNEL_POSITION_AUX27 = 39
PA_SOURCE_HW_MUTE_CTRL = 16
PA_SOURCE_NETWORK = 8
PA_SOURCE_LATENCY = 2
PA_SOURCE_HW_VOLUME_CTRL = 1
PA_CHANNEL_POSITION_AUX24 = 36
PA_STREAM_RELATIVE_VOLUME = 262144
PA_SINK_DYNAMIC_LATENCY = 128
PA_STREAM_START_UNMUTED = 65536
PA_STREAM_DONT_INHIBIT_AUTO_SUSPEND = 32768
PA_STREAM_ADJUST_LATENCY = 8192
PA_STREAM_START_MUTED = 4096
PA_STREAM_PEAK_DETECT = 2048
PA_STREAM_DONT_MOVE = 512
PA_STREAM_FIX_CHANNELS = 256
PA_STREAM_NO_REMAP_CHANNELS = 16
PA_SINK_IDLE = 1
PA_STREAM_NOT_MONOTONIC = 4
PA_CHANNEL_MAP_ALSA = 1
PA_SEEK_ABSOLUTE = 1
PA_CHANNEL_POSITION_AUX17 = 29
PA_SOURCE_DYNAMIC_LATENCY = 64
PA_SUBSCRIPTION_EVENT_TYPE_MASK = 48
PA_CHANNEL_POSITION_AUX16 = 28
PA_STREAM_START_CORKED = 1
PA_STREAM_UPLOAD = 3
PA_STREAM_RECORD = 2
PA_SINK_UNLINKED = -3
PA_SOURCE_SUSPENDED = 2
PA_CHANNEL_POSITION_AUX13 = 25
PA_SINK_DECIBEL_VOLUME = 32
PA_SOURCE_RUNNING = 0
PA_AUTOLOAD_SOURCE = 1
PA_STREAM_NOFLAGS = 0
PA_IO_EVENT_ERROR = 8
PA_CHANNEL_POSITION_AUX26 = 38
PA_CONTEXT_NOAUTOSPAWN = 1
PA_SAMPLE_FLOAT32BE = 6
PA_SINK_RUNNING = 0
PA_SINK_INVALID_STATE = -1
PA_ENCODING_ANY = 0
PA_STREAM_PLAYBACK = 1
PA_STREAM_NODIRECTION = 0
PA_OPERATION_CANCELLED = 2
PA_OPERATION_DONE = 1
PA_OPERATION_RUNNING = 0
PA_IO_EVENT_INPUT = 1
PA_IO_EVENT_OUTPUT = 2
PA_STREAM_EARLY_REQUESTS = 16384
PA_CHANNEL_POSITION_AUX6 = 18
PA_CHANNEL_POSITION_AUX19 = 31
PA_SINK_SET_FORMATS = 256
PA_CHANNEL_POSITION_AUX5 = 17
PA_SINK_FLAT_VOLUME = 64
PA_SINK_HW_MUTE_CTRL = 16
PA_STREAM_FAIL_ON_SUSPEND = 131072
PA_SINK_NETWORK = 8
PA_SINK_HARDWARE = 4
PA_SINK_LATENCY = 2
PA_SINK_HW_VOLUME_CTRL = 1
PA_SINK_NOFLAGS = 0
PA_STREAM_VARIABLE_RATE = 1024
PA_CHANNEL_POSITION_AUX2 = 14
PA_CHANNEL_POSITION_AUX1 = 13
PA_ENCODING_INVALID = -1
PA_ENCODING_MAX = 6
PA_ENCODING_DTS_IEC61937 = 5
PA_ENCODING_MPEG_IEC61937 = 4
PA_SUBSCRIPTION_MASK_AUTOLOAD = 256
PA_CHANNEL_POSITION_AUX18 = 30
PA_CHANNEL_POSITION_SIDE_RIGHT = 11
PA_CHANNEL_POSITION_MAX = 51
PA_STREAM_FIX_RATE = 128
PA_CHANNEL_POSITION_TOP_REAR_RIGHT = 49
PA_CHANNEL_POSITION_SIDE_LEFT = 10
PA_CHANNEL_POSITION_TOP_FRONT_RIGHT = 46
PA_CHANNEL_POSITION_TOP_CENTER = 44
PA_STREAM_FIX_FORMAT = 64
PA_UPDATE_SET = 0
PA_CHANNEL_POSITION_AUX30 = 42
PA_ERR_TIMEOUT = 8
PA_CHANNEL_POSITION_AUX29 = 41
PA_STREAM_NO_REMIX_CHANNELS = 32
PA_CHANNEL_POSITION_AUX23 = 35
PA_CHANNEL_POSITION_AUX22 = 34
PA_CHANNEL_POSITION_AUX20 = 32
PA_SOURCE_IDLE = 1
PA_SOURCE_UNLINKED = -3
PA_SOURCE_INIT = -2
PA_CHANNEL_POSITION_AUX14 = 26
PA_CHANNEL_POSITION_AUX0 = 12
PA_CHANNEL_POSITION_AUX12 = 24
PA_CHANNEL_POSITION_LFE = 7
PA_SEEK_RELATIVE_END = 3
PA_CHANNEL_POSITION_AUX8 = 20
PA_CHANNEL_POSITION_AUX7 = 19
PA_CONTEXT_SETTING_NAME = 3
PA_CHANNEL_POSITION_AUX4 = 16
PA_CHANNEL_POSITION_AUX3 = 15
PA_STREAM_INTERPOLATE_TIMING = 2
PA_CHANNEL_POSITION_FRONT_LEFT_OF_CENTER = 8
PA_CHANNEL_POSITION_SUBWOOFER = 7
PA_CHANNEL_POSITION_REAR_CENTER = 4
PA_CHANNEL_POSITION_REAR_RIGHT = 6
PA_CHANNEL_POSITION_REAR_LEFT = 5
PA_CHANNEL_POSITION_CENTER = 3
PA_CHANNEL_POSITION_RIGHT = 2
PA_CHANNEL_POSITION_LEFT = 1
PA_CONTEXT_UNCONNECTED = 0
PA_CHANNEL_POSITION_FRONT_RIGHT = 2
PA_CHANNEL_POSITION_FRONT_LEFT = 1
PA_CHANNEL_POSITION_MONO = 0
PA_CHANNEL_POSITION_INVALID = -1
PA_ERR_KILLED = 12
PA_SUBSCRIPTION_MASK_ALL = 767
PA_ERR_MAX = 27
PA_CHANNEL_POSITION_FRONT_CENTER = 3
PA_ERR_BUSY = 26
PA_SUBSCRIPTION_MASK_SERVER = 128
PA_ERR_FORKED = 24
PA_SUBSCRIPTION_MASK_CLIENT = 32
PA_SUBSCRIPTION_MASK_MODULE = 16
PA_SUBSCRIPTION_MASK_SINK_INPUT = 4
PA_SEEK_RELATIVE_ON_READ = 2
PA_ERR_VERSION = 17
PA_SOURCE_INVALID_STATE = -1
PA_ERR_NODATA = 16
PA_ERR_BADSTATE = 15
PA_ERR_MODINITFAILED = 14
PA_ERR_INVALIDSERVER = 13
PA_CHANNEL_POSITION_AUX25 = 37
PA_ERR_CONNECTIONTERMINATED = 11
PA_ERR_INTERNAL = 10
PA_ERR_AUTHKEY = 9
PA_CHANNEL_POSITION_AUX15 = 27
PA_ENCODING_EAC3_IEC61937 = 3
PA_ERR_PROTOCOL = 7
PA_ERR_CONNECTIONREFUSED = 6
PA_ERR_NOENTITY = 5
PA_ERR_COMMAND = 2
PA_ERR_ACCESS = 1
PA_OK = 0
PA_SUBSCRIPTION_EVENT_REMOVE = 32
PA_SUBSCRIPTION_EVENT_CHANGE = 16
PA_SUBSCRIPTION_EVENT_NEW = 0
PA_SINK_INIT = -2
PA_SUBSCRIPTION_EVENT_FACILITY_MASK = 15
PA_SUBSCRIPTION_EVENT_CARD = 9
PA_SUBSCRIPTION_EVENT_AUTOLOAD = 8
PA_SUBSCRIPTION_EVENT_SERVER = 7
PA_CHANNEL_POSITION_FRONT_RIGHT_OF_CENTER = 9
PA_SUBSCRIPTION_EVENT_CLIENT = 5
PA_SUBSCRIPTION_EVENT_MODULE = 4
PA_ENCODING_AC3_IEC61937 = 2
PA_SUBSCRIPTION_EVENT_SOURCE_OUTPUT = 3
PA_SUBSCRIPTION_EVENT_SINK_INPUT = 2
PA_SUBSCRIPTION_EVENT_SOURCE = 1
PA_SUBSCRIPTION_EVENT_SINK = 0
PA_ERR_EXIST = 4
PA_ERR_NOEXTENSION = 21
PA_CONTEXT_READY = 4
PA_DEVICE_TYPE_SOURCE = 1
PA_DEVICE_TYPE_SINK = 0
PA_CHANNEL_POSITION_AUX9 = 21
PA_SUBSCRIPTION_MASK_SOURCE_OUTPUT = 8
PA_ENCODING_PCM = 1
PA_STREAM_TERMINATED = 4
PA_STREAM_FAILED = 3
PA_STREAM_CREATING = 1
PA_ERR_UNKNOWN = 20
PA_STREAM_UNCONNECTED = 0
PA_CHANNEL_MAP_DEFAULT = 0
PA_SAMPLE_MAX = 13
PA_CHANNEL_MAP_OSS = 4
PA_CHANNEL_MAP_WAVEEX = 3
PA_CONTEXT_NOFLAGS = 0
PA_CHANNEL_MAP_AUX = 2
PA_SUBSCRIPTION_MASK_CARD = 512
PA_CHANNEL_POSITION_AUX21 = 33
PA_SAMPLE_S24LE = 9
PA_SAMPLE_S32BE = 8
PA_SAMPLE_FLOAT32LE = 5
PA_STREAM_PASSTHROUGH = 524288
PA_SAMPLE_S16BE = 4
PA_SAMPLE_U8 = 0
PA_ERR_IO = 25
PA_SUBSCRIPTION_MASK_SAMPLE_CACHE = 64
PA_ERR_NOTSUPPORTED = 19
PA_ERR_TOOLARGE = 18
PA_CONTEXT_AUTHORIZING = 2
PA_ERR_NOTIMPLEMENTED = 23
PA_CONTEXT_NOFAIL = 2
PA_ERR_OBSOLETE = 22
PA_STREAM_READY = 2
PA_SAMPLE_INVALID = -1
PA_CHANNEL_POSITION_AUX11 = 23
PA_SUBSCRIPTION_MASK_SOURCE = 2
PA_SINK_SUSPENDED = 2
PA_SUBSCRIPTION_MASK_SINK = 1
PA_SUBSCRIPTION_EVENT_SAMPLE_CACHE = 6
PA_CHANNEL_POSITION_AUX10 = 22
PA_SEEK_RELATIVE = 0
PA_SAMPLE_S16LE = 3
PA_IO_EVENT_NULL = 0

# values for enumeration 'pa_channel_position'
pa_channel_position = c_int # enum
pa_channel_position_t = pa_channel_position
uint64_t = c_uint64
pa_channel_position_mask_t = uint64_t

# values for enumeration 'pa_channel_map_def'
pa_channel_map_def = c_int # enum
pa_channel_map_def_t = pa_channel_map_def
class pa_channel_map(Structure):
    pass
uint8_t = c_uint8
pa_channel_map._fields_ = [
    ('channels', uint8_t),
    ('map', pa_channel_position_t * 32),
]
pa_channel_map_init = _libraries['libpulse.so.0'].pa_channel_map_init
pa_channel_map_init.restype = POINTER(pa_channel_map)
pa_channel_map_init.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_init_mono = _libraries['libpulse.so.0'].pa_channel_map_init_mono
pa_channel_map_init_mono.restype = POINTER(pa_channel_map)
pa_channel_map_init_mono.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_init_stereo = _libraries['libpulse.so.0'].pa_channel_map_init_stereo
pa_channel_map_init_stereo.restype = POINTER(pa_channel_map)
pa_channel_map_init_stereo.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_init_auto = _libraries['libpulse.so.0'].pa_channel_map_init_auto
pa_channel_map_init_auto.restype = POINTER(pa_channel_map)
pa_channel_map_init_auto.argtypes = [POINTER(pa_channel_map), c_uint, pa_channel_map_def_t]
pa_channel_map_init_extend = _libraries['libpulse.so.0'].pa_channel_map_init_extend
pa_channel_map_init_extend.restype = POINTER(pa_channel_map)
pa_channel_map_init_extend.argtypes = [POINTER(pa_channel_map), c_uint, pa_channel_map_def_t]
pa_channel_position_to_string = _libraries['libpulse.so.0'].pa_channel_position_to_string
pa_channel_position_to_string.restype = STRING
pa_channel_position_to_string.argtypes = [pa_channel_position_t]
pa_channel_position_from_string = _libraries['libpulse.so.0'].pa_channel_position_from_string
pa_channel_position_from_string.restype = pa_channel_position_t
pa_channel_position_from_string.argtypes = [STRING]
pa_channel_position_to_pretty_string = _libraries['libpulse.so.0'].pa_channel_position_to_pretty_string
pa_channel_position_to_pretty_string.restype = STRING
pa_channel_position_to_pretty_string.argtypes = [pa_channel_position_t]
size_t = c_ulong
pa_channel_map_snprint = _libraries['libpulse.so.0'].pa_channel_map_snprint
pa_channel_map_snprint.restype = STRING
pa_channel_map_snprint.argtypes = [STRING, size_t, POINTER(pa_channel_map)]
pa_channel_map_parse = _libraries['libpulse.so.0'].pa_channel_map_parse
pa_channel_map_parse.restype = POINTER(pa_channel_map)
pa_channel_map_parse.argtypes = [POINTER(pa_channel_map), STRING]
pa_channel_map_equal = _libraries['libpulse.so.0'].pa_channel_map_equal
pa_channel_map_equal.restype = c_int
pa_channel_map_equal.argtypes = [POINTER(pa_channel_map), POINTER(pa_channel_map)]
pa_channel_map_valid = _libraries['libpulse.so.0'].pa_channel_map_valid
pa_channel_map_valid.restype = c_int
pa_channel_map_valid.argtypes = [POINTER(pa_channel_map)]
class pa_sample_spec(Structure):
    pass
pa_channel_map_compatible = _libraries['libpulse.so.0'].pa_channel_map_compatible
pa_channel_map_compatible.restype = c_int
pa_channel_map_compatible.argtypes = [POINTER(pa_channel_map), POINTER(pa_sample_spec)]
pa_channel_map_superset = _libraries['libpulse.so.0'].pa_channel_map_superset
pa_channel_map_superset.restype = c_int
pa_channel_map_superset.argtypes = [POINTER(pa_channel_map), POINTER(pa_channel_map)]
pa_channel_map_can_balance = _libraries['libpulse.so.0'].pa_channel_map_can_balance
pa_channel_map_can_balance.restype = c_int
pa_channel_map_can_balance.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_can_fade = _libraries['libpulse.so.0'].pa_channel_map_can_fade
pa_channel_map_can_fade.restype = c_int
pa_channel_map_can_fade.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_to_name = _libraries['libpulse.so.0'].pa_channel_map_to_name
pa_channel_map_to_name.restype = STRING
pa_channel_map_to_name.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_to_pretty_name = _libraries['libpulse.so.0'].pa_channel_map_to_pretty_name
pa_channel_map_to_pretty_name.restype = STRING
pa_channel_map_to_pretty_name.argtypes = [POINTER(pa_channel_map)]
pa_channel_map_has_position = _libraries['libpulse.so.0'].pa_channel_map_has_position
pa_channel_map_has_position.restype = c_int
pa_channel_map_has_position.argtypes = [POINTER(pa_channel_map), pa_channel_position_t]
pa_channel_map_mask = _libraries['libpulse.so.0'].pa_channel_map_mask
pa_channel_map_mask.restype = pa_channel_position_mask_t
pa_channel_map_mask.argtypes = [POINTER(pa_channel_map)]
class pa_context(Structure):
    pass
pa_context._fields_ = [
]
pa_context_notify_cb_t = CFUNCTYPE(None, POINTER(pa_context), c_void_p)
pa_context_success_cb_t = CFUNCTYPE(None, POINTER(pa_context), c_int, c_void_p)
class pa_proplist(Structure):
    pass
pa_context_event_cb_t = CFUNCTYPE(None, POINTER(pa_context), STRING, POINTER(pa_proplist), c_void_p)
class pa_mainloop_api(Structure):
    pass
pa_context_new = _libraries['libpulse.so.0'].pa_context_new
pa_context_new.restype = POINTER(pa_context)
pa_context_new.argtypes = [POINTER(pa_mainloop_api), STRING]
pa_context_new_with_proplist = _libraries['libpulse.so.0'].pa_context_new_with_proplist
pa_context_new_with_proplist.restype = POINTER(pa_context)
pa_context_new_with_proplist.argtypes = [POINTER(pa_mainloop_api), STRING, POINTER(pa_proplist)]
pa_context_unref = _libraries['libpulse.so.0'].pa_context_unref
pa_context_unref.restype = None
pa_context_unref.argtypes = [POINTER(pa_context)]
pa_context_ref = _libraries['libpulse.so.0'].pa_context_ref
pa_context_ref.restype = POINTER(pa_context)
pa_context_ref.argtypes = [POINTER(pa_context)]
pa_context_set_state_callback = _libraries['libpulse.so.0'].pa_context_set_state_callback
pa_context_set_state_callback.restype = None
pa_context_set_state_callback.argtypes = [POINTER(pa_context), pa_context_notify_cb_t, c_void_p]
pa_context_set_event_callback = _libraries['libpulse.so.0'].pa_context_set_event_callback
pa_context_set_event_callback.restype = None
pa_context_set_event_callback.argtypes = [POINTER(pa_context), pa_context_event_cb_t, c_void_p]
pa_context_errno = _libraries['libpulse.so.0'].pa_context_errno
pa_context_errno.restype = c_int
pa_context_errno.argtypes = [POINTER(pa_context)]
pa_context_is_pending = _libraries['libpulse.so.0'].pa_context_is_pending
pa_context_is_pending.restype = c_int
pa_context_is_pending.argtypes = [POINTER(pa_context)]

# values for enumeration 'pa_context_state'
pa_context_state = c_int # enum
pa_context_state_t = pa_context_state
pa_context_get_state = _libraries['libpulse.so.0'].pa_context_get_state
pa_context_get_state.restype = pa_context_state_t
pa_context_get_state.argtypes = [POINTER(pa_context)]

# values for enumeration 'pa_context_flags'
pa_context_flags = c_int # enum
pa_context_flags_t = pa_context_flags
class pa_spawn_api(Structure):
    pass
pa_context_connect = _libraries['libpulse.so.0'].pa_context_connect
pa_context_connect.restype = c_int
pa_context_connect.argtypes = [POINTER(pa_context), STRING, pa_context_flags_t, POINTER(pa_spawn_api)]
pa_context_disconnect = _libraries['libpulse.so.0'].pa_context_disconnect
pa_context_disconnect.restype = None
pa_context_disconnect.argtypes = [POINTER(pa_context)]
class pa_operation(Structure):
    pass
pa_context_drain = _libraries['libpulse.so.0'].pa_context_drain
pa_context_drain.restype = POINTER(pa_operation)
pa_context_drain.argtypes = [POINTER(pa_context), pa_context_notify_cb_t, c_void_p]
pa_context_exit_daemon = _libraries['libpulse.so.0'].pa_context_exit_daemon
pa_context_exit_daemon.restype = POINTER(pa_operation)
pa_context_exit_daemon.argtypes = [POINTER(pa_context), pa_context_success_cb_t, c_void_p]
pa_context_set_default_sink = _libraries['libpulse.so.0'].pa_context_set_default_sink
pa_context_set_default_sink.restype = POINTER(pa_operation)
pa_context_set_default_sink.argtypes = [POINTER(pa_context), STRING, pa_context_success_cb_t, c_void_p]
pa_context_set_default_source = _libraries['libpulse.so.0'].pa_context_set_default_source
pa_context_set_default_source.restype = POINTER(pa_operation)
pa_context_set_default_source.argtypes = [POINTER(pa_context), STRING, pa_context_success_cb_t, c_void_p]
pa_context_is_local = _libraries['libpulse.so.0'].pa_context_is_local
pa_context_is_local.restype = c_int
pa_context_is_local.argtypes = [POINTER(pa_context)]
pa_context_set_name = _libraries['libpulse.so.0'].pa_context_set_name
pa_context_set_name.restype = POINTER(pa_operation)
pa_context_set_name.argtypes = [POINTER(pa_context), STRING, pa_context_success_cb_t, c_void_p]
pa_context_get_server = _libraries['libpulse.so.0'].pa_context_get_server
pa_context_get_server.restype = STRING
pa_context_get_server.argtypes = [POINTER(pa_context)]
uint32_t = c_uint32
pa_context_get_protocol_version = _libraries['libpulse.so.0'].pa_context_get_protocol_version
pa_context_get_protocol_version.restype = uint32_t
pa_context_get_protocol_version.argtypes = [POINTER(pa_context)]
pa_context_get_server_protocol_version = _libraries['libpulse.so.0'].pa_context_get_server_protocol_version
pa_context_get_server_protocol_version.restype = uint32_t
pa_context_get_server_protocol_version.argtypes = [POINTER(pa_context)]

# values for enumeration 'pa_update_mode'
pa_update_mode = c_int # enum
pa_update_mode_t = pa_update_mode
pa_context_proplist_update = _libraries['libpulse.so.0'].pa_context_proplist_update
pa_context_proplist_update.restype = POINTER(pa_operation)
pa_context_proplist_update.argtypes = [POINTER(pa_context), pa_update_mode_t, POINTER(pa_proplist), pa_context_success_cb_t, c_void_p]
pa_context_proplist_remove = _libraries['libpulse.so.0'].pa_context_proplist_remove
pa_context_proplist_remove.restype = POINTER(pa_operation)
pa_context_proplist_remove.argtypes = [POINTER(pa_context), POINTER(STRING), pa_context_success_cb_t, c_void_p]
pa_context_get_index = _libraries['libpulse.so.0'].pa_context_get_index
pa_context_get_index.restype = uint32_t
pa_context_get_index.argtypes = [POINTER(pa_context)]
class pa_time_event(Structure):
    pass
pa_usec_t = uint64_t
class timeval(Structure):
    pass
__time_t = c_long
__suseconds_t = c_long
timeval._fields_ = [
    ('tv_sec', __time_t),
    ('tv_usec', __suseconds_t),
]
pa_time_event_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_time_event), POINTER(timeval), c_void_p)
pa_context_rttime_new = _libraries['libpulse.so.0'].pa_context_rttime_new
pa_context_rttime_new.restype = POINTER(pa_time_event)
pa_context_rttime_new.argtypes = [POINTER(pa_context), pa_usec_t, pa_time_event_cb_t, c_void_p]
pa_context_rttime_restart = _libraries['libpulse.so.0'].pa_context_rttime_restart
pa_context_rttime_restart.restype = None
pa_context_rttime_restart.argtypes = [POINTER(pa_context), POINTER(pa_time_event), pa_usec_t]
pa_context_get_tile_size = _libraries['libpulse.so.0'].pa_context_get_tile_size
pa_context_get_tile_size.restype = size_t
pa_context_get_tile_size.argtypes = [POINTER(pa_context), POINTER(pa_sample_spec)]

# values for enumeration 'pa_stream_state'
pa_stream_state = c_int # enum
pa_stream_state_t = pa_stream_state

# values for enumeration 'pa_operation_state'
pa_operation_state = c_int # enum
pa_operation_state_t = pa_operation_state

# values for enumeration 'pa_device_type'
pa_device_type = c_int # enum
pa_device_type_t = pa_device_type

# values for enumeration 'pa_stream_direction'
pa_stream_direction = c_int # enum
pa_stream_direction_t = pa_stream_direction

# values for enumeration 'pa_stream_flags'
pa_stream_flags = c_int # enum
pa_stream_flags_t = pa_stream_flags
class pa_buffer_attr(Structure):
    pass
pa_buffer_attr._fields_ = [
    ('maxlength', uint32_t),
    ('tlength', uint32_t),
    ('prebuf', uint32_t),
    ('minreq', uint32_t),
    ('fragsize', uint32_t),
]

# values for enumeration 'pa_subscription_mask'
pa_subscription_mask = c_int # enum
pa_subscription_mask_t = pa_subscription_mask

# values for enumeration 'pa_subscription_event_type'
pa_subscription_event_type = c_int # enum
pa_subscription_event_type_t = pa_subscription_event_type
class pa_timing_info(Structure):
    pass
int64_t = c_int64
pa_timing_info._fields_ = [
    ('timestamp', timeval),
    ('synchronized_clocks', c_int),
    ('sink_usec', pa_usec_t),
    ('source_usec', pa_usec_t),
    ('transport_usec', pa_usec_t),
    ('playing', c_int),
    ('write_index_corrupt', c_int),
    ('write_index', int64_t),
    ('read_index_corrupt', c_int),
    ('read_index', int64_t),
    ('configured_sink_usec', pa_usec_t),
    ('configured_source_usec', pa_usec_t),
    ('since_underrun', int64_t),
]
pa_spawn_api._fields_ = [
    ('prefork', CFUNCTYPE(None)),
    ('postfork', CFUNCTYPE(None)),
    ('atfork', CFUNCTYPE(None)),
]

# values for enumeration 'pa_seek_mode'
pa_seek_mode = c_int # enum
pa_seek_mode_t = pa_seek_mode

# values for enumeration 'pa_sink_flags'
pa_sink_flags = c_int # enum
pa_sink_flags_t = pa_sink_flags

# values for enumeration 'pa_sink_state'
pa_sink_state = c_int # enum
pa_sink_state_t = pa_sink_state

# values for enumeration 'pa_source_flags'
pa_source_flags = c_int # enum
pa_source_flags_t = pa_source_flags

# values for enumeration 'pa_source_state'
pa_source_state = c_int # enum
pa_source_state_t = pa_source_state
pa_free_cb_t = CFUNCTYPE(None, c_void_p)
pa_strerror = _libraries['libpulse.so.0'].pa_strerror
pa_strerror.restype = STRING
pa_strerror.argtypes = [c_int]

# values for enumeration 'pa_encoding'
pa_encoding = c_int # enum
pa_encoding_t = pa_encoding
pa_encoding_to_string = _libraries['libpulse.so.0'].pa_encoding_to_string
pa_encoding_to_string.restype = STRING
pa_encoding_to_string.argtypes = [pa_encoding_t]
class pa_format_info(Structure):
    pass
pa_format_info._fields_ = [
    ('encoding', pa_encoding_t),
    ('plist', POINTER(pa_proplist)),
]
pa_format_info_new = _libraries['libpulse.so.0'].pa_format_info_new
pa_format_info_new.restype = POINTER(pa_format_info)
pa_format_info_new.argtypes = []
pa_format_info_copy = _libraries['libpulse.so.0'].pa_format_info_copy
pa_format_info_copy.restype = POINTER(pa_format_info)
pa_format_info_copy.argtypes = [POINTER(pa_format_info)]
pa_format_info_free = _libraries['libpulse.so.0'].pa_format_info_free
pa_format_info_free.restype = None
pa_format_info_free.argtypes = [POINTER(pa_format_info)]
pa_format_info_valid = _libraries['libpulse.so.0'].pa_format_info_valid
pa_format_info_valid.restype = c_int
pa_format_info_valid.argtypes = [POINTER(pa_format_info)]
pa_format_info_is_pcm = _libraries['libpulse.so.0'].pa_format_info_is_pcm
pa_format_info_is_pcm.restype = c_int
pa_format_info_is_pcm.argtypes = [POINTER(pa_format_info)]
pa_format_info_is_compatible = _libraries['libpulse.so.0'].pa_format_info_is_compatible
pa_format_info_is_compatible.restype = c_int
pa_format_info_is_compatible.argtypes = [POINTER(pa_format_info), POINTER(pa_format_info)]
pa_format_info_snprint = _libraries['libpulse.so.0'].pa_format_info_snprint
pa_format_info_snprint.restype = STRING
pa_format_info_snprint.argtypes = [STRING, size_t, POINTER(pa_format_info)]
pa_format_info_from_string = _libraries['libpulse.so.0'].pa_format_info_from_string
pa_format_info_from_string.restype = POINTER(pa_format_info)
pa_format_info_from_string.argtypes = [STRING]
pa_format_info_set_prop_int = _libraries['libpulse.so.0'].pa_format_info_set_prop_int
pa_format_info_set_prop_int.restype = None
pa_format_info_set_prop_int.argtypes = [POINTER(pa_format_info), STRING, c_int]
pa_format_info_set_prop_int_array = _libraries['libpulse.so.0'].pa_format_info_set_prop_int_array
pa_format_info_set_prop_int_array.restype = None
pa_format_info_set_prop_int_array.argtypes = [POINTER(pa_format_info), STRING, POINTER(c_int), c_int]
pa_format_info_set_prop_int_range = _libraries['libpulse.so.0'].pa_format_info_set_prop_int_range
pa_format_info_set_prop_int_range.restype = None
pa_format_info_set_prop_int_range.argtypes = [POINTER(pa_format_info), STRING, c_int, c_int]
pa_format_info_set_prop_string = _libraries['libpulse.so.0'].pa_format_info_set_prop_string
pa_format_info_set_prop_string.restype = None
pa_format_info_set_prop_string.argtypes = [POINTER(pa_format_info), STRING, STRING]
pa_format_info_set_prop_string_array = _libraries['libpulse.so.0'].pa_format_info_set_prop_string_array
pa_format_info_set_prop_string_array.restype = None
pa_format_info_set_prop_string_array.argtypes = [POINTER(pa_format_info), STRING, POINTER(STRING), c_int]

# values for enumeration 'pa_sample_format'
pa_sample_format = c_int # enum
pa_sample_format_t = pa_sample_format
pa_format_info_set_sample_format = _libraries['libpulse.so.0'].pa_format_info_set_sample_format
pa_format_info_set_sample_format.restype = None
pa_format_info_set_sample_format.argtypes = [POINTER(pa_format_info), pa_sample_format_t]
pa_format_info_set_rate = _libraries['libpulse.so.0'].pa_format_info_set_rate
pa_format_info_set_rate.restype = None
pa_format_info_set_rate.argtypes = [POINTER(pa_format_info), c_int]
pa_format_info_set_channels = _libraries['libpulse.so.0'].pa_format_info_set_channels
pa_format_info_set_channels.restype = None
pa_format_info_set_channels.argtypes = [POINTER(pa_format_info), c_int]
pa_format_info_set_channel_map = _libraries['libpulse.so.0'].pa_format_info_set_channel_map
pa_format_info_set_channel_map.restype = None
pa_format_info_set_channel_map.argtypes = [POINTER(pa_format_info), POINTER(pa_channel_map)]
class pa_sink_port_info(Structure):
    pass
pa_sink_port_info._fields_ = [
    ('name', STRING),
    ('description', STRING),
    ('priority', uint32_t),
]
class pa_sink_info(Structure):
    pass
pa_sample_spec._fields_ = [
    ('format', pa_sample_format_t),
    ('rate', uint32_t),
    ('channels', uint8_t),
]
class pa_cvolume(Structure):
    pass
pa_volume_t = uint32_t
pa_cvolume._fields_ = [
    ('channels', uint8_t),
    ('values', pa_volume_t * 32),
]
pa_sink_info._fields_ = [
    ('name', STRING),
    ('index', uint32_t),
    ('description', STRING),
    ('sample_spec', pa_sample_spec),
    ('channel_map', pa_channel_map),
    ('owner_module', uint32_t),
    ('volume', pa_cvolume),
    ('mute', c_int),
    ('monitor_source', uint32_t),
    ('monitor_source_name', STRING),
    ('latency', pa_usec_t),
    ('driver', STRING),
    ('flags', pa_sink_flags_t),
    ('proplist', POINTER(pa_proplist)),
    ('configured_latency', pa_usec_t),
    ('base_volume', pa_volume_t),
    ('state', pa_sink_state_t),
    ('n_volume_steps', uint32_t),
    ('card', uint32_t),
    ('n_ports', uint32_t),
    ('ports', POINTER(POINTER(pa_sink_port_info))),
    ('active_port', POINTER(pa_sink_port_info)),
    ('n_formats', uint8_t),
    ('formats', POINTER(POINTER(pa_format_info))),
]
pa_sink_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_sink_info), c_int, c_void_p)
pa_context_get_sink_info_by_name = _libraries['libpulse.so.0'].pa_context_get_sink_info_by_name
pa_context_get_sink_info_by_name.restype = POINTER(pa_operation)
pa_context_get_sink_info_by_name.argtypes = [POINTER(pa_context), STRING, pa_sink_info_cb_t, c_void_p]
pa_context_get_sink_info_by_index = _libraries['libpulse.so.0'].pa_context_get_sink_info_by_index
pa_context_get_sink_info_by_index.restype = POINTER(pa_operation)
pa_context_get_sink_info_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_sink_info_cb_t, c_void_p]
pa_context_get_sink_info_list = _libraries['libpulse.so.0'].pa_context_get_sink_info_list
pa_context_get_sink_info_list.restype = POINTER(pa_operation)
pa_context_get_sink_info_list.argtypes = [POINTER(pa_context), pa_sink_info_cb_t, c_void_p]
pa_context_set_sink_volume_by_index = _libraries['libpulse.so.0'].pa_context_set_sink_volume_by_index
pa_context_set_sink_volume_by_index.restype = POINTER(pa_operation)
pa_context_set_sink_volume_by_index.argtypes = [POINTER(pa_context), uint32_t, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_sink_volume_by_name = _libraries['libpulse.so.0'].pa_context_set_sink_volume_by_name
pa_context_set_sink_volume_by_name.restype = POINTER(pa_operation)
pa_context_set_sink_volume_by_name.argtypes = [POINTER(pa_context), STRING, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_sink_mute_by_index = _libraries['libpulse.so.0'].pa_context_set_sink_mute_by_index
pa_context_set_sink_mute_by_index.restype = POINTER(pa_operation)
pa_context_set_sink_mute_by_index.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_set_sink_mute_by_name = _libraries['libpulse.so.0'].pa_context_set_sink_mute_by_name
pa_context_set_sink_mute_by_name.restype = POINTER(pa_operation)
pa_context_set_sink_mute_by_name.argtypes = [POINTER(pa_context), STRING, c_int, pa_context_success_cb_t, c_void_p]
pa_context_suspend_sink_by_name = _libraries['libpulse.so.0'].pa_context_suspend_sink_by_name
pa_context_suspend_sink_by_name.restype = POINTER(pa_operation)
pa_context_suspend_sink_by_name.argtypes = [POINTER(pa_context), STRING, c_int, pa_context_success_cb_t, c_void_p]
pa_context_suspend_sink_by_index = _libraries['libpulse.so.0'].pa_context_suspend_sink_by_index
pa_context_suspend_sink_by_index.restype = POINTER(pa_operation)
pa_context_suspend_sink_by_index.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_set_sink_port_by_index = _libraries['libpulse.so.0'].pa_context_set_sink_port_by_index
pa_context_set_sink_port_by_index.restype = POINTER(pa_operation)
pa_context_set_sink_port_by_index.argtypes = [POINTER(pa_context), uint32_t, STRING, pa_context_success_cb_t, c_void_p]
pa_context_set_sink_port_by_name = _libraries['libpulse.so.0'].pa_context_set_sink_port_by_name
pa_context_set_sink_port_by_name.restype = POINTER(pa_operation)
pa_context_set_sink_port_by_name.argtypes = [POINTER(pa_context), STRING, STRING, pa_context_success_cb_t, c_void_p]
class pa_source_port_info(Structure):
    pass
pa_source_port_info._fields_ = [
    ('name', STRING),
    ('description', STRING),
    ('priority', uint32_t),
]
class pa_source_info(Structure):
    pass
pa_source_info._fields_ = [
    ('name', STRING),
    ('index', uint32_t),
    ('description', STRING),
    ('sample_spec', pa_sample_spec),
    ('channel_map', pa_channel_map),
    ('owner_module', uint32_t),
    ('volume', pa_cvolume),
    ('mute', c_int),
    ('monitor_of_sink', uint32_t),
    ('monitor_of_sink_name', STRING),
    ('latency', pa_usec_t),
    ('driver', STRING),
    ('flags', pa_source_flags_t),
    ('proplist', POINTER(pa_proplist)),
    ('configured_latency', pa_usec_t),
    ('base_volume', pa_volume_t),
    ('state', pa_source_state_t),
    ('n_volume_steps', uint32_t),
    ('card', uint32_t),
    ('n_ports', uint32_t),
    ('ports', POINTER(POINTER(pa_source_port_info))),
    ('active_port', POINTER(pa_source_port_info)),
    ('n_formats', uint8_t),
    ('formats', POINTER(POINTER(pa_format_info))),
]
pa_source_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_source_info), c_int, c_void_p)
pa_context_get_source_info_by_name = _libraries['libpulse.so.0'].pa_context_get_source_info_by_name
pa_context_get_source_info_by_name.restype = POINTER(pa_operation)
pa_context_get_source_info_by_name.argtypes = [POINTER(pa_context), STRING, pa_source_info_cb_t, c_void_p]
pa_context_get_source_info_by_index = _libraries['libpulse.so.0'].pa_context_get_source_info_by_index
pa_context_get_source_info_by_index.restype = POINTER(pa_operation)
pa_context_get_source_info_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_source_info_cb_t, c_void_p]
pa_context_get_source_info_list = _libraries['libpulse.so.0'].pa_context_get_source_info_list
pa_context_get_source_info_list.restype = POINTER(pa_operation)
pa_context_get_source_info_list.argtypes = [POINTER(pa_context), pa_source_info_cb_t, c_void_p]
pa_context_set_source_volume_by_index = _libraries['libpulse.so.0'].pa_context_set_source_volume_by_index
pa_context_set_source_volume_by_index.restype = POINTER(pa_operation)
pa_context_set_source_volume_by_index.argtypes = [POINTER(pa_context), uint32_t, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_source_volume_by_name = _libraries['libpulse.so.0'].pa_context_set_source_volume_by_name
pa_context_set_source_volume_by_name.restype = POINTER(pa_operation)
pa_context_set_source_volume_by_name.argtypes = [POINTER(pa_context), STRING, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_source_mute_by_index = _libraries['libpulse.so.0'].pa_context_set_source_mute_by_index
pa_context_set_source_mute_by_index.restype = POINTER(pa_operation)
pa_context_set_source_mute_by_index.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_set_source_mute_by_name = _libraries['libpulse.so.0'].pa_context_set_source_mute_by_name
pa_context_set_source_mute_by_name.restype = POINTER(pa_operation)
pa_context_set_source_mute_by_name.argtypes = [POINTER(pa_context), STRING, c_int, pa_context_success_cb_t, c_void_p]
pa_context_suspend_source_by_name = _libraries['libpulse.so.0'].pa_context_suspend_source_by_name
pa_context_suspend_source_by_name.restype = POINTER(pa_operation)
pa_context_suspend_source_by_name.argtypes = [POINTER(pa_context), STRING, c_int, pa_context_success_cb_t, c_void_p]
pa_context_suspend_source_by_index = _libraries['libpulse.so.0'].pa_context_suspend_source_by_index
pa_context_suspend_source_by_index.restype = POINTER(pa_operation)
pa_context_suspend_source_by_index.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_set_source_port_by_index = _libraries['libpulse.so.0'].pa_context_set_source_port_by_index
pa_context_set_source_port_by_index.restype = POINTER(pa_operation)
pa_context_set_source_port_by_index.argtypes = [POINTER(pa_context), uint32_t, STRING, pa_context_success_cb_t, c_void_p]
pa_context_set_source_port_by_name = _libraries['libpulse.so.0'].pa_context_set_source_port_by_name
pa_context_set_source_port_by_name.restype = POINTER(pa_operation)
pa_context_set_source_port_by_name.argtypes = [POINTER(pa_context), STRING, STRING, pa_context_success_cb_t, c_void_p]
class pa_server_info(Structure):
    pass
pa_server_info._fields_ = [
    ('user_name', STRING),
    ('host_name', STRING),
    ('server_version', STRING),
    ('server_name', STRING),
    ('sample_spec', pa_sample_spec),
    ('default_sink_name', STRING),
    ('default_source_name', STRING),
    ('cookie', uint32_t),
    ('channel_map', pa_channel_map),
]
pa_server_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_server_info), c_void_p)
pa_context_get_server_info = _libraries['libpulse.so.0'].pa_context_get_server_info
pa_context_get_server_info.restype = POINTER(pa_operation)
pa_context_get_server_info.argtypes = [POINTER(pa_context), pa_server_info_cb_t, c_void_p]
class pa_module_info(Structure):
    pass
pa_module_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('argument', STRING),
    ('n_used', uint32_t),
    ('auto_unload', c_int),
    ('proplist', POINTER(pa_proplist)),
]
pa_module_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_module_info), c_int, c_void_p)
pa_context_get_module_info = _libraries['libpulse.so.0'].pa_context_get_module_info
pa_context_get_module_info.restype = POINTER(pa_operation)
pa_context_get_module_info.argtypes = [POINTER(pa_context), uint32_t, pa_module_info_cb_t, c_void_p]
pa_context_get_module_info_list = _libraries['libpulse.so.0'].pa_context_get_module_info_list
pa_context_get_module_info_list.restype = POINTER(pa_operation)
pa_context_get_module_info_list.argtypes = [POINTER(pa_context), pa_module_info_cb_t, c_void_p]
pa_context_index_cb_t = CFUNCTYPE(None, POINTER(pa_context), uint32_t, c_void_p)
pa_context_load_module = _libraries['libpulse.so.0'].pa_context_load_module
pa_context_load_module.restype = POINTER(pa_operation)
pa_context_load_module.argtypes = [POINTER(pa_context), STRING, STRING, pa_context_index_cb_t, c_void_p]
pa_context_unload_module = _libraries['libpulse.so.0'].pa_context_unload_module
pa_context_unload_module.restype = POINTER(pa_operation)
pa_context_unload_module.argtypes = [POINTER(pa_context), uint32_t, pa_context_success_cb_t, c_void_p]
class pa_client_info(Structure):
    pass
pa_client_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('owner_module', uint32_t),
    ('driver', STRING),
    ('proplist', POINTER(pa_proplist)),
]
pa_client_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_client_info), c_int, c_void_p)
pa_context_get_client_info = _libraries['libpulse.so.0'].pa_context_get_client_info
pa_context_get_client_info.restype = POINTER(pa_operation)
pa_context_get_client_info.argtypes = [POINTER(pa_context), uint32_t, pa_client_info_cb_t, c_void_p]
pa_context_get_client_info_list = _libraries['libpulse.so.0'].pa_context_get_client_info_list
pa_context_get_client_info_list.restype = POINTER(pa_operation)
pa_context_get_client_info_list.argtypes = [POINTER(pa_context), pa_client_info_cb_t, c_void_p]
pa_context_kill_client = _libraries['libpulse.so.0'].pa_context_kill_client
pa_context_kill_client.restype = POINTER(pa_operation)
pa_context_kill_client.argtypes = [POINTER(pa_context), uint32_t, pa_context_success_cb_t, c_void_p]
class pa_card_profile_info(Structure):
    pass
pa_card_profile_info._fields_ = [
    ('name', STRING),
    ('description', STRING),
    ('n_sinks', uint32_t),
    ('n_sources', uint32_t),
    ('priority', uint32_t),
]
class pa_card_info(Structure):
    pass
pa_card_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('owner_module', uint32_t),
    ('driver', STRING),
    ('n_profiles', uint32_t),
    ('profiles', POINTER(pa_card_profile_info)),
    ('active_profile', POINTER(pa_card_profile_info)),
    ('proplist', POINTER(pa_proplist)),
]
pa_card_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_card_info), c_int, c_void_p)
pa_context_get_card_info_by_index = _libraries['libpulse.so.0'].pa_context_get_card_info_by_index
pa_context_get_card_info_by_index.restype = POINTER(pa_operation)
pa_context_get_card_info_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_card_info_cb_t, c_void_p]
pa_context_get_card_info_by_name = _libraries['libpulse.so.0'].pa_context_get_card_info_by_name
pa_context_get_card_info_by_name.restype = POINTER(pa_operation)
pa_context_get_card_info_by_name.argtypes = [POINTER(pa_context), STRING, pa_card_info_cb_t, c_void_p]
pa_context_get_card_info_list = _libraries['libpulse.so.0'].pa_context_get_card_info_list
pa_context_get_card_info_list.restype = POINTER(pa_operation)
pa_context_get_card_info_list.argtypes = [POINTER(pa_context), pa_card_info_cb_t, c_void_p]
pa_context_set_card_profile_by_index = _libraries['libpulse.so.0'].pa_context_set_card_profile_by_index
pa_context_set_card_profile_by_index.restype = POINTER(pa_operation)
pa_context_set_card_profile_by_index.argtypes = [POINTER(pa_context), uint32_t, STRING, pa_context_success_cb_t, c_void_p]
pa_context_set_card_profile_by_name = _libraries['libpulse.so.0'].pa_context_set_card_profile_by_name
pa_context_set_card_profile_by_name.restype = POINTER(pa_operation)
pa_context_set_card_profile_by_name.argtypes = [POINTER(pa_context), STRING, STRING, pa_context_success_cb_t, c_void_p]
class pa_sink_input_info(Structure):
    pass
pa_sink_input_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('owner_module', uint32_t),
    ('client', uint32_t),
    ('sink', uint32_t),
    ('sample_spec', pa_sample_spec),
    ('channel_map', pa_channel_map),
    ('volume', pa_cvolume),
    ('buffer_usec', pa_usec_t),
    ('sink_usec', pa_usec_t),
    ('resample_method', STRING),
    ('driver', STRING),
    ('mute', c_int),
    ('proplist', POINTER(pa_proplist)),
    ('corked', c_int),
    ('has_volume', c_int),
    ('volume_writable', c_int),
    ('format', POINTER(pa_format_info)),
]
pa_sink_input_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_sink_input_info), c_int, c_void_p)
pa_context_get_sink_input_info = _libraries['libpulse.so.0'].pa_context_get_sink_input_info
pa_context_get_sink_input_info.restype = POINTER(pa_operation)
pa_context_get_sink_input_info.argtypes = [POINTER(pa_context), uint32_t, pa_sink_input_info_cb_t, c_void_p]
pa_context_get_sink_input_info_list = _libraries['libpulse.so.0'].pa_context_get_sink_input_info_list
pa_context_get_sink_input_info_list.restype = POINTER(pa_operation)
pa_context_get_sink_input_info_list.argtypes = [POINTER(pa_context), pa_sink_input_info_cb_t, c_void_p]
pa_context_move_sink_input_by_name = _libraries['libpulse.so.0'].pa_context_move_sink_input_by_name
pa_context_move_sink_input_by_name.restype = POINTER(pa_operation)
pa_context_move_sink_input_by_name.argtypes = [POINTER(pa_context), uint32_t, STRING, pa_context_success_cb_t, c_void_p]
pa_context_move_sink_input_by_index = _libraries['libpulse.so.0'].pa_context_move_sink_input_by_index
pa_context_move_sink_input_by_index.restype = POINTER(pa_operation)
pa_context_move_sink_input_by_index.argtypes = [POINTER(pa_context), uint32_t, uint32_t, pa_context_success_cb_t, c_void_p]
pa_context_set_sink_input_volume = _libraries['libpulse.so.0'].pa_context_set_sink_input_volume
pa_context_set_sink_input_volume.restype = POINTER(pa_operation)
pa_context_set_sink_input_volume.argtypes = [POINTER(pa_context), uint32_t, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_sink_input_mute = _libraries['libpulse.so.0'].pa_context_set_sink_input_mute
pa_context_set_sink_input_mute.restype = POINTER(pa_operation)
pa_context_set_sink_input_mute.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_kill_sink_input = _libraries['libpulse.so.0'].pa_context_kill_sink_input
pa_context_kill_sink_input.restype = POINTER(pa_operation)
pa_context_kill_sink_input.argtypes = [POINTER(pa_context), uint32_t, pa_context_success_cb_t, c_void_p]
class pa_source_output_info(Structure):
    pass
pa_source_output_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('owner_module', uint32_t),
    ('client', uint32_t),
    ('source', uint32_t),
    ('sample_spec', pa_sample_spec),
    ('channel_map', pa_channel_map),
    ('buffer_usec', pa_usec_t),
    ('source_usec', pa_usec_t),
    ('resample_method', STRING),
    ('driver', STRING),
    ('proplist', POINTER(pa_proplist)),
    ('corked', c_int),
    ('volume', pa_cvolume),
    ('mute', c_int),
    ('has_volume', c_int),
    ('volume_writable', c_int),
    ('format', POINTER(pa_format_info)),
]
pa_source_output_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_source_output_info), c_int, c_void_p)
pa_context_get_source_output_info = _libraries['libpulse.so.0'].pa_context_get_source_output_info
pa_context_get_source_output_info.restype = POINTER(pa_operation)
pa_context_get_source_output_info.argtypes = [POINTER(pa_context), uint32_t, pa_source_output_info_cb_t, c_void_p]
pa_context_get_source_output_info_list = _libraries['libpulse.so.0'].pa_context_get_source_output_info_list
pa_context_get_source_output_info_list.restype = POINTER(pa_operation)
pa_context_get_source_output_info_list.argtypes = [POINTER(pa_context), pa_source_output_info_cb_t, c_void_p]
pa_context_move_source_output_by_name = _libraries['libpulse.so.0'].pa_context_move_source_output_by_name
pa_context_move_source_output_by_name.restype = POINTER(pa_operation)
pa_context_move_source_output_by_name.argtypes = [POINTER(pa_context), uint32_t, STRING, pa_context_success_cb_t, c_void_p]
pa_context_move_source_output_by_index = _libraries['libpulse.so.0'].pa_context_move_source_output_by_index
pa_context_move_source_output_by_index.restype = POINTER(pa_operation)
pa_context_move_source_output_by_index.argtypes = [POINTER(pa_context), uint32_t, uint32_t, pa_context_success_cb_t, c_void_p]
pa_context_set_source_output_volume = _libraries['libpulse.so.0'].pa_context_set_source_output_volume
pa_context_set_source_output_volume.restype = POINTER(pa_operation)
pa_context_set_source_output_volume.argtypes = [POINTER(pa_context), uint32_t, POINTER(pa_cvolume), pa_context_success_cb_t, c_void_p]
pa_context_set_source_output_mute = _libraries['libpulse.so.0'].pa_context_set_source_output_mute
pa_context_set_source_output_mute.restype = POINTER(pa_operation)
pa_context_set_source_output_mute.argtypes = [POINTER(pa_context), uint32_t, c_int, pa_context_success_cb_t, c_void_p]
pa_context_kill_source_output = _libraries['libpulse.so.0'].pa_context_kill_source_output
pa_context_kill_source_output.restype = POINTER(pa_operation)
pa_context_kill_source_output.argtypes = [POINTER(pa_context), uint32_t, pa_context_success_cb_t, c_void_p]
class pa_stat_info(Structure):
    pass
pa_stat_info._fields_ = [
    ('memblock_total', uint32_t),
    ('memblock_total_size', uint32_t),
    ('memblock_allocated', uint32_t),
    ('memblock_allocated_size', uint32_t),
    ('scache_size', uint32_t),
]
pa_stat_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_stat_info), c_void_p)
pa_context_stat = _libraries['libpulse.so.0'].pa_context_stat
pa_context_stat.restype = POINTER(pa_operation)
pa_context_stat.argtypes = [POINTER(pa_context), pa_stat_info_cb_t, c_void_p]
class pa_sample_info(Structure):
    pass
pa_sample_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('volume', pa_cvolume),
    ('sample_spec', pa_sample_spec),
    ('channel_map', pa_channel_map),
    ('duration', pa_usec_t),
    ('bytes', uint32_t),
    ('lazy', c_int),
    ('filename', STRING),
    ('proplist', POINTER(pa_proplist)),
]
pa_sample_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_sample_info), c_int, c_void_p)
pa_context_get_sample_info_by_name = _libraries['libpulse.so.0'].pa_context_get_sample_info_by_name
pa_context_get_sample_info_by_name.restype = POINTER(pa_operation)
pa_context_get_sample_info_by_name.argtypes = [POINTER(pa_context), STRING, pa_sample_info_cb_t, c_void_p]
pa_context_get_sample_info_by_index = _libraries['libpulse.so.0'].pa_context_get_sample_info_by_index
pa_context_get_sample_info_by_index.restype = POINTER(pa_operation)
pa_context_get_sample_info_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_sample_info_cb_t, c_void_p]
pa_context_get_sample_info_list = _libraries['libpulse.so.0'].pa_context_get_sample_info_list
pa_context_get_sample_info_list.restype = POINTER(pa_operation)
pa_context_get_sample_info_list.argtypes = [POINTER(pa_context), pa_sample_info_cb_t, c_void_p]

# values for enumeration 'pa_autoload_type'
pa_autoload_type = c_int # enum
pa_autoload_type_t = pa_autoload_type
class pa_autoload_info(Structure):
    pass
pa_autoload_info._fields_ = [
    ('index', uint32_t),
    ('name', STRING),
    ('type', pa_autoload_type_t),
    ('module', STRING),
    ('argument', STRING),
]
pa_autoload_info_cb_t = CFUNCTYPE(None, POINTER(pa_context), POINTER(pa_autoload_info), c_int, c_void_p)
pa_context_get_autoload_info_by_name = _libraries['libpulse.so.0'].pa_context_get_autoload_info_by_name
pa_context_get_autoload_info_by_name.restype = POINTER(pa_operation)
pa_context_get_autoload_info_by_name.argtypes = [POINTER(pa_context), STRING, pa_autoload_type_t, pa_autoload_info_cb_t, c_void_p]
pa_context_get_autoload_info_by_index = _libraries['libpulse.so.0'].pa_context_get_autoload_info_by_index
pa_context_get_autoload_info_by_index.restype = POINTER(pa_operation)
pa_context_get_autoload_info_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_autoload_info_cb_t, c_void_p]
pa_context_get_autoload_info_list = _libraries['libpulse.so.0'].pa_context_get_autoload_info_list
pa_context_get_autoload_info_list.restype = POINTER(pa_operation)
pa_context_get_autoload_info_list.argtypes = [POINTER(pa_context), pa_autoload_info_cb_t, c_void_p]
pa_context_add_autoload = _libraries['libpulse.so.0'].pa_context_add_autoload
pa_context_add_autoload.restype = POINTER(pa_operation)
pa_context_add_autoload.argtypes = [POINTER(pa_context), STRING, pa_autoload_type_t, STRING, STRING, pa_context_index_cb_t, c_void_p]
pa_context_remove_autoload_by_name = _libraries['libpulse.so.0'].pa_context_remove_autoload_by_name
pa_context_remove_autoload_by_name.restype = POINTER(pa_operation)
pa_context_remove_autoload_by_name.argtypes = [POINTER(pa_context), STRING, pa_autoload_type_t, pa_context_success_cb_t, c_void_p]
pa_context_remove_autoload_by_index = _libraries['libpulse.so.0'].pa_context_remove_autoload_by_index
pa_context_remove_autoload_by_index.restype = POINTER(pa_operation)
pa_context_remove_autoload_by_index.argtypes = [POINTER(pa_context), uint32_t, pa_context_success_cb_t, c_void_p]

# values for enumeration 'pa_io_event_flags'
pa_io_event_flags = c_int # enum
pa_io_event_flags_t = pa_io_event_flags
class pa_io_event(Structure):
    pass
pa_io_event._fields_ = [
]
pa_io_event_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_io_event), c_int, pa_io_event_flags_t, c_void_p)
pa_io_event_destroy_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_io_event), c_void_p)
pa_time_event._fields_ = [
]
pa_time_event_destroy_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_time_event), c_void_p)
class pa_defer_event(Structure):
    pass
pa_defer_event._fields_ = [
]
pa_defer_event_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_defer_event), c_void_p)
pa_defer_event_destroy_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_defer_event), c_void_p)
pa_mainloop_api._fields_ = [
    ('userdata', c_void_p),
    ('io_new', CFUNCTYPE(POINTER(pa_io_event), POINTER(pa_mainloop_api), c_int, pa_io_event_flags_t, pa_io_event_cb_t, c_void_p)),
    ('io_enable', CFUNCTYPE(None, POINTER(pa_io_event), pa_io_event_flags_t)),
    ('io_free', CFUNCTYPE(None, POINTER(pa_io_event))),
    ('io_set_destroy', CFUNCTYPE(None, POINTER(pa_io_event), pa_io_event_destroy_cb_t)),
    ('time_new', CFUNCTYPE(POINTER(pa_time_event), POINTER(pa_mainloop_api), POINTER(timeval), pa_time_event_cb_t, c_void_p)),
    ('time_restart', CFUNCTYPE(None, POINTER(pa_time_event), POINTER(timeval))),
    ('time_free', CFUNCTYPE(None, POINTER(pa_time_event))),
    ('time_set_destroy', CFUNCTYPE(None, POINTER(pa_time_event), pa_time_event_destroy_cb_t)),
    ('defer_new', CFUNCTYPE(POINTER(pa_defer_event), POINTER(pa_mainloop_api), pa_defer_event_cb_t, c_void_p)),
    ('defer_enable', CFUNCTYPE(None, POINTER(pa_defer_event), c_int)),
    ('defer_free', CFUNCTYPE(None, POINTER(pa_defer_event))),
    ('defer_set_destroy', CFUNCTYPE(None, POINTER(pa_defer_event), pa_defer_event_destroy_cb_t)),
    ('quit', CFUNCTYPE(None, POINTER(pa_mainloop_api), c_int)),
]
pa_mainloop_api_once = _libraries['libpulse.so.0'].pa_mainloop_api_once
pa_mainloop_api_once.restype = None
pa_mainloop_api_once.argtypes = [POINTER(pa_mainloop_api), CFUNCTYPE(None, POINTER(pa_mainloop_api), c_void_p), c_void_p]
class pa_signal_event(Structure):
    pass
pa_signal_event._fields_ = [
]
pa_signal_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_signal_event), c_int, c_void_p)
pa_signal_destroy_cb_t = CFUNCTYPE(None, POINTER(pa_mainloop_api), POINTER(pa_signal_event), c_void_p)
pa_signal_init = _libraries['libpulse.so.0'].pa_signal_init
pa_signal_init.restype = c_int
pa_signal_init.argtypes = [POINTER(pa_mainloop_api)]
pa_signal_done = _libraries['libpulse.so.0'].pa_signal_done
pa_signal_done.restype = None
pa_signal_done.argtypes = []
pa_signal_new = _libraries['libpulse.so.0'].pa_signal_new
pa_signal_new.restype = POINTER(pa_signal_event)
pa_signal_new.argtypes = [c_int, pa_signal_cb_t, c_void_p]
pa_signal_free = _libraries['libpulse.so.0'].pa_signal_free
pa_signal_free.restype = None
pa_signal_free.argtypes = [POINTER(pa_signal_event)]
pa_signal_set_destroy = _libraries['libpulse.so.0'].pa_signal_set_destroy
pa_signal_set_destroy.restype = None
pa_signal_set_destroy.argtypes = [POINTER(pa_signal_event), pa_signal_destroy_cb_t]
class pa_mainloop(Structure):
    pass
pa_mainloop._fields_ = [
]
pa_mainloop_new = _libraries['libpulse.so.0'].pa_mainloop_new
pa_mainloop_new.restype = POINTER(pa_mainloop)
pa_mainloop_new.argtypes = []
pa_mainloop_free = _libraries['libpulse.so.0'].pa_mainloop_free
pa_mainloop_free.restype = None
pa_mainloop_free.argtypes = [POINTER(pa_mainloop)]
pa_mainloop_prepare = _libraries['libpulse.so.0'].pa_mainloop_prepare
pa_mainloop_prepare.restype = c_int
pa_mainloop_prepare.argtypes = [POINTER(pa_mainloop), c_int]
pa_mainloop_poll = _libraries['libpulse.so.0'].pa_mainloop_poll
pa_mainloop_poll.restype = c_int
pa_mainloop_poll.argtypes = [POINTER(pa_mainloop)]
pa_mainloop_dispatch = _libraries['libpulse.so.0'].pa_mainloop_dispatch
pa_mainloop_dispatch.restype = c_int
pa_mainloop_dispatch.argtypes = [POINTER(pa_mainloop)]
pa_mainloop_get_retval = _libraries['libpulse.so.0'].pa_mainloop_get_retval
pa_mainloop_get_retval.restype = c_int
pa_mainloop_get_retval.argtypes = [POINTER(pa_mainloop)]
pa_mainloop_iterate = _libraries['libpulse.so.0'].pa_mainloop_iterate
pa_mainloop_iterate.restype = c_int
pa_mainloop_iterate.argtypes = [POINTER(pa_mainloop), c_int, POINTER(c_int)]
pa_mainloop_run = _libraries['libpulse.so.0'].pa_mainloop_run
pa_mainloop_run.restype = c_int
pa_mainloop_run.argtypes = [POINTER(pa_mainloop), POINTER(c_int)]
pa_mainloop_get_api = _libraries['libpulse.so.0'].pa_mainloop_get_api
pa_mainloop_get_api.restype = POINTER(pa_mainloop_api)
pa_mainloop_get_api.argtypes = [POINTER(pa_mainloop)]
pa_mainloop_quit = _libraries['libpulse.so.0'].pa_mainloop_quit
pa_mainloop_quit.restype = None
pa_mainloop_quit.argtypes = [POINTER(pa_mainloop), c_int]
pa_mainloop_wakeup = _libraries['libpulse.so.0'].pa_mainloop_wakeup
pa_mainloop_wakeup.restype = None
pa_mainloop_wakeup.argtypes = [POINTER(pa_mainloop)]
class pollfd(Structure):
    pass
pa_poll_func = CFUNCTYPE(c_int, POINTER(pollfd), c_ulong, c_int, c_void_p)
pa_mainloop_set_poll_func = _libraries['libpulse.so.0'].pa_mainloop_set_poll_func
pa_mainloop_set_poll_func.restype = None
pa_mainloop_set_poll_func.argtypes = [POINTER(pa_mainloop), pa_poll_func, c_void_p]
pa_operation._fields_ = [
]
pa_operation_ref = _libraries['libpulse.so.0'].pa_operation_ref
pa_operation_ref.restype = POINTER(pa_operation)
pa_operation_ref.argtypes = [POINTER(pa_operation)]
pa_operation_unref = _libraries['libpulse.so.0'].pa_operation_unref
pa_operation_unref.restype = None
pa_operation_unref.argtypes = [POINTER(pa_operation)]
pa_operation_cancel = _libraries['libpulse.so.0'].pa_operation_cancel
pa_operation_cancel.restype = None
pa_operation_cancel.argtypes = [POINTER(pa_operation)]
pa_operation_get_state = _libraries['libpulse.so.0'].pa_operation_get_state
pa_operation_get_state.restype = pa_operation_state_t
pa_operation_get_state.argtypes = [POINTER(pa_operation)]
pa_proplist._fields_ = [
]
pa_proplist_new = _libraries['libpulse.so.0'].pa_proplist_new
pa_proplist_new.restype = POINTER(pa_proplist)
pa_proplist_new.argtypes = []
pa_proplist_free = _libraries['libpulse.so.0'].pa_proplist_free
pa_proplist_free.restype = None
pa_proplist_free.argtypes = [POINTER(pa_proplist)]
pa_proplist_sets = _libraries['libpulse.so.0'].pa_proplist_sets
pa_proplist_sets.restype = c_int
pa_proplist_sets.argtypes = [POINTER(pa_proplist), STRING, STRING]
pa_proplist_setp = _libraries['libpulse.so.0'].pa_proplist_setp
pa_proplist_setp.restype = c_int
pa_proplist_setp.argtypes = [POINTER(pa_proplist), STRING]
pa_proplist_setf = _libraries['libpulse.so.0'].pa_proplist_setf
pa_proplist_setf.restype = c_int
pa_proplist_setf.argtypes = [POINTER(pa_proplist), STRING, STRING]
pa_proplist_set = _libraries['libpulse.so.0'].pa_proplist_set
pa_proplist_set.restype = c_int
pa_proplist_set.argtypes = [POINTER(pa_proplist), STRING, c_void_p, size_t]
pa_proplist_gets = _libraries['libpulse.so.0'].pa_proplist_gets
pa_proplist_gets.restype = STRING
pa_proplist_gets.argtypes = [POINTER(pa_proplist), STRING]
pa_proplist_get = _libraries['libpulse.so.0'].pa_proplist_get
pa_proplist_get.restype = c_int
pa_proplist_get.argtypes = [POINTER(pa_proplist), STRING, POINTER(c_void_p), POINTER(size_t)]
pa_proplist_update = _libraries['libpulse.so.0'].pa_proplist_update
pa_proplist_update.restype = None
pa_proplist_update.argtypes = [POINTER(pa_proplist), pa_update_mode_t, POINTER(pa_proplist)]
pa_proplist_unset = _libraries['libpulse.so.0'].pa_proplist_unset
pa_proplist_unset.restype = c_int
pa_proplist_unset.argtypes = [POINTER(pa_proplist), STRING]
pa_proplist_unset_many = _libraries['libpulse.so.0'].pa_proplist_unset_many
pa_proplist_unset_many.restype = c_int
pa_proplist_unset_many.argtypes = [POINTER(pa_proplist), POINTER(STRING)]
pa_proplist_iterate = _libraries['libpulse.so.0'].pa_proplist_iterate
pa_proplist_iterate.restype = STRING
pa_proplist_iterate.argtypes = [POINTER(pa_proplist), POINTER(c_void_p)]
pa_proplist_to_string = _libraries['libpulse.so.0'].pa_proplist_to_string
pa_proplist_to_string.restype = STRING
pa_proplist_to_string.argtypes = [POINTER(pa_proplist)]
pa_proplist_to_string_sep = _libraries['libpulse.so.0'].pa_proplist_to_string_sep
pa_proplist_to_string_sep.restype = STRING
pa_proplist_to_string_sep.argtypes = [POINTER(pa_proplist), STRING]
pa_proplist_from_string = _libraries['libpulse.so.0'].pa_proplist_from_string
pa_proplist_from_string.restype = POINTER(pa_proplist)
pa_proplist_from_string.argtypes = [STRING]
pa_proplist_contains = _libraries['libpulse.so.0'].pa_proplist_contains
pa_proplist_contains.restype = c_int
pa_proplist_contains.argtypes = [POINTER(pa_proplist), STRING]
pa_proplist_clear = _libraries['libpulse.so.0'].pa_proplist_clear
pa_proplist_clear.restype = None
pa_proplist_clear.argtypes = [POINTER(pa_proplist)]
pa_proplist_copy = _libraries['libpulse.so.0'].pa_proplist_copy
pa_proplist_copy.restype = POINTER(pa_proplist)
pa_proplist_copy.argtypes = [POINTER(pa_proplist)]
pa_proplist_size = _libraries['libpulse.so.0'].pa_proplist_size
pa_proplist_size.restype = c_uint
pa_proplist_size.argtypes = [POINTER(pa_proplist)]
pa_proplist_isempty = _libraries['libpulse.so.0'].pa_proplist_isempty
pa_proplist_isempty.restype = c_int
pa_proplist_isempty.argtypes = [POINTER(pa_proplist)]
pa_proplist_equal = _libraries['libpulse.so.0'].pa_proplist_equal
pa_proplist_equal.restype = c_int
pa_proplist_equal.argtypes = [POINTER(pa_proplist), POINTER(pa_proplist)]
pa_bytes_per_second = _libraries['libpulse.so.0'].pa_bytes_per_second
pa_bytes_per_second.restype = size_t
pa_bytes_per_second.argtypes = [POINTER(pa_sample_spec)]
pa_frame_size = _libraries['libpulse.so.0'].pa_frame_size
pa_frame_size.restype = size_t
pa_frame_size.argtypes = [POINTER(pa_sample_spec)]
pa_sample_size = _libraries['libpulse.so.0'].pa_sample_size
pa_sample_size.restype = size_t
pa_sample_size.argtypes = [POINTER(pa_sample_spec)]
pa_sample_size_of_format = _libraries['libpulse.so.0'].pa_sample_size_of_format
pa_sample_size_of_format.restype = size_t
pa_sample_size_of_format.argtypes = [pa_sample_format_t]
pa_bytes_to_usec = _libraries['libpulse.so.0'].pa_bytes_to_usec
pa_bytes_to_usec.restype = pa_usec_t
pa_bytes_to_usec.argtypes = [uint64_t, POINTER(pa_sample_spec)]
pa_usec_to_bytes = _libraries['libpulse.so.0'].pa_usec_to_bytes
pa_usec_to_bytes.restype = size_t
pa_usec_to_bytes.argtypes = [pa_usec_t, POINTER(pa_sample_spec)]
pa_sample_spec_init = _libraries['libpulse.so.0'].pa_sample_spec_init
pa_sample_spec_init.restype = POINTER(pa_sample_spec)
pa_sample_spec_init.argtypes = [POINTER(pa_sample_spec)]
pa_sample_spec_valid = _libraries['libpulse.so.0'].pa_sample_spec_valid
pa_sample_spec_valid.restype = c_int
pa_sample_spec_valid.argtypes = [POINTER(pa_sample_spec)]
pa_sample_spec_equal = _libraries['libpulse.so.0'].pa_sample_spec_equal
pa_sample_spec_equal.restype = c_int
pa_sample_spec_equal.argtypes = [POINTER(pa_sample_spec), POINTER(pa_sample_spec)]
pa_sample_format_to_string = _libraries['libpulse.so.0'].pa_sample_format_to_string
pa_sample_format_to_string.restype = STRING
pa_sample_format_to_string.argtypes = [pa_sample_format_t]
pa_parse_sample_format = _libraries['libpulse.so.0'].pa_parse_sample_format
pa_parse_sample_format.restype = pa_sample_format_t
pa_parse_sample_format.argtypes = [STRING]
pa_sample_spec_snprint = _libraries['libpulse.so.0'].pa_sample_spec_snprint
pa_sample_spec_snprint.restype = STRING
pa_sample_spec_snprint.argtypes = [STRING, size_t, POINTER(pa_sample_spec)]
pa_bytes_snprint = _libraries['libpulse.so.0'].pa_bytes_snprint
pa_bytes_snprint.restype = STRING
pa_bytes_snprint.argtypes = [STRING, size_t, c_uint]
pa_sample_format_is_le = _libraries['libpulse.so.0'].pa_sample_format_is_le
pa_sample_format_is_le.restype = c_int
pa_sample_format_is_le.argtypes = [pa_sample_format_t]
pa_sample_format_is_be = _libraries['libpulse.so.0'].pa_sample_format_is_be
pa_sample_format_is_be.restype = c_int
pa_sample_format_is_be.argtypes = [pa_sample_format_t]
pa_context_play_sample_cb_t = CFUNCTYPE(None, POINTER(pa_context), uint32_t, c_void_p)
class pa_stream(Structure):
    pass
pa_stream_connect_upload = _libraries['libpulse.so.0'].pa_stream_connect_upload
pa_stream_connect_upload.restype = c_int
pa_stream_connect_upload.argtypes = [POINTER(pa_stream), size_t]
pa_stream_finish_upload = _libraries['libpulse.so.0'].pa_stream_finish_upload
pa_stream_finish_upload.restype = c_int
pa_stream_finish_upload.argtypes = [POINTER(pa_stream)]
pa_context_remove_sample = _libraries['libpulse.so.0'].pa_context_remove_sample
pa_context_remove_sample.restype = POINTER(pa_operation)
pa_context_remove_sample.argtypes = [POINTER(pa_context), STRING, pa_context_success_cb_t, c_void_p]
pa_context_play_sample = _libraries['libpulse.so.0'].pa_context_play_sample
pa_context_play_sample.restype = POINTER(pa_operation)
pa_context_play_sample.argtypes = [POINTER(pa_context), STRING, STRING, pa_volume_t, pa_context_success_cb_t, c_void_p]
pa_context_play_sample_with_proplist = _libraries['libpulse.so.0'].pa_context_play_sample_with_proplist
pa_context_play_sample_with_proplist.restype = POINTER(pa_operation)
pa_context_play_sample_with_proplist.argtypes = [POINTER(pa_context), STRING, STRING, pa_volume_t, POINTER(pa_proplist), pa_context_play_sample_cb_t, c_void_p]
pa_stream._fields_ = [
]
pa_stream_success_cb_t = CFUNCTYPE(None, POINTER(pa_stream), c_int, c_void_p)
pa_stream_request_cb_t = CFUNCTYPE(None, POINTER(pa_stream), size_t, c_void_p)
pa_stream_notify_cb_t = CFUNCTYPE(None, POINTER(pa_stream), c_void_p)
pa_stream_event_cb_t = CFUNCTYPE(None, POINTER(pa_stream), STRING, POINTER(pa_proplist), c_void_p)
pa_stream_new = _libraries['libpulse.so.0'].pa_stream_new
pa_stream_new.restype = POINTER(pa_stream)
pa_stream_new.argtypes = [POINTER(pa_context), STRING, POINTER(pa_sample_spec), POINTER(pa_channel_map)]
pa_stream_new_with_proplist = _libraries['libpulse.so.0'].pa_stream_new_with_proplist
pa_stream_new_with_proplist.restype = POINTER(pa_stream)
pa_stream_new_with_proplist.argtypes = [POINTER(pa_context), STRING, POINTER(pa_sample_spec), POINTER(pa_channel_map), POINTER(pa_proplist)]
pa_stream_new_extended = _libraries['libpulse.so.0'].pa_stream_new_extended
pa_stream_new_extended.restype = POINTER(pa_stream)
pa_stream_new_extended.argtypes = [POINTER(pa_context), STRING, POINTER(POINTER(pa_format_info)), c_uint, POINTER(pa_proplist)]
pa_stream_unref = _libraries['libpulse.so.0'].pa_stream_unref
pa_stream_unref.restype = None
pa_stream_unref.argtypes = [POINTER(pa_stream)]
pa_stream_ref = _libraries['libpulse.so.0'].pa_stream_ref
pa_stream_ref.restype = POINTER(pa_stream)
pa_stream_ref.argtypes = [POINTER(pa_stream)]
pa_stream_get_state = _libraries['libpulse.so.0'].pa_stream_get_state
pa_stream_get_state.restype = pa_stream_state_t
pa_stream_get_state.argtypes = [POINTER(pa_stream)]
pa_stream_get_context = _libraries['libpulse.so.0'].pa_stream_get_context
pa_stream_get_context.restype = POINTER(pa_context)
pa_stream_get_context.argtypes = [POINTER(pa_stream)]
pa_stream_get_index = _libraries['libpulse.so.0'].pa_stream_get_index
pa_stream_get_index.restype = uint32_t
pa_stream_get_index.argtypes = [POINTER(pa_stream)]
pa_stream_get_device_index = _libraries['libpulse.so.0'].pa_stream_get_device_index
pa_stream_get_device_index.restype = uint32_t
pa_stream_get_device_index.argtypes = [POINTER(pa_stream)]
pa_stream_get_device_name = _libraries['libpulse.so.0'].pa_stream_get_device_name
pa_stream_get_device_name.restype = STRING
pa_stream_get_device_name.argtypes = [POINTER(pa_stream)]
pa_stream_is_suspended = _libraries['libpulse.so.0'].pa_stream_is_suspended
pa_stream_is_suspended.restype = c_int
pa_stream_is_suspended.argtypes = [POINTER(pa_stream)]
pa_stream_is_corked = _libraries['libpulse.so.0'].pa_stream_is_corked
pa_stream_is_corked.restype = c_int
pa_stream_is_corked.argtypes = [POINTER(pa_stream)]
pa_stream_connect_playback = _libraries['libpulse.so.0'].pa_stream_connect_playback
pa_stream_connect_playback.restype = c_int
pa_stream_connect_playback.argtypes = [POINTER(pa_stream), STRING, POINTER(pa_buffer_attr), pa_stream_flags_t, POINTER(pa_cvolume), POINTER(pa_stream)]
pa_stream_connect_record = _libraries['libpulse.so.0'].pa_stream_connect_record
pa_stream_connect_record.restype = c_int
pa_stream_connect_record.argtypes = [POINTER(pa_stream), STRING, POINTER(pa_buffer_attr), pa_stream_flags_t]
pa_stream_disconnect = _libraries['libpulse.so.0'].pa_stream_disconnect
pa_stream_disconnect.restype = c_int
pa_stream_disconnect.argtypes = [POINTER(pa_stream)]
pa_stream_begin_write = _libraries['libpulse.so.0'].pa_stream_begin_write
pa_stream_begin_write.restype = c_int
pa_stream_begin_write.argtypes = [POINTER(pa_stream), POINTER(c_void_p), POINTER(size_t)]
pa_stream_cancel_write = _libraries['libpulse.so.0'].pa_stream_cancel_write
pa_stream_cancel_write.restype = c_int
pa_stream_cancel_write.argtypes = [POINTER(pa_stream)]
pa_stream_write = _libraries['libpulse.so.0'].pa_stream_write
pa_stream_write.restype = c_int
pa_stream_write.argtypes = [POINTER(pa_stream), c_void_p, size_t, pa_free_cb_t, int64_t, pa_seek_mode_t]
pa_stream_peek = _libraries['libpulse.so.0'].pa_stream_peek
pa_stream_peek.restype = c_int
pa_stream_peek.argtypes = [POINTER(pa_stream), POINTER(c_void_p), POINTER(size_t)]
pa_stream_drop = _libraries['libpulse.so.0'].pa_stream_drop
pa_stream_drop.restype = c_int
pa_stream_drop.argtypes = [POINTER(pa_stream)]
pa_stream_writable_size = _libraries['libpulse.so.0'].pa_stream_writable_size
pa_stream_writable_size.restype = size_t
pa_stream_writable_size.argtypes = [POINTER(pa_stream)]
pa_stream_readable_size = _libraries['libpulse.so.0'].pa_stream_readable_size
pa_stream_readable_size.restype = size_t
pa_stream_readable_size.argtypes = [POINTER(pa_stream)]
pa_stream_drain = _libraries['libpulse.so.0'].pa_stream_drain
pa_stream_drain.restype = POINTER(pa_operation)
pa_stream_drain.argtypes = [POINTER(pa_stream), pa_stream_success_cb_t, c_void_p]
pa_stream_update_timing_info = _libraries['libpulse.so.0'].pa_stream_update_timing_info
pa_stream_update_timing_info.restype = POINTER(pa_operation)
pa_stream_update_timing_info.argtypes = [POINTER(pa_stream), pa_stream_success_cb_t, c_void_p]
pa_stream_set_state_callback = _libraries['libpulse.so.0'].pa_stream_set_state_callback
pa_stream_set_state_callback.restype = None
pa_stream_set_state_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_write_callback = _libraries['libpulse.so.0'].pa_stream_set_write_callback
pa_stream_set_write_callback.restype = None
pa_stream_set_write_callback.argtypes = [POINTER(pa_stream), pa_stream_request_cb_t, c_void_p]
pa_stream_set_read_callback = _libraries['libpulse.so.0'].pa_stream_set_read_callback
pa_stream_set_read_callback.restype = None
pa_stream_set_read_callback.argtypes = [POINTER(pa_stream), pa_stream_request_cb_t, c_void_p]
pa_stream_set_overflow_callback = _libraries['libpulse.so.0'].pa_stream_set_overflow_callback
pa_stream_set_overflow_callback.restype = None
pa_stream_set_overflow_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_get_underflow_index = _libraries['libpulse.so.0'].pa_stream_get_underflow_index
pa_stream_get_underflow_index.restype = int64_t
pa_stream_get_underflow_index.argtypes = [POINTER(pa_stream)]
pa_stream_set_underflow_callback = _libraries['libpulse.so.0'].pa_stream_set_underflow_callback
pa_stream_set_underflow_callback.restype = None
pa_stream_set_underflow_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_started_callback = _libraries['libpulse.so.0'].pa_stream_set_started_callback
pa_stream_set_started_callback.restype = None
pa_stream_set_started_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_latency_update_callback = _libraries['libpulse.so.0'].pa_stream_set_latency_update_callback
pa_stream_set_latency_update_callback.restype = None
pa_stream_set_latency_update_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_moved_callback = _libraries['libpulse.so.0'].pa_stream_set_moved_callback
pa_stream_set_moved_callback.restype = None
pa_stream_set_moved_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_suspended_callback = _libraries['libpulse.so.0'].pa_stream_set_suspended_callback
pa_stream_set_suspended_callback.restype = None
pa_stream_set_suspended_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_set_event_callback = _libraries['libpulse.so.0'].pa_stream_set_event_callback
pa_stream_set_event_callback.restype = None
pa_stream_set_event_callback.argtypes = [POINTER(pa_stream), pa_stream_event_cb_t, c_void_p]
pa_stream_set_buffer_attr_callback = _libraries['libpulse.so.0'].pa_stream_set_buffer_attr_callback
pa_stream_set_buffer_attr_callback.restype = None
pa_stream_set_buffer_attr_callback.argtypes = [POINTER(pa_stream), pa_stream_notify_cb_t, c_void_p]
pa_stream_cork = _libraries['libpulse.so.0'].pa_stream_cork
pa_stream_cork.restype = POINTER(pa_operation)
pa_stream_cork.argtypes = [POINTER(pa_stream), c_int, pa_stream_success_cb_t, c_void_p]
pa_stream_flush = _libraries['libpulse.so.0'].pa_stream_flush
pa_stream_flush.restype = POINTER(pa_operation)
pa_stream_flush.argtypes = [POINTER(pa_stream), pa_stream_success_cb_t, c_void_p]
pa_stream_prebuf = _libraries['libpulse.so.0'].pa_stream_prebuf
pa_stream_prebuf.restype = POINTER(pa_operation)
pa_stream_prebuf.argtypes = [POINTER(pa_stream), pa_stream_success_cb_t, c_void_p]
pa_stream_trigger = _libraries['libpulse.so.0'].pa_stream_trigger
pa_stream_trigger.restype = POINTER(pa_operation)
pa_stream_trigger.argtypes = [POINTER(pa_stream), pa_stream_success_cb_t, c_void_p]
pa_stream_set_name = _libraries['libpulse.so.0'].pa_stream_set_name
pa_stream_set_name.restype = POINTER(pa_operation)
pa_stream_set_name.argtypes = [POINTER(pa_stream), STRING, pa_stream_success_cb_t, c_void_p]
pa_stream_get_time = _libraries['libpulse.so.0'].pa_stream_get_time
pa_stream_get_time.restype = c_int
pa_stream_get_time.argtypes = [POINTER(pa_stream), POINTER(pa_usec_t)]
pa_stream_get_latency = _libraries['libpulse.so.0'].pa_stream_get_latency
pa_stream_get_latency.restype = c_int
pa_stream_get_latency.argtypes = [POINTER(pa_stream), POINTER(pa_usec_t), POINTER(c_int)]
pa_stream_get_timing_info = _libraries['libpulse.so.0'].pa_stream_get_timing_info
pa_stream_get_timing_info.restype = POINTER(pa_timing_info)
pa_stream_get_timing_info.argtypes = [POINTER(pa_stream)]
pa_stream_get_sample_spec = _libraries['libpulse.so.0'].pa_stream_get_sample_spec
pa_stream_get_sample_spec.restype = POINTER(pa_sample_spec)
pa_stream_get_sample_spec.argtypes = [POINTER(pa_stream)]
pa_stream_get_channel_map = _libraries['libpulse.so.0'].pa_stream_get_channel_map
pa_stream_get_channel_map.restype = POINTER(pa_channel_map)
pa_stream_get_channel_map.argtypes = [POINTER(pa_stream)]
pa_stream_get_format_info = _libraries['libpulse.so.0'].pa_stream_get_format_info
pa_stream_get_format_info.restype = POINTER(pa_format_info)
pa_stream_get_format_info.argtypes = [POINTER(pa_stream)]
pa_stream_get_buffer_attr = _libraries['libpulse.so.0'].pa_stream_get_buffer_attr
pa_stream_get_buffer_attr.restype = POINTER(pa_buffer_attr)
pa_stream_get_buffer_attr.argtypes = [POINTER(pa_stream)]
pa_stream_set_buffer_attr = _libraries['libpulse.so.0'].pa_stream_set_buffer_attr
pa_stream_set_buffer_attr.restype = POINTER(pa_operation)
pa_stream_set_buffer_attr.argtypes = [POINTER(pa_stream), POINTER(pa_buffer_attr), pa_stream_success_cb_t, c_void_p]
pa_stream_update_sample_rate = _libraries['libpulse.so.0'].pa_stream_update_sample_rate
pa_stream_update_sample_rate.restype = POINTER(pa_operation)
pa_stream_update_sample_rate.argtypes = [POINTER(pa_stream), uint32_t, pa_stream_success_cb_t, c_void_p]
pa_stream_proplist_update = _libraries['libpulse.so.0'].pa_stream_proplist_update
pa_stream_proplist_update.restype = POINTER(pa_operation)
pa_stream_proplist_update.argtypes = [POINTER(pa_stream), pa_update_mode_t, POINTER(pa_proplist), pa_stream_success_cb_t, c_void_p]
pa_stream_proplist_remove = _libraries['libpulse.so.0'].pa_stream_proplist_remove
pa_stream_proplist_remove.restype = POINTER(pa_operation)
pa_stream_proplist_remove.argtypes = [POINTER(pa_stream), POINTER(STRING), pa_stream_success_cb_t, c_void_p]
pa_stream_set_monitor_stream = _libraries['libpulse.so.0'].pa_stream_set_monitor_stream
pa_stream_set_monitor_stream.restype = c_int
pa_stream_set_monitor_stream.argtypes = [POINTER(pa_stream), uint32_t]
pa_stream_get_monitor_stream = _libraries['libpulse.so.0'].pa_stream_get_monitor_stream
pa_stream_get_monitor_stream.restype = uint32_t
pa_stream_get_monitor_stream.argtypes = [POINTER(pa_stream)]
pa_context_subscribe_cb_t = CFUNCTYPE(None, POINTER(pa_context), pa_subscription_event_type_t, uint32_t, c_void_p)
pa_context_subscribe = _libraries['libpulse.so.0'].pa_context_subscribe
pa_context_subscribe.restype = POINTER(pa_operation)
pa_context_subscribe.argtypes = [POINTER(pa_context), pa_subscription_mask_t, pa_context_success_cb_t, c_void_p]
pa_context_set_subscribe_callback = _libraries['libpulse.so.0'].pa_context_set_subscribe_callback
pa_context_set_subscribe_callback.restype = None
pa_context_set_subscribe_callback.argtypes = [POINTER(pa_context), pa_context_subscribe_cb_t, c_void_p]
class pa_threaded_mainloop(Structure):
    pass
pa_threaded_mainloop._fields_ = [
]
pa_threaded_mainloop_new = _libraries['libpulse.so.0'].pa_threaded_mainloop_new
pa_threaded_mainloop_new.restype = POINTER(pa_threaded_mainloop)
pa_threaded_mainloop_new.argtypes = []
pa_threaded_mainloop_free = _libraries['libpulse.so.0'].pa_threaded_mainloop_free
pa_threaded_mainloop_free.restype = None
pa_threaded_mainloop_free.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_start = _libraries['libpulse.so.0'].pa_threaded_mainloop_start
pa_threaded_mainloop_start.restype = c_int
pa_threaded_mainloop_start.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_stop = _libraries['libpulse.so.0'].pa_threaded_mainloop_stop
pa_threaded_mainloop_stop.restype = None
pa_threaded_mainloop_stop.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_lock = _libraries['libpulse.so.0'].pa_threaded_mainloop_lock
pa_threaded_mainloop_lock.restype = None
pa_threaded_mainloop_lock.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_unlock = _libraries['libpulse.so.0'].pa_threaded_mainloop_unlock
pa_threaded_mainloop_unlock.restype = None
pa_threaded_mainloop_unlock.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_wait = _libraries['libpulse.so.0'].pa_threaded_mainloop_wait
pa_threaded_mainloop_wait.restype = None
pa_threaded_mainloop_wait.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_signal = _libraries['libpulse.so.0'].pa_threaded_mainloop_signal
pa_threaded_mainloop_signal.restype = None
pa_threaded_mainloop_signal.argtypes = [POINTER(pa_threaded_mainloop), c_int]
pa_threaded_mainloop_accept = _libraries['libpulse.so.0'].pa_threaded_mainloop_accept
pa_threaded_mainloop_accept.restype = None
pa_threaded_mainloop_accept.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_get_retval = _libraries['libpulse.so.0'].pa_threaded_mainloop_get_retval
pa_threaded_mainloop_get_retval.restype = c_int
pa_threaded_mainloop_get_retval.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_get_api = _libraries['libpulse.so.0'].pa_threaded_mainloop_get_api
pa_threaded_mainloop_get_api.restype = POINTER(pa_mainloop_api)
pa_threaded_mainloop_get_api.argtypes = [POINTER(pa_threaded_mainloop)]
pa_threaded_mainloop_in_thread = _libraries['libpulse.so.0'].pa_threaded_mainloop_in_thread
pa_threaded_mainloop_in_thread.restype = c_int
pa_threaded_mainloop_in_thread.argtypes = [POINTER(pa_threaded_mainloop)]
pa_gettimeofday = _libraries['libpulse.so.0'].pa_gettimeofday
pa_gettimeofday.restype = POINTER(timeval)
pa_gettimeofday.argtypes = [POINTER(timeval)]
pa_timeval_diff = _libraries['libpulse.so.0'].pa_timeval_diff
pa_timeval_diff.restype = pa_usec_t
pa_timeval_diff.argtypes = [POINTER(timeval), POINTER(timeval)]
pa_timeval_cmp = _libraries['libpulse.so.0'].pa_timeval_cmp
pa_timeval_cmp.restype = c_int
pa_timeval_cmp.argtypes = [POINTER(timeval), POINTER(timeval)]
pa_timeval_age = _libraries['libpulse.so.0'].pa_timeval_age
pa_timeval_age.restype = pa_usec_t
pa_timeval_age.argtypes = [POINTER(timeval)]
pa_timeval_add = _libraries['libpulse.so.0'].pa_timeval_add
pa_timeval_add.restype = POINTER(timeval)
pa_timeval_add.argtypes = [POINTER(timeval), pa_usec_t]
pa_timeval_sub = _libraries['libpulse.so.0'].pa_timeval_sub
pa_timeval_sub.restype = POINTER(timeval)
pa_timeval_sub.argtypes = [POINTER(timeval), pa_usec_t]
pa_timeval_store = _libraries['libpulse.so.0'].pa_timeval_store
pa_timeval_store.restype = POINTER(timeval)
pa_timeval_store.argtypes = [POINTER(timeval), pa_usec_t]
pa_timeval_load = _libraries['libpulse.so.0'].pa_timeval_load
pa_timeval_load.restype = pa_usec_t
pa_timeval_load.argtypes = [POINTER(timeval)]
pa_utf8_valid = _libraries['libpulse.so.0'].pa_utf8_valid
pa_utf8_valid.restype = STRING
pa_utf8_valid.argtypes = [STRING]
pa_ascii_valid = _libraries['libpulse.so.0'].pa_ascii_valid
pa_ascii_valid.restype = STRING
pa_ascii_valid.argtypes = [STRING]
pa_utf8_filter = _libraries['libpulse.so.0'].pa_utf8_filter
pa_utf8_filter.restype = STRING
pa_utf8_filter.argtypes = [STRING]
pa_ascii_filter = _libraries['libpulse.so.0'].pa_ascii_filter
pa_ascii_filter.restype = STRING
pa_ascii_filter.argtypes = [STRING]
pa_utf8_to_locale = _libraries['libpulse.so.0'].pa_utf8_to_locale
pa_utf8_to_locale.restype = STRING
pa_utf8_to_locale.argtypes = [STRING]
pa_locale_to_utf8 = _libraries['libpulse.so.0'].pa_locale_to_utf8
pa_locale_to_utf8.restype = STRING
pa_locale_to_utf8.argtypes = [STRING]
pa_get_user_name = _libraries['libpulse.so.0'].pa_get_user_name
pa_get_user_name.restype = STRING
pa_get_user_name.argtypes = [STRING, size_t]
pa_get_host_name = _libraries['libpulse.so.0'].pa_get_host_name
pa_get_host_name.restype = STRING
pa_get_host_name.argtypes = [STRING, size_t]
pa_get_fqdn = _libraries['libpulse.so.0'].pa_get_fqdn
pa_get_fqdn.restype = STRING
pa_get_fqdn.argtypes = [STRING, size_t]
pa_get_home_dir = _libraries['libpulse.so.0'].pa_get_home_dir
pa_get_home_dir.restype = STRING
pa_get_home_dir.argtypes = [STRING, size_t]
pa_get_binary_name = _libraries['libpulse.so.0'].pa_get_binary_name
pa_get_binary_name.restype = STRING
pa_get_binary_name.argtypes = [STRING, size_t]
pa_path_get_filename = _libraries['libpulse.so.0'].pa_path_get_filename
pa_path_get_filename.restype = STRING
pa_path_get_filename.argtypes = [STRING]
pa_msleep = _libraries['libpulse.so.0'].pa_msleep
pa_msleep.restype = c_int
pa_msleep.argtypes = [c_ulong]
pa_get_library_version = _libraries['libpulse.so.0'].pa_get_library_version
pa_get_library_version.restype = STRING
pa_get_library_version.argtypes = []
pa_cvolume_equal = _libraries['libpulse.so.0'].pa_cvolume_equal
pa_cvolume_equal.restype = c_int
pa_cvolume_equal.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume)]
pa_cvolume_init = _libraries['libpulse.so.0'].pa_cvolume_init
pa_cvolume_init.restype = POINTER(pa_cvolume)
pa_cvolume_init.argtypes = [POINTER(pa_cvolume)]
pa_cvolume_set = _libraries['libpulse.so.0'].pa_cvolume_set
pa_cvolume_set.restype = POINTER(pa_cvolume)
pa_cvolume_set.argtypes = [POINTER(pa_cvolume), c_uint, pa_volume_t]
pa_cvolume_snprint = _libraries['libpulse.so.0'].pa_cvolume_snprint
pa_cvolume_snprint.restype = STRING
pa_cvolume_snprint.argtypes = [STRING, size_t, POINTER(pa_cvolume)]
pa_sw_cvolume_snprint_dB = _libraries['libpulse.so.0'].pa_sw_cvolume_snprint_dB
pa_sw_cvolume_snprint_dB.restype = STRING
pa_sw_cvolume_snprint_dB.argtypes = [STRING, size_t, POINTER(pa_cvolume)]
pa_volume_snprint = _libraries['libpulse.so.0'].pa_volume_snprint
pa_volume_snprint.restype = STRING
pa_volume_snprint.argtypes = [STRING, size_t, pa_volume_t]
pa_sw_volume_snprint_dB = _libraries['libpulse.so.0'].pa_sw_volume_snprint_dB
pa_sw_volume_snprint_dB.restype = STRING
pa_sw_volume_snprint_dB.argtypes = [STRING, size_t, pa_volume_t]
pa_cvolume_avg = _libraries['libpulse.so.0'].pa_cvolume_avg
pa_cvolume_avg.restype = pa_volume_t
pa_cvolume_avg.argtypes = [POINTER(pa_cvolume)]
pa_cvolume_avg_mask = _libraries['libpulse.so.0'].pa_cvolume_avg_mask
pa_cvolume_avg_mask.restype = pa_volume_t
pa_cvolume_avg_mask.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), pa_channel_position_mask_t]
pa_cvolume_max = _libraries['libpulse.so.0'].pa_cvolume_max
pa_cvolume_max.restype = pa_volume_t
pa_cvolume_max.argtypes = [POINTER(pa_cvolume)]
pa_cvolume_max_mask = _libraries['libpulse.so.0'].pa_cvolume_max_mask
pa_cvolume_max_mask.restype = pa_volume_t
pa_cvolume_max_mask.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), pa_channel_position_mask_t]
pa_cvolume_min = _libraries['libpulse.so.0'].pa_cvolume_min
pa_cvolume_min.restype = pa_volume_t
pa_cvolume_min.argtypes = [POINTER(pa_cvolume)]
pa_cvolume_min_mask = _libraries['libpulse.so.0'].pa_cvolume_min_mask
pa_cvolume_min_mask.restype = pa_volume_t
pa_cvolume_min_mask.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), pa_channel_position_mask_t]
pa_cvolume_valid = _libraries['libpulse.so.0'].pa_cvolume_valid
pa_cvolume_valid.restype = c_int
pa_cvolume_valid.argtypes = [POINTER(pa_cvolume)]
pa_cvolume_channels_equal_to = _libraries['libpulse.so.0'].pa_cvolume_channels_equal_to
pa_cvolume_channels_equal_to.restype = c_int
pa_cvolume_channels_equal_to.argtypes = [POINTER(pa_cvolume), pa_volume_t]
pa_sw_volume_multiply = _libraries['libpulse.so.0'].pa_sw_volume_multiply
pa_sw_volume_multiply.restype = pa_volume_t
pa_sw_volume_multiply.argtypes = [pa_volume_t, pa_volume_t]
pa_sw_cvolume_multiply = _libraries['libpulse.so.0'].pa_sw_cvolume_multiply
pa_sw_cvolume_multiply.restype = POINTER(pa_cvolume)
pa_sw_cvolume_multiply.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume), POINTER(pa_cvolume)]
pa_sw_cvolume_multiply_scalar = _libraries['libpulse.so.0'].pa_sw_cvolume_multiply_scalar
pa_sw_cvolume_multiply_scalar.restype = POINTER(pa_cvolume)
pa_sw_cvolume_multiply_scalar.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume), pa_volume_t]
pa_sw_volume_divide = _libraries['libpulse.so.0'].pa_sw_volume_divide
pa_sw_volume_divide.restype = pa_volume_t
pa_sw_volume_divide.argtypes = [pa_volume_t, pa_volume_t]
pa_sw_cvolume_divide = _libraries['libpulse.so.0'].pa_sw_cvolume_divide
pa_sw_cvolume_divide.restype = POINTER(pa_cvolume)
pa_sw_cvolume_divide.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume), POINTER(pa_cvolume)]
pa_sw_cvolume_divide_scalar = _libraries['libpulse.so.0'].pa_sw_cvolume_divide_scalar
pa_sw_cvolume_divide_scalar.restype = POINTER(pa_cvolume)
pa_sw_cvolume_divide_scalar.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume), pa_volume_t]
pa_sw_volume_from_dB = _libraries['libpulse.so.0'].pa_sw_volume_from_dB
pa_sw_volume_from_dB.restype = pa_volume_t
pa_sw_volume_from_dB.argtypes = [c_double]
pa_sw_volume_to_dB = _libraries['libpulse.so.0'].pa_sw_volume_to_dB
pa_sw_volume_to_dB.restype = c_double
pa_sw_volume_to_dB.argtypes = [pa_volume_t]
pa_sw_volume_from_linear = _libraries['libpulse.so.0'].pa_sw_volume_from_linear
pa_sw_volume_from_linear.restype = pa_volume_t
pa_sw_volume_from_linear.argtypes = [c_double]
pa_sw_volume_to_linear = _libraries['libpulse.so.0'].pa_sw_volume_to_linear
pa_sw_volume_to_linear.restype = c_double
pa_sw_volume_to_linear.argtypes = [pa_volume_t]
pa_cvolume_remap = _libraries['libpulse.so.0'].pa_cvolume_remap
pa_cvolume_remap.restype = POINTER(pa_cvolume)
pa_cvolume_remap.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), POINTER(pa_channel_map)]
pa_cvolume_compatible = _libraries['libpulse.so.0'].pa_cvolume_compatible
pa_cvolume_compatible.restype = c_int
pa_cvolume_compatible.argtypes = [POINTER(pa_cvolume), POINTER(pa_sample_spec)]
pa_cvolume_compatible_with_channel_map = _libraries['libpulse.so.0'].pa_cvolume_compatible_with_channel_map
pa_cvolume_compatible_with_channel_map.restype = c_int
pa_cvolume_compatible_with_channel_map.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map)]
pa_cvolume_get_balance = _libraries['libpulse.so.0'].pa_cvolume_get_balance
pa_cvolume_get_balance.restype = c_float
pa_cvolume_get_balance.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map)]
pa_cvolume_set_balance = _libraries['libpulse.so.0'].pa_cvolume_set_balance
pa_cvolume_set_balance.restype = POINTER(pa_cvolume)
pa_cvolume_set_balance.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), c_float]
pa_cvolume_get_fade = _libraries['libpulse.so.0'].pa_cvolume_get_fade
pa_cvolume_get_fade.restype = c_float
pa_cvolume_get_fade.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map)]
pa_cvolume_set_fade = _libraries['libpulse.so.0'].pa_cvolume_set_fade
pa_cvolume_set_fade.restype = POINTER(pa_cvolume)
pa_cvolume_set_fade.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), c_float]
pa_cvolume_scale = _libraries['libpulse.so.0'].pa_cvolume_scale
pa_cvolume_scale.restype = POINTER(pa_cvolume)
pa_cvolume_scale.argtypes = [POINTER(pa_cvolume), pa_volume_t]
pa_cvolume_scale_mask = _libraries['libpulse.so.0'].pa_cvolume_scale_mask
pa_cvolume_scale_mask.restype = POINTER(pa_cvolume)
pa_cvolume_scale_mask.argtypes = [POINTER(pa_cvolume), pa_volume_t, POINTER(pa_channel_map), pa_channel_position_mask_t]
pa_cvolume_set_position = _libraries['libpulse.so.0'].pa_cvolume_set_position
pa_cvolume_set_position.restype = POINTER(pa_cvolume)
pa_cvolume_set_position.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), pa_channel_position_t, pa_volume_t]
pa_cvolume_get_position = _libraries['libpulse.so.0'].pa_cvolume_get_position
pa_cvolume_get_position.restype = pa_volume_t
pa_cvolume_get_position.argtypes = [POINTER(pa_cvolume), POINTER(pa_channel_map), pa_channel_position_t]
pa_cvolume_merge = _libraries['libpulse.so.0'].pa_cvolume_merge
pa_cvolume_merge.restype = POINTER(pa_cvolume)
pa_cvolume_merge.argtypes = [POINTER(pa_cvolume), POINTER(pa_cvolume), POINTER(pa_cvolume)]
pa_cvolume_inc_clamp = _libraries['libpulse.so.0'].pa_cvolume_inc_clamp
pa_cvolume_inc_clamp.restype = POINTER(pa_cvolume)
pa_cvolume_inc_clamp.argtypes = [POINTER(pa_cvolume), pa_volume_t, pa_volume_t]
pa_cvolume_inc = _libraries['libpulse.so.0'].pa_cvolume_inc
pa_cvolume_inc.restype = POINTER(pa_cvolume)
pa_cvolume_inc.argtypes = [POINTER(pa_cvolume), pa_volume_t]
pa_cvolume_dec = _libraries['libpulse.so.0'].pa_cvolume_dec
pa_cvolume_dec.restype = POINTER(pa_cvolume)
pa_cvolume_dec.argtypes = [POINTER(pa_cvolume), pa_volume_t]
pa_xmalloc = _libraries['libpulse.so.0'].pa_xmalloc
pa_xmalloc.restype = c_void_p
pa_xmalloc.argtypes = [size_t]
pa_xmalloc0 = _libraries['libpulse.so.0'].pa_xmalloc0
pa_xmalloc0.restype = c_void_p
pa_xmalloc0.argtypes = [size_t]
pa_xrealloc = _libraries['libpulse.so.0'].pa_xrealloc
pa_xrealloc.restype = c_void_p
pa_xrealloc.argtypes = [c_void_p, size_t]
pa_xfree = _libraries['libpulse.so.0'].pa_xfree
pa_xfree.restype = None
pa_xfree.argtypes = [c_void_p]
pa_xstrdup = _libraries['libpulse.so.0'].pa_xstrdup
pa_xstrdup.restype = STRING
pa_xstrdup.argtypes = [STRING]
pa_xstrndup = _libraries['libpulse.so.0'].pa_xstrndup
pa_xstrndup.restype = STRING
pa_xstrndup.argtypes = [STRING, size_t]
pa_xmemdup = _libraries['libpulse.so.0'].pa_xmemdup
pa_xmemdup.restype = c_void_p
pa_xmemdup.argtypes = [c_void_p, size_t]
PA_CHANNELS_MAX = 32L # Variable c_uint '32u'
PA_PROP_WINDOW_DESKTOP = 'window.desktop' # Variable STRING '(const char*)"window.desktop"'
PA_NSEC_PER_SEC = 1000000000L # Variable c_ulonglong '1000000000ull'
PA_PROP_WINDOW_ICON = 'window.icon' # Variable STRING '(const char*)"window.icon"'
PA_NSEC_PER_MSEC = 1000000L # Variable c_ulonglong '1000000ull'
PA_USEC_PER_MSEC = 1000L # Variable c_ulong '1000u'
PA_PROP_DEVICE_BUFFERING_BUFFER_SIZE = 'device.buffering.buffer_size' # Variable STRING '(const char*)"device.buffering.buffer_size"'
PA_VOLUME_MUTED = 0L # Variable c_uint '0u'
PA_PROP_WINDOW_HPOS = 'window.hpos' # Variable STRING '(const char*)"window.hpos"'
PA_PROP_DEVICE_CLASS = 'device.class' # Variable STRING '(const char*)"device.class"'
PA_USEC_PER_SEC = 1000000L # Variable c_ulong '1000000u'
PA_PROP_WINDOW_X11_DISPLAY = 'window.x11.display' # Variable STRING '(const char*)"window.x11.display"'
PA_PROP_DEVICE_VENDOR_ID = 'device.vendor.id' # Variable STRING '(const char*)"device.vendor.id"'
PA_PROP_FILTER_SUPPRESS = 'filter.suppress' # Variable STRING '(const char*)"filter.suppress"'
PA_PROP_FORMAT_CHANNEL_MAP = 'format.channel_map' # Variable STRING '(const char*)"format.channel_map"'
PA_PROP_DEVICE_BUFFERING_FRAGMENT_SIZE = 'device.buffering.fragment_size' # Variable STRING '(const char*)"device.buffering.fragment_size"'
PA_PROP_DEVICE_PROFILE_DESCRIPTION = 'device.profile.description' # Variable STRING '(const char*)"device.profile.description"'
PA_PROP_MEDIA_ICON = 'media.icon' # Variable STRING '(const char*)"media.icon"'
PA_PROP_DEVICE_PRODUCT_ID = 'device.product.id' # Variable STRING '(const char*)"device.product.id"'
PA_PROP_FILTER_APPLY = 'filter.apply' # Variable STRING '(const char*)"filter.apply"'
PA_PROP_WINDOW_VPOS = 'window.vpos' # Variable STRING '(const char*)"window.vpos"'
PA_PROP_DEVICE_BUS_PATH = 'device.bus_path' # Variable STRING '(const char*)"device.bus_path"'
PA_PROP_APPLICATION_PROCESS_MACHINE_ID = 'application.process.machine_id' # Variable STRING '(const char*)"application.process.machine_id"'
PA_PROP_WINDOW_Y = 'window.y' # Variable STRING '(const char*)"window.y"'
PA_PROP_WINDOW_X = 'window.x' # Variable STRING '(const char*)"window.x"'
PA_PROP_APPLICATION_PROCESS_ID = 'application.process.id' # Variable STRING '(const char*)"application.process.id"'
PA_PROP_MEDIA_ICON_NAME = 'media.icon_name' # Variable STRING '(const char*)"media.icon_name"'
PA_CVOLUME_SNPRINT_MAX = 320 # Variable c_int '320'
PA_RATE_MAX = 192000L # Variable c_uint '192000u'
PA_MICRO = 0 # Variable c_int '0'
PA_PROP_APPLICATION_ICON_NAME = 'application.icon_name' # Variable STRING '(const char*)"application.icon_name"'
PA_PROP_MODULE_VERSION = 'module.version' # Variable STRING '(const char*)"module.version"'
PA_INVALID_INDEX = 4294967295L # Variable c_uint '4294967295u'
PA_PROP_APPLICATION_PROCESS_HOST = 'application.process.host' # Variable STRING '(const char*)"application.process.host"'
PA_PROP_DEVICE_ICON = 'device.icon' # Variable STRING '(const char*)"device.icon"'
PA_PROP_WINDOW_X11_SCREEN = 'window.x11.screen' # Variable STRING '(const char*)"window.x11.screen"'
PA_USEC_INVALID = 18446744073709551615L # Variable c_ulong '-1u'
PA_PROP_APPLICATION_LANGUAGE = 'application.language' # Variable STRING '(const char*)"application.language"'
PA_PROP_WINDOW_WIDTH = 'window.width' # Variable STRING '(const char*)"window.width"'
PA_PROP_DEVICE_STRING = 'device.string' # Variable STRING '(const char*)"device.string"'
PA_PROP_DEVICE_BUS = 'device.bus' # Variable STRING '(const char*)"device.bus"'
PA_PROTOCOL_VERSION = 23 # Variable c_int '23'
PA_PROP_MEDIA_ROLE = 'media.role' # Variable STRING '(const char*)"media.role"'
PA_MINOR = 1 # Variable c_int '1'
PA_PROP_EVENT_MOUSE_VPOS = 'event.mouse.vpos' # Variable STRING '(const char*)"event.mouse.vpos"'
PA_PROP_MEDIA_ARTIST = 'media.artist' # Variable STRING '(const char*)"media.artist"'
PA_PROP_MEDIA_SOFTWARE = 'media.software' # Variable STRING '(const char*)"media.software"'
PA_PROP_APPLICATION_ID = 'application.id' # Variable STRING '(const char*)"application.id"'
PA_DECIBEL_MININFTY = -200.0 # Variable c_double '-2.0e+2'
PA_PROP_WINDOW_NAME = 'window.name' # Variable STRING '(const char*)"window.name"'
PA_NSEC_PER_USEC = 1000L # Variable c_ulonglong '1000ull'
PA_API_VERSION = 12 # Variable c_int '12'
PA_PROP_WINDOW_X11_XID = 'window.x11.xid' # Variable STRING '(const char*)"window.x11.xid"'
PA_VOLUME_NORM = 65536L # Variable c_uint '65536u'
PA_PROP_EVENT_MOUSE_BUTTON = 'event.mouse.button' # Variable STRING '(const char*)"event.mouse.button"'
PA_PROP_APPLICATION_PROCESS_USER = 'application.process.user' # Variable STRING '(const char*)"application.process.user"'
PA_PROP_APPLICATION_ICON = 'application.icon' # Variable STRING '(const char*)"application.icon"'
PA_PROP_WINDOW_X11_MONITOR = 'window.x11.monitor' # Variable STRING '(const char*)"window.x11.monitor"'
PA_STREAM_EVENT_REQUEST_CORK = 'request-cork' # Variable STRING '(const char*)"request-cork"'
PA_PROP_MEDIA_FILENAME = 'media.filename' # Variable STRING '(const char*)"media.filename"'
PA_PROP_FORMAT_SAMPLE_FORMAT = 'format.sample_format' # Variable STRING '(const char*)"format.sample_format"'
PA_CHANNEL_MAP_SNPRINT_MAX = 336 # Variable c_int '336'
PA_PROP_MEDIA_TITLE = 'media.title' # Variable STRING '(const char*)"media.title"'
PA_PROP_EVENT_MOUSE_X = 'event.mouse.x' # Variable STRING '(const char*)"event.mouse.x"'
PA_SAMPLE_SPEC_SNPRINT_MAX = 32 # Variable c_int '32'
PA_PROP_EVENT_MOUSE_Y = 'event.mouse.y' # Variable STRING '(const char*)"event.mouse.y"'
PA_PROP_FILTER_WANT = 'filter.want' # Variable STRING '(const char*)"filter.want"'
PA_PROP_MODULE_USAGE = 'module.usage' # Variable STRING '(const char*)"module.usage"'
PA_PROP_WINDOW_ID = 'window.id' # Variable STRING '(const char*)"window.id"'
PA_PROP_DEVICE_API = 'device.api' # Variable STRING '(const char*)"device.api"'
PA_PROP_EVENT_DESCRIPTION = 'event.description' # Variable STRING '(const char*)"event.description"'
PA_PROP_DEVICE_ACCESS_MODE = 'device.access_mode' # Variable STRING '(const char*)"device.access_mode"'
PA_PROP_EVENT_MOUSE_HPOS = 'event.mouse.hpos' # Variable STRING '(const char*)"event.mouse.hpos"'
PA_PROP_DEVICE_MASTER_DEVICE = 'device.master_device' # Variable STRING '(const char*)"device.master_device"'
PA_PROP_FORMAT_RATE = 'format.rate' # Variable STRING '(const char*)"format.rate"'
PA_PROP_DEVICE_PROFILE_NAME = 'device.profile.name' # Variable STRING '(const char*)"device.profile.name"'
PA_STREAM_EVENT_REQUEST_UNCORK = 'request-uncork' # Variable STRING '(const char*)"request-uncork"'
PA_PROP_EVENT_ID = 'event.id' # Variable STRING '(const char*)"event.id"'
PA_BYTES_SNPRINT_MAX = 11 # Variable c_int '11'
PA_PROP_DEVICE_FORM_FACTOR = 'device.form_factor' # Variable STRING '(const char*)"device.form_factor"'
PA_PROP_APPLICATION_PROCESS_SESSION_ID = 'application.process.session_id' # Variable STRING '(const char*)"application.process.session_id"'
PA_USEC_MAX = 18446744073709551614L # Variable c_ulong '-2u'
PA_PROP_FORMAT_CHANNELS = 'format.channels' # Variable STRING '(const char*)"format.channels"'
PA_PROP_MEDIA_NAME = 'media.name' # Variable STRING '(const char*)"media.name"'
PA_VOLUME_SNPRINT_MAX = 10 # Variable c_int '10'
PA_PROP_DEVICE_SERIAL = 'device.serial' # Variable STRING '(const char*)"device.serial"'
PA_STREAM_EVENT_FORMAT_LOST = 'format-lost' # Variable STRING '(const char*)"format-lost"'
PA_PROP_APPLICATION_VERSION = 'application.version' # Variable STRING '(const char*)"application.version"'
PA_PROP_DEVICE_PRODUCT_NAME = 'device.product.name' # Variable STRING '(const char*)"device.product.name"'
PA_PROP_MODULE_AUTHOR = 'module.author' # Variable STRING '(const char*)"module.author"'
PA_PROP_WINDOW_ICON_NAME = 'window.icon_name' # Variable STRING '(const char*)"window.icon_name"'
PA_MAJOR = 1 # Variable c_int '1'
PA_MSEC_PER_SEC = 1000L # Variable c_ulong '1000u'
PA_PROP_DEVICE_VENDOR_NAME = 'device.vendor.name' # Variable STRING '(const char*)"device.vendor.name"'
PA_PROP_DEVICE_INTENDED_ROLES = 'device.intended_roles' # Variable STRING '(const char*)"device.intended_roles"'
PA_SW_CVOLUME_SNPRINT_DB_MAX = 448 # Variable c_int '448'
PA_PROP_DEVICE_DESCRIPTION = 'device.description' # Variable STRING '(const char*)"device.description"'
PA_PROP_APPLICATION_NAME = 'application.name' # Variable STRING '(const char*)"application.name"'
PA_PROP_DEVICE_ICON_NAME = 'device.icon_name' # Variable STRING '(const char*)"device.icon_name"'
PA_PROP_MODULE_DESCRIPTION = 'module.description' # Variable STRING '(const char*)"module.description"'
PA_FORMAT_INFO_SNPRINT_MAX = 256 # Variable c_int '256'
PA_PROP_APPLICATION_PROCESS_BINARY = 'application.process.binary' # Variable STRING '(const char*)"application.process.binary"'
PA_PROP_WINDOW_HEIGHT = 'window.height' # Variable STRING '(const char*)"window.height"'
PA_PROP_MEDIA_COPYRIGHT = 'media.copyright' # Variable STRING '(const char*)"media.copyright"'
PA_SW_VOLUME_SNPRINT_DB_MAX = 10 # Variable c_int '10'
PA_PROP_MEDIA_LANGUAGE = 'media.language' # Variable STRING '(const char*)"media.language"'
pollfd._fields_ = [
]
__all__ = ['pa_context_set_name',
           'pa_context_get_source_info_by_index',
           'pa_time_event_destroy_cb_t', 'PA_IO_EVENT_HANGUP',
           'pa_client_info', 'pa_context_set_sink_volume_by_name',
           'pa_stream_request_cb_t', 'PA_PROP_MEDIA_ROLE',
           'PA_STREAM_UPLOAD', 'PA_SUBSCRIPTION_MASK_SOURCE',
           'PA_PROP_DEVICE_API', 'pa_context_get_protocol_version',
           'pa_channel_map_def_t',
           'pa_context_set_card_profile_by_name',
           'pa_context_get_server_info', 'pa_stream_set_buffer_attr',
           'pa_context_get_sample_info_by_index', 'uint8_t',
           'pa_get_host_name', 'pa_bytes_to_usec', 'pa_free_cb_t',
           'pa_format_info_set_channel_map',
           'pa_context_get_client_info_list',
           'pa_threaded_mainloop_in_thread', 'pa_xfree',
           'pa_proplist_iterate',
           'PA_PROP_DEVICE_BUFFERING_BUFFER_SIZE', 'PA_VOLUME_MUTED',
           'pa_context_move_sink_input_by_index',
           'pa_context_suspend_sink_by_name', 'PA_CONTEXT_NOFAIL',
           'PA_PROP_DEVICE_CLASS', 'pa_encoding_t',
           'pa_stream_set_name', 'PA_PROP_FILTER_SUPPRESS',
           'pa_stream_set_event_callback', 'pa_channel_map_valid',
           'PA_CHANNEL_POSITION_SUBWOOFER', 'pa_signal_destroy_cb_t',
           'pa_channel_position_from_string', '__time_t',
           'pa_seek_mode', 'PA_SUBSCRIPTION_MASK_CLIENT',
           'pa_context_set_sink_volume_by_index',
           'pa_context_get_module_info', 'pa_sample_spec_init',
           'PA_RATE_MAX', 'pa_channel_position_mask_t',
           'PA_SINK_LATENCY', 'PA_PROP_MEDIA_ICON', 'PA_USEC_INVALID',
           'pa_cvolume_set_fade',
           'pa_context_remove_autoload_by_name',
           'pa_mainloop_get_retval',
           'pa_format_info_set_prop_string_array', 'PA_SINK_UNLINKED',
           'pa_subscription_event_type_t', 'PA_ERR_TIMEOUT',
           'PA_PROP_APPLICATION_PROCESS_ID',
           'pa_context_get_source_output_info_list', 'pa_sample_spec',
           'pa_context_play_sample_with_proplist',
           'PA_ENCODING_DTS_IEC61937', 'PA_ERR_NOTSUPPORTED',
           'pa_stream_get_channel_map', 'pa_channel_map_parse',
           'pa_channel_map_equal', 'PA_CHANNEL_POSITION_MAX',
           'pa_cvolume_remap', 'PA_STREAM_AUTO_TIMING_UPDATE',
           'PA_STREAM_PASSTHROUGH', 'PA_PROP_DEVICE_STRING',
           'pa_context_get_autoload_info_by_index',
           'pa_format_info_is_compatible',
           'pa_context_play_sample_cb_t', 'pa_proplist_size',
           'pa_xstrdup', 'pa_stream_get_timing_info',
           'pa_cvolume_get_position', 'PA_CHANNEL_POSITION_AUX18',
           'PA_CHANNEL_POSITION_AUX19', 'pa_signal_init',
           'PA_CHANNEL_POSITION_AUX10', 'PA_CHANNEL_POSITION_AUX11',
           'PA_CHANNEL_POSITION_AUX12', 'PA_CHANNEL_POSITION_AUX13',
           'PA_CHANNEL_POSITION_AUX14', 'PA_CHANNEL_POSITION_AUX15',
           'PA_CHANNEL_POSITION_AUX16', 'PA_CHANNEL_POSITION_AUX17',
           'pa_stream_set_moved_callback', 'pa_stream_trigger',
           'pa_timeval_age', 'PA_SAMPLE_U8', 'PA_SINK_HARDWARE',
           'pa_stream_get_device_index', 'pa_cvolume_max',
           'PA_PROP_EVENT_ID', 'PA_NSEC_PER_USEC',
           'pa_format_info_set_rate', 'pa_stream_state_t',
           'PA_BYTES_SNPRINT_MAX', 'pa_proplist_from_string',
           'PA_CHANNEL_POSITION_INVALID', 'PA_ERR_INTERNAL',
           'PA_CHANNEL_POSITION_FRONT_RIGHT_OF_CENTER',
           'pa_cvolume_avg', 'pa_stream_state',
           'PA_PROP_WINDOW_X11_XID', 'PA_CONTEXT_UNCONNECTED',
           'PA_SUBSCRIPTION_EVENT_MODULE', 'PA_ERR_TOOLARGE',
           'PA_CHANNEL_MAP_ALSA', 'PA_STREAM_FIX_FORMAT',
           'PA_SOURCE_HARDWARE', 'PA_CHANNEL_POSITION_CENTER',
           'PA_PROP_WINDOW_X11_MONITOR',
           'pa_context_set_source_volume_by_index',
           'PA_PROP_MEDIA_FILENAME', 'PA_SINK_DECIBEL_VOLUME',
           'pa_operation_ref', 'pa_format_info_copy',
           'pa_channel_position_t', 'pa_sample_format_t',
           'pa_stream_flush', 'PA_PROP_FORMAT_SAMPLE_FORMAT',
           'PA_SEEK_ABSOLUTE', 'PA_PROP_MEDIA_TITLE',
           'PA_SAMPLE_SPEC_SNPRINT_MAX', 'PA_SOURCE_INVALID_STATE',
           'pa_stream_set_write_callback', 'PA_SOURCE_LATENCY',
           'PA_CHANNELS_MAX', 'PA_CONTEXT_NOAUTOSPAWN',
           'pa_cvolume_set_position', 'pa_sample_info',
           'pa_subscription_mask_t', 'PA_SUBSCRIPTION_EVENT_SOURCE',
           'pa_io_event_flags', 'pa_context_errno',
           'PA_CONTEXT_READY', 'PA_SAMPLE_S24BE',
           'pa_threaded_mainloop_wait', 'pa_stream_connect_record',
           'pa_context_remove_autoload_by_index',
           'PA_SEEK_RELATIVE_END', 'pa_timing_info',
           'pa_path_get_filename', 'pa_stream_get_buffer_attr',
           'PA_STREAM_EVENT_REQUEST_UNCORK', 'pa_defer_event',
           'pa_get_binary_name', 'pa_channel_map_can_balance',
           'PA_API_VERSION', 'pa_stream_set_buffer_attr_callback',
           'PA_CHANNEL_MAP_OSS', 'pa_format_info_is_pcm',
           'pa_context_get_server_protocol_version',
           'pa_sample_format_is_be', 'PA_SUBSCRIPTION_EVENT_CLIENT',
           'pa_stream_ref', 'PA_SOURCE_HW_VOLUME_CTRL',
           'PA_PROP_MEDIA_COPYRIGHT', 'pollfd', 'PA_ERR_ACCESS',
           'PA_CHANNEL_POSITION_TOP_FRONT_RIGHT',
           'pa_defer_event_destroy_cb_t', 'pa_strerror',
           'pa_channel_map_snprint', 'PA_STREAM_FIX_RATE',
           'pa_context_drain', 'pa_stream_direction_t',
           'PA_PROP_DEVICE_VENDOR_NAME',
           'PA_SUBSCRIPTION_EVENT_SAMPLE_CACHE',
           'PA_PROP_APPLICATION_PROCESS_HOST',
           'pa_stream_get_format_info', 'PA_PROP_APPLICATION_NAME',
           'pa_signal_new', 'PA_SAMPLE_S24_32BE', 'PA_SOURCE_NETWORK',
           'PA_SUBSCRIPTION_EVENT_FACILITY_MASK',
           'pa_mainloop_wakeup', 'pa_xstrndup', 'PA_SEEK_RELATIVE',
           'pa_module_info', 'pa_encoding_to_string', 'PA_ERR_IO',
           'pa_stream_flags_t', 'pa_timeval_sub', 'pa_timeval_add',
           'PA_CHANNEL_POSITION_TOP_REAR_CENTER',
           'PA_CONTEXT_CONNECTING', 'pa_context_add_autoload',
           'pa_sw_cvolume_divide',
           'pa_context_set_source_mute_by_name',
           'PA_SUBSCRIPTION_MASK_AUTOLOAD', 'pa_stream_cancel_write',
           'PA_SINK_HW_MUTE_CTRL', 'PA_CHANNEL_POSITION_AUX21',
           'PA_CHANNEL_POSITION_AUX20', 'PA_CHANNEL_POSITION_AUX23',
           'PA_CHANNEL_POSITION_AUX22', 'PA_CHANNEL_POSITION_AUX25',
           'PA_UPDATE_MERGE', 'PA_CHANNEL_POSITION_AUX27',
           'PA_SOURCE_DYNAMIC_LATENCY', 'PA_CHANNEL_POSITION_AUX29',
           'PA_CHANNEL_POSITION_AUX28',
           'pa_stream_set_started_callback', 'PA_SINK_FLAT_VOLUME',
           'size_t', 'pa_context_flags', 'pa_utf8_to_locale',
           'pa_proplist_sets', 'pa_proplist_setp',
           'PA_ERR_CONNECTIONTERMINATED', 'pa_format_info_free',
           'PA_PROP_WINDOW_ICON', 'pa_operation_cancel',
           'PA_CHANNEL_MAP_SNPRINT_MAX', 'PA_DEVICE_TYPE_SINK',
           'PA_CHANNEL_POSITION_TOP_FRONT_CENTER',
           'pa_format_info_from_string', 'pa_proplist_setf',
           'pa_cvolume_set', 'pa_bytes_per_second',
           'PA_PROP_DEVICE_PROFILE_DESCRIPTION', 'pa_stream',
           'PA_ERR_COMMAND', 'PA_SUBSCRIPTION_MASK_SINK_INPUT',
           'pa_channel_map_to_pretty_name', 'pa_card_info',
           'PA_CONTEXT_SETTING_NAME', 'PA_IO_EVENT_OUTPUT',
           'PA_PROP_FORMAT_CHANNEL_MAP',
           'pa_context_set_card_profile_by_index',
           'PA_CHANNEL_POSITION_FRONT_LEFT_OF_CENTER',
           'pa_sample_info_cb_t', 'pa_source_state',
           'pa_channel_map_init_mono', 'pa_stream_readable_size',
           'PA_PROP_WINDOW_WIDTH', 'pa_stream_set_suspended_callback',
           'pa_cvolume_scale_mask', 'pa_stream_get_underflow_index',
           'pa_stream_begin_write', 'pa_stream_get_time',
           'pa_cvolume', 'pa_context_set_state_callback',
           'pa_sw_cvolume_multiply', 'PA_CHANNEL_POSITION_REAR_LEFT',
           'PA_ERR_EXIST', 'pa_threaded_mainloop_lock', 'pa_io_event',
           'PA_VOLUME_NORM', 'pa_proplist_unset_many',
           'PA_SAMPLE_MAX', 'PA_SOURCE_DECIBEL_VOLUME',
           'PA_PROP_WINDOW_Y', 'PA_PROP_WINDOW_X',
           'pa_stream_get_state', 'pa_frame_size',
           'pa_sample_size_of_format', 'PA_SAMPLE_FLOAT32LE',
           'PA_STREAM_FIX_CHANNELS', 'PA_CONTEXT_NOFLAGS',
           'PA_STREAM_EARLY_REQUESTS', 'pa_update_mode_t',
           'pa_proplist_unset', 'PA_ERR_PROTOCOL',
           'PA_PROP_MODULE_AUTHOR', 'PA_SOURCE_HW_MUTE_CTRL',
           'pa_context_set_subscribe_callback',
           'PA_PROP_MODULE_VERSION', 'PA_ENCODING_ANY',
           'pa_context_set_default_sink', 'PA_SAMPLE_S24_32LE',
           'pa_context_get_client_info', 'PA_ENCODING_PCM',
           'pa_stream_notify_cb_t', 'pa_context_index_cb_t',
           'pa_cvolume_merge', 'PA_ENCODING_MAX', 'pa_signal_done',
           'pa_threaded_mainloop_new', 'PA_PROP_DEVICE_ICON',
           'pa_channel_map_init_extend', 'PA_SUBSCRIPTION_MASK_SINK',
           'pa_context_set_sink_mute_by_name', 'pa_sample_spec_equal',
           'pa_mainloop_api_once', 'pa_threaded_mainloop_stop',
           'pa_timeval_cmp', 'pa_source_flags_t', 'pa_sink_flags',
           'pa_io_event_cb_t', 'pa_mainloop_get_api',
           'PA_CHANNEL_MAP_DEF_MAX', 'pa_usec_to_bytes',
           'PA_ERR_VERSION', 'pa_stream_prebuf', 'PA_IO_EVENT_NULL',
           'PA_OPERATION_RUNNING', 'PA_CHANNEL_POSITION_LEFT',
           'pa_cvolume_min', 'PA_CHANNEL_POSITION_RIGHT',
           'PA_SINK_INVALID_STATE', 'PA_SUBSCRIPTION_EVENT_SINK',
           'pa_io_event_flags_t', '__suseconds_t',
           'pa_channel_map_init_stereo', 'PA_CHANNEL_MAP_AUX',
           'pa_threaded_mainloop_unlock', 'PA_SINK_RUNNING',
           'pa_source_flags', 'pa_stream_proplist_remove',
           'pa_get_library_version', 'PA_SINK_NETWORK',
           'pa_stream_event_cb_t', 'PA_ENCODING_MPEG_IEC61937',
           'PA_SUBSCRIPTION_EVENT_SOURCE_OUTPUT', 'pa_source_state_t',
           'pa_xmalloc0', 'PA_UPDATE_SET',
           'pa_stream_update_timing_info',
           'PA_SUBSCRIPTION_EVENT_REMOVE', 'pa_stat_info',
           'PA_CONTEXT_AUTHORIZING', 'pa_proplist_new',
           'PA_SOURCE_INIT', 'pa_mainloop', 'PA_USEC_PER_SEC',
           'pa_stream_writable_size', 'PA_PROP_EVENT_MOUSE_HPOS',
           'PA_SUBSCRIPTION_MASK_CARD',
           'pa_context_set_sink_port_by_name',
           'pa_sw_cvolume_snprint_dB',
           'PA_SUBSCRIPTION_MASK_SAMPLE_CACHE', 'PA_PROP_FILTER_WANT',
           'PA_STREAM_INTERPOLATE_TIMING',
           'pa_context_set_sink_input_volume',
           'pa_stream_proplist_update', 'pa_volume_snprint',
           'pa_context_get_sink_info_by_name', 'uint64_t',
           'PA_CVOLUME_SNPRINT_MAX', 'pa_spawn_api',
           'PA_CHANNEL_POSITION_TOP_FRONT_LEFT',
           'pa_context_set_sink_input_mute', 'PA_USEC_MAX',
           'PA_CHANNEL_POSITION_TOP_CENTER', 'pa_get_home_dir',
           'pa_operation_unref', 'PA_ERR_BADSTATE', 'pa_mainloop_run',
           'pa_mainloop_iterate', 'PA_SUBSCRIPTION_MASK_NULL',
           'pa_cvolume_inc_clamp', 'PA_PROP_MODULE_USAGE',
           'pa_device_type', 'pa_sample_format_is_le', 'pa_xmalloc',
           'PA_ERR_MODINITFAILED', 'timeval',
           'PA_PROP_WINDOW_ICON_NAME', 'pa_sample_spec_snprint',
           'PA_MSEC_PER_SEC', 'pa_stream_get_sample_spec',
           'PA_STREAM_START_UNMUTED', 'PA_STREAM_TERMINATED',
           'pa_context_get_card_info_list', 'pa_cvolume_scale',
           'pa_proplist', 'pa_cvolume_init',
           'pa_stream_set_read_callback', 'pa_server_info',
           'PA_PROP_APPLICATION_ICON_NAME', 'PA_SAMPLE_ALAW',
           'PA_SUBSCRIPTION_MASK_MODULE', 'PA_STREAM_FAILED',
           'pa_sw_volume_divide', 'pa_stream_finish_upload',
           'PA_PROP_EVENT_DESCRIPTION', 'pa_sw_volume_from_dB',
           'pa_format_info_set_prop_int_array', 'PA_ERR_AUTHKEY',
           'PA_SUBSCRIPTION_EVENT_NEW', 'PA_STREAM_EVENT_FORMAT_LOST',
           'PA_SUBSCRIPTION_EVENT_SINK_INPUT',
           'PA_PROP_FORMAT_CHANNELS', 'PA_PROP_MEDIA_LANGUAGE',
           'pa_source_output_info', 'pa_context_state_t',
           'PA_PROP_APPLICATION_ICON',
           'PA_STREAM_DONT_INHIBIT_AUTO_SUSPEND',
           'PA_PROP_WINDOW_DESKTOP', 'pa_io_event_destroy_cb_t',
           'PA_ERR_MAX', 'pa_proplist_to_string',
           'PA_CHANNEL_POSITION_SIDE_RIGHT', 'pa_context_stat',
           'pa_locale_to_utf8', 'pa_context_set_source_port_by_index',
           'pa_stream_set_latency_update_callback',
           'PA_PROP_WINDOW_VPOS', 'pa_operation_state_t',
           'PA_CHANNEL_POSITION_AUX24', 'pa_context_get_state',
           'PA_ERR_FORKED', 'pa_source_info',
           'PA_CHANNEL_POSITION_AUX26', 'PA_ERR_CONNECTIONREFUSED',
           'PA_CHANNEL_POSITION_FRONT_RIGHT', 'pa_sample_size',
           'PA_PROP_DEVICE_DESCRIPTION', 'pa_msleep',
           'PA_USEC_PER_MSEC', 'pa_context_get_sink_info_list',
           'PA_CHANNEL_POSITION_AUX30', 'PA_CHANNEL_POSITION_AUX31',
           'PA_SAMPLE_INVALID', 'PA_SAMPLE_ULAW', 'pa_usec_t',
           'pa_autoload_info_cb_t', 'pa_gettimeofday',
           'pa_card_info_cb_t', 'PA_STREAM_ADJUST_LATENCY',
           'PA_PROP_DEVICE_BUFFERING_FRAGMENT_SIZE',
           'pa_cvolume_equal', 'pa_parse_sample_format',
           'PA_IO_EVENT_ERROR', 'pa_context_set_sink_port_by_index',
           'PA_DEVICE_TYPE_SOURCE', 'pa_threaded_mainloop_get_api',
           'pa_bytes_snprint', 'pa_context_event_cb_t',
           'pa_cvolume_valid', 'pa_context_rttime_restart',
           'PA_PROP_EVENT_MOUSE_VPOS', 'pa_mainloop_poll',
           'PA_STREAM_NO_REMAP_CHANNELS', 'pa_mainloop_free',
           'PA_SINK_SUSPENDED', 'pa_threaded_mainloop_start',
           'pa_format_info_set_sample_format',
           'pa_format_info_set_prop_int', 'PA_PROP_MEDIA_ICON_NAME',
           'pa_autoload_type', 'pa_threaded_mainloop',
           'PA_SINK_DYNAMIC_LATENCY', 'pa_context_kill_client',
           'pa_sink_state', 'pa_stream_write', 'pa_sink_port_info',
           'pa_mainloop_new', 'pa_context_get_source_info_by_name',
           'PA_STREAM_NO_REMIX_CHANNELS', 'pa_context_remove_sample',
           'PA_MAJOR', 'PA_STREAM_FAIL_ON_SUSPEND',
           'pa_context_get_tile_size', 'pa_stream_set_state_callback',
           'PA_PROP_APPLICATION_PROCESS_SESSION_ID',
           'pa_client_info_cb_t', 'pa_stream_connect_playback',
           'pa_context_unref', 'pa_format_info_set_prop_int_range',
           'pa_context_new_with_proplist', 'PA_PROP_DEVICE_BUS',
           'PA_SINK_SET_FORMATS', 'pa_stream_new_extended',
           'PA_CHANNEL_POSITION_TOP_REAR_LEFT',
           'PA_SUBSCRIPTION_EVENT_AUTOLOAD',
           'PA_CHANNEL_POSITION_FRONT_CENTER',
           'PA_SEEK_RELATIVE_ON_READ', 'pa_channel_position',
           'pa_mainloop_api', 'pa_proplist_gets',
           'pa_context_set_default_source', 'PA_CHANNEL_POSITION_LFE',
           'pa_sample_format', 'pa_sw_cvolume_divide_scalar',
           'pa_cvolume_min_mask', 'PA_STREAM_PEAK_DETECT',
           'PA_IO_EVENT_INPUT', 'PA_STREAM_VARIABLE_RATE',
           'PA_ERR_NODATA', 'PA_DECIBEL_MININFTY',
           'PA_PROP_WINDOW_NAME',
           'pa_channel_position_to_pretty_string',
           'pa_stream_is_corked', 'pa_context_get_sink_input_info',
           'pa_sw_volume_snprint_dB',
           'pa_context_move_source_output_by_name',
           'pa_stream_get_device_name', 'pa_operation_state',
           'pa_channel_map_mask', 'pa_stream_disconnect',
           'PA_PROP_DEVICE_FORM_FACTOR',
           'PA_PROP_APPLICATION_PROCESS_MACHINE_ID',
           'pa_cvolume_set_balance',
           'PA_PROP_APPLICATION_PROCESS_USER', 'pa_get_user_name',
           'PA_STREAM_EVENT_REQUEST_CORK',
           'pa_proplist_to_string_sep', 'PA_STREAM_START_MUTED',
           'PA_SOURCE_NOFLAGS', 'pa_threaded_mainloop_accept',
           'PA_SAMPLE_S32LE', 'pa_context_notify_cb_t',
           'pa_context_set_source_mute_by_index', 'PA_SOURCE_IDLE',
           'pa_context_suspend_source_by_index',
           'PA_PROP_MEDIA_SOFTWARE', 'PA_PROP_WINDOW_ID',
           'PA_PROP_WINDOW_HPOS', 'pa_context_play_sample',
           'pa_channel_map_to_name',
           'pa_context_get_module_info_list', 'pa_operation',
           'PA_STREAM_RECORD', 'PA_AUTOLOAD_SOURCE',
           'pa_context_get_card_info_by_name',
           'PA_PROP_DEVICE_ACCESS_MODE', 'pa_context_subscribe',
           'PA_AUTOLOAD_SINK', 'pa_context_get_source_info_list',
           'PA_MINOR', 'pa_timeval_diff', 'PA_SOURCE_RUNNING',
           'pa_server_info_cb_t', 'pa_context_ref',
           'pa_sw_cvolume_multiply_scalar',
           'PA_SW_CVOLUME_SNPRINT_DB_MAX', 'PA_VOLUME_SNPRINT_MAX',
           'pa_time_event_cb_t', 'pa_stream_get_latency',
           'pa_xmemdup', 'PA_CHANNEL_POSITION_MONO',
           'PA_CHANNEL_MAP_DEFAULT', 'PA_OPERATION_DONE',
           'pa_mainloop_dispatch', 'pa_proplist_set', 'PA_SINK_INIT',
           'pa_cvolume_max_mask', 'PA_STREAM_NODIRECTION',
           'PA_PROP_DEVICE_SERIAL', 'pa_autoload_info',
           'PA_PROP_APPLICATION_VERSION',
           'pa_context_kill_sink_input', 'PA_PROP_WINDOW_X11_DISPLAY',
           'pa_sink_info_cb_t', 'pa_channel_map_superset',
           'PA_SUBSCRIPTION_MASK_SOURCE_OUTPUT',
           'pa_card_profile_info', 'pa_context_get_sample_info_list',
           'PA_MICRO', 'PA_PROP_DEVICE_VENDOR_ID',
           'pa_subscription_mask', 'PA_STREAM_DONT_MOVE',
           'pa_threaded_mainloop_free', 'PA_SAMPLE_S16BE',
           'pa_stream_connect_upload', 'PA_FORMAT_INFO_SNPRINT_MAX',
           'PA_ERR_KILLED', 'pa_context_get_source_output_info',
           'pa_stat_info_cb_t', 'pa_ascii_filter',
           'pa_context_get_autoload_info_list',
           'PA_ENCODING_AC3_IEC61937', 'PA_STREAM_PLAYBACK',
           'pa_format_info_set_channels', 'PA_PROP_FILTER_APPLY',
           'pa_sw_volume_to_dB', 'pa_format_info', 'pa_sink_state_t',
           'uint32_t', 'PA_SW_VOLUME_SNPRINT_DB_MAX', 'pa_volume_t',
           'PA_STREAM_UNCONNECTED', 'PA_CHANNEL_MAP_WAVEEX',
           'pa_stream_cork', 'pa_channel_map_init',
           'PA_ENCODING_EAC3_IEC61937', 'pa_stream_new_with_proplist',
           'PA_STREAM_NOFLAGS', 'pa_stream_success_cb_t',
           'PA_STREAM_NOT_MONOTONIC', 'PA_PROP_DEVICE_MASTER_DEVICE',
           'pa_stream_drain', 'PA_SINK_IDLE', 'pa_context_new',
           'pa_context_suspend_sink_by_index', 'pa_cvolume_dec',
           'PA_CONTEXT_TERMINATED', 'pa_context_rttime_new',
           'pa_module_info_cb_t',
           'PA_CHANNEL_POSITION_TOP_REAR_RIGHT', 'PA_NSEC_PER_MSEC',
           'pa_stream_peek', 'PA_PROP_MEDIA_NAME',
           'pa_channel_map_can_fade', 'PA_CONTEXT_FAILED',
           'pa_context_set_sink_mute_by_index', 'pa_sink_info',
           'pa_context_set_source_output_volume',
           'pa_sample_spec_valid', 'pa_operation_get_state',
           'PA_PROP_APPLICATION_PROCESS_BINARY',
           'pa_context_proplist_remove',
           'pa_context_move_source_output_by_index',
           'pa_timeval_load', 'pa_get_fqdn', 'pa_stream_unref',
           'pa_stream_set_monitor_stream',
           'PA_CHANNEL_POSITION_FRONT_LEFT', 'pa_mainloop_quit',
           'pa_channel_map_init_auto', 'pa_cvolume_inc',
           'PA_PROP_DEVICE_PRODUCT_ID', 'pa_cvolume_get_balance',
           'PA_PROTOCOL_VERSION', 'pa_source_info_cb_t',
           'pa_context_get_index', 'pa_signal_free',
           'PA_PROP_DEVICE_BUS_PATH', 'pa_cvolume_compatible',
           'pa_encoding', 'PA_NSEC_PER_SEC',
           'PA_SUBSCRIPTION_MASK_SERVER', 'pa_cvolume_get_fade',
           'pa_context', 'PA_PROP_EVENT_MOUSE_BUTTON',
           'pa_utf8_filter', 'pa_stream_update_sample_rate',
           'PA_PROP_DEVICE_PROFILE_NAME', 'pa_sw_volume_multiply',
           'pa_cvolume_snprint', 'pa_format_info_new',
           'pa_stream_flags', 'PA_CHANNEL_POSITION_AUX2',
           'PA_CHANNEL_POSITION_AUX3', 'PA_CHANNEL_POSITION_AUX0',
           'PA_SAMPLE_S16LE', 'PA_CHANNEL_POSITION_AUX6',
           'PA_STREAM_RELATIVE_VOLUME', 'PA_CHANNEL_POSITION_AUX4',
           'PA_CHANNEL_POSITION_AUX5', 'pa_xrealloc',
           'PA_CHANNEL_POSITION_AUX8', 'PA_CHANNEL_POSITION_AUX9',
           'PA_PROP_WINDOW_X11_SCREEN', 'PA_SOURCE_SUSPENDED',
           'pa_defer_event_cb_t', 'pa_threaded_mainloop_signal',
           'PA_STREAM_START_CORKED', 'pa_time_event',
           'PA_CHANNEL_MAP_AIFF', 'PA_PROP_APPLICATION_LANGUAGE',
           'PA_ERR_NOENTITY', 'PA_CHANNEL_POSITION_REAR_RIGHT',
           'pa_stream_get_context', 'pa_sw_volume_to_linear',
           'pa_source_output_info_cb_t',
           'pa_format_info_set_prop_string', 'pa_proplist_clear',
           'pa_context_get_server', 'pa_stream_set_overflow_callback',
           'PA_ERR_BUSY', 'pa_cvolume_compatible_with_channel_map',
           'PA_PROP_MEDIA_ARTIST', 'pa_utf8_valid',
           'pa_proplist_free', 'pa_stream_set_underflow_callback',
           'pa_channel_map', 'pa_update_mode',
           'PA_PROP_APPLICATION_ID', 'PA_UPDATE_REPLACE',
           'pa_stream_is_suspended', 'PA_SAMPLE_S24LE',
           'PA_ENCODING_INVALID', 'pa_context_get_card_info_by_index',
           'pa_proplist_equal', 'pa_stream_get_index',
           'pa_context_get_sample_info_by_name',
           'PA_SINK_HW_VOLUME_CTRL', 'PA_OPERATION_CANCELLED',
           'pa_context_get_sink_input_info_list',
           'pa_threaded_mainloop_get_retval', 'PA_SAMPLE_S32BE',
           'pa_proplist_copy', 'pa_context_proplist_update',
           'PA_INVALID_INDEX', 'PA_SAMPLE_FLOAT32BE',
           'pa_context_get_sink_info_by_index', 'pa_proplist_update',
           'PA_ERR_UNKNOWN', 'pa_stream_drop', 'pa_signal_cb_t',
           'pa_context_set_source_volume_by_name',
           'pa_context_subscribe_cb_t', 'pa_source_port_info',
           'pa_cvolume_channels_equal_to', 'PA_SINK_NOFLAGS',
           'PA_CHANNEL_POSITION_SIDE_LEFT', 'pa_device_type_t',
           'PA_SUBSCRIPTION_EVENT_CHANGE', 'PA_OK',
           'pa_channel_position_to_string', 'pa_context_load_module',
           'pa_context_connect', 'pa_autoload_type_t',
           'PA_SUBSCRIPTION_EVENT_CARD',
           'PA_CHANNEL_POSITION_REAR_CENTER', 'PA_ERR_INVALID',
           'pa_channel_map_def', 'pa_proplist_get',
           'PA_PROP_FORMAT_RATE', 'pa_context_flags_t',
           'PA_ERR_NOEXTENSION', 'pa_signal_set_destroy',
           'pa_poll_func', 'pa_context_set_source_output_mute',
           'pa_timeval_store', 'PA_SUBSCRIPTION_EVENT_TYPE_MASK',
           'pa_proplist_isempty', 'pa_cvolume_avg_mask',
           'pa_context_exit_daemon',
           'pa_context_suspend_source_by_name',
           'pa_context_set_event_callback', 'PA_ERR_NOTIMPLEMENTED',
           'PA_PROP_EVENT_MOUSE_X', 'PA_PROP_EVENT_MOUSE_Y',
           'pa_subscription_event_type',
           'pa_context_move_sink_input_by_name', 'int64_t',
           'pa_mainloop_set_poll_func', 'PA_SOURCE_FLAT_VOLUME',
           'PA_ERR_OBSOLETE', 'pa_mainloop_prepare',
           'PA_PROP_MODULE_DESCRIPTION', 'pa_context_is_pending',
           'PA_STREAM_CREATING', 'PA_PROP_DEVICE_PRODUCT_NAME',
           'pa_context_get_autoload_info_by_name', 'pa_context_state',
           'pa_ascii_valid', 'pa_context_disconnect',
           'pa_channel_map_compatible',
           'PA_SUBSCRIPTION_EVENT_SERVER', 'pa_stream_direction',
           'PA_SOURCE_UNLINKED', 'pa_sink_flags_t', 'pa_seek_mode_t',
           'pa_context_set_source_port_by_name',
           'pa_context_is_local', 'PA_PROP_DEVICE_INTENDED_ROLES',
           'pa_context_kill_source_output', 'pa_stream_new',
           'PA_SUBSCRIPTION_MASK_ALL', 'pa_proplist_contains',
           'PA_ERR_INVALIDSERVER', 'pa_stream_get_monitor_stream',
           'PA_PROP_DEVICE_ICON_NAME', 'PA_CHANNEL_POSITION_AUX1',
           'pa_sink_input_info_cb_t', 'pa_channel_map_has_position',
           'PA_STREAM_READY', 'pa_sw_volume_from_linear',
           'PA_CHANNEL_POSITION_AUX7', 'pa_context_unload_module',
           'PA_PROP_WINDOW_HEIGHT', 'pa_format_info_valid',
           'pa_signal_event', 'pa_sink_input_info',
           'pa_sample_format_to_string', 'pa_format_info_snprint',
           'pa_context_success_cb_t', 'pa_buffer_attr',
           'STRING']
