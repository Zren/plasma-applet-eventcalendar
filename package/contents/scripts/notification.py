#!/usr/bin/python3
import os, sys
import argparse
import subprocess
from enum import Enum, IntEnum
from ctypes import *

import gi
gi.require_version('GLib', '2.0')
gi.require_version('Notify', '0.7')
from gi.repository import GLib, Notify



#---
# Recreate canberra-gtk-play in Python
#   https://git.0pointer.net/libcanberra.git/tree/src/canberra-gtk-play.c
# Based on Dave Barry's <dave@psax.org> pycanberra under LGPL 2.1
#   https://github.com/totdb/pycanberra/blob/master/pycanberra.py
libcanberra = None
try:
	libcanberra = CDLL("libcanberra.so.0")
except:
	sys.stderr.write('libcanberra not found\n')

def convertArgs(args):
	return (
		arg.encode("utf-8") if isinstance(arg, str) else arg
		for arg in args
	)

ca_context = c_void_p

class Canberra:
	@staticmethod
	def installed():
		return libcanberra is not None

	class Code(IntEnum):
		SUCCESS = 0
		ERROR_NOTSUPPORTED = -1
		ERROR_INVALID = -2
		ERROR_STATE = -3
		ERROR_OOM = -4
		ERROR_NODRIVER = -5
		ERROR_SYSTEM = -6
		ERROR_CORRUPT = -7
		ERROR_TOOBIG = -8
		ERROR_NOTFOUND = -9
		ERROR_DESTROYED = -10
		ERROR_CANCELED = -11
		ERROR_NOTAVAILABLE = -12
		ERROR_ACCESS = -13
		ERROR_IO = -14
		ERROR_INTERNAL = -15
		ERROR_DISABLED = -16
		ERROR_FORKED = -17
		ERROR_DISCONNECTED = -18
		ERROR_MAX = -19

	class Prop(bytes, Enum):
		EVENT_ID = b'event.id'
		EVENT_DESCRIPTION = b'event.description'
		MEDIA_FILENAME = b'media.filename'
		APPLICATION_NAME = b'application.name'

	def __init__(self):
		self.context = ca_context()
		libcanberra.ca_context_create(byref(self.context))

	def play(self, *props):
		playId = 0
		res = libcanberra.ca_context_play(
			self.context,
			playId,
			*convertArgs(props),
			None, # Must end with NULL to mark end of props
		)
		if res != Canberra.Code.SUCCESS:
			raise Exception(Canberra.Code(res), "Error playing", props)

	def playEvent(self, eventId, *props):
		props += (Canberra.Prop.EVENT_ID, eventId)
		self.play(*props)

	def playFile(self, filename, *props):
		props += (Canberra.Prop.MEDIA_FILENAME, filename)
		self.play(*props)


#---
# Plasma's Notification server doesn't support sounds,
# the KNotify manually plays sounds instead. So we manually
# play them with libcanberra. We can't use canberra-gtk-play since
# it requires the gnome-session-canberra package in Ubuntu,
# which is not installed by default.
def playSound(args):
	if not Canberra.installed():
		sys.stderr.write('skipping playing sound\n')
		return

	canberra = Canberra()
	props = [
		Canberra.Prop.EVENT_DESCRIPTION, args.appName,
		Canberra.Prop.APPLICATION_NAME, args.appName,
	]

	if args.sound.startswith('file://'):
		args.sound = args.sound[len('file://'):]

	if args.sound.startswith('/'):
		canberra.playFile(args.sound, *props)
	else:
		canberra.playEvent(args.sound, *props)


	if args.loop:
		for i in range(args.loop):
			# TODO: wait for playEffect to end.
			# TODO: wrap playEffect in a function, and call it here.
			pass


#---
def notify(args):
	sfxProc = None

	#--- Notification
	# https://notify2.readthedocs.io/en/latest/
	loop = GLib.MainLoop()
	Notify.init(args.appName)
	# print(Notify.get_server_caps())

	n = Notify.Notification.new(
		args.summary,
		args.message,
		icon=args.icon,
	)

	# Note: EXPIRES_DEFAULT = -1, EXPIRES_NEVER = 0
	n.set_timeout(args.timeout)

	def on_action(notification, action, *user_data):
		sys.stdout.write(' '.join([action, *user_data]) + '\n')
		if sfxProc:
			sfxProc.terminate()
		loop.quit()

	def closed(notification):
		on_action(notification, "closed")

	n.connect("closed", closed)
	n.add_action("default", "default", on_action)
	if args.actions:
		for action in args.actions:
			actionId, actionLabel = action.split(',', 1)
			n.add_action(actionId, actionLabel, on_action)
	n.show()

	#--- Sound
	if args.sound:
		playSound(args)

	loop.run()

def main():
	parser = argparse.ArgumentParser(prog='notification.py', description='Notifications with sound effects and actions.')
	parser.add_argument('summary')
	parser.add_argument('message')
	parser.add_argument('--icon', default='')
	parser.add_argument('--app-name', dest='appName', default='Event Calendar')
	parser.add_argument('--sound')
	parser.add_argument('--loop')
	parser.add_argument('--timeout', type=int, default=Notify.EXPIRES_DEFAULT)
	parser.add_argument('--action', dest='actions', action='append')
	parser.add_argument('--metadata')


	try:
		args = parser.parse_args()
		notify(args)
	except KeyboardInterrupt:
		pass
	except Exception as e:
		sys.stderr.write('{}\n'.format(e))
		parser.print_help()

def test():
	notify(argparse.Namespace(
		summary='Summary',
		message='Message',
		icon='plasma',
		appName='Plasma',
		sound='complete',
		loop=False,
		actions=[
			'ok,Ok',
			'cancel,Cancel',
		],
	))

if __name__ == '__main__':
	main()
	# test()


