#!/usr/bin/python3
import os, sys
import argparse
import subprocess

import gi
gi.require_version('GLib', '2.0')
gi.require_version('Notify', '0.7')
from gi.repository import GLib, Notify

def notify(args):
	appName = "Event Calendar"
	sfxProc = None

	#--- Notification
	# https://notify2.readthedocs.io/en/latest/
	loop = GLib.MainLoop()
	Notify.init(appName)
	# print(Notify.get_server_caps())

	n = Notify.Notification.new(
		args.summary,
		args.message,
		icon=args.icon,
	)

	def on_action(notification, action, *user_data):
		print(action, *user_data) # Print to stdout
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
		# Plasma's Notification server doesn't support sounds,
		# the KNotify manually plays sounds instead. So we manually
		# play then with libcanberra in a subprocess.
		sfxCommand = [
			"canberra-gtk-play",
			"--description", appName,
		]

		if args.sound.startswith('/'):
			sfxCommand += ["--file", args.sound]
		else:
			sfxCommand += ["--id", args.sound]

		if args.loop:
			sfxCommand += ["--loop", args.loop]

		sfxProc = subprocess.Popen(sfxCommand)

	loop.run()

def main():
	parser = argparse.ArgumentParser(prog='notification.py', description='Notifications with sound effects and actions.')
	parser.add_argument('summary')
	parser.add_argument('message')
	parser.add_argument('--icon', default='')
	parser.add_argument('--app-name', dest='appName', default='Event Calendar')
	parser.add_argument('--sound')
	parser.add_argument('--loop')
	parser.add_argument('--action', dest='actions', action='append')
	parser.add_argument('--metadata')


	try:
		args = parser.parse_args()
		notify(args)
	except KeyboardInterrupt:
		pass
	except Exception as e:
		print(e)
		parser.print_help()


if __name__ == '__main__':
	main()


