* `lib_pulseaudio.py`  
  https://github.com/Valodim/python-pulseaudio  
  By Vincent Breitmoser, under LGPL
* `peak_monitor.py`  
  http://freshfoo.com/posts/pulseaudio_monitoring/  
  http://freshfoo.com/posts/raspberry_pi_vu_meter/  
  https://bitbucket.org/mjs0/raspberry_pi-vu_meter/src  
  By Menno Finlay-Smits

`peak_monitor.py` has been modified so that the monitor is filtered out (pretend to be a PulseAudio Control stream). It will also be modified further to monitor the peaks of Sources, SourceOutputs, and SinkInputs.
