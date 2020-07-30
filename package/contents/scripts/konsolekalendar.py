#!/bin/python3

import os
import sys
import subprocess
from datetime import datetime, timedelta
import csv
from pprint import pprint
from collections import namedtuple

def konsolekalendarAdd(calendarId, dateTime, text):
	startDate = dateTime
	startTime = ''
	endDate = ''
	endTime = ''
	summary = text
	description = ''
	location = ''
	cmd = [
		'konsolekalendar',
		'--verbose',
		'--add',
		'--calendar',
		calendarId,
	]
	if startDate:
		cmd += ['--date', startDate]
	if startTime:
		cmd += ['--time', startTime]
	if endDate:
		cmd += ['--end-date', endDate]
	if endTime:
		cmd += ['--end-time', endTime]
	if summary:
		cmd += ['--summary', summary]
	if description:
		cmd += ['--description', description]

	if location:
		cmd += ['--location', location]
	else:
		cmd += ['--location', ''] # Prevent it populating with 'Default location'

	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr, proc.stdout)
		sys.exit(proc.returncode)
	output = proc.stdout.decode('utf-8').rstrip()
	print(output)

# Note: date+time is localized.
# "Wednesday, 29 July 2020","","Wednesday, 29 July 2020","","test allday","Default location","","fea4c06b-f818-47b1-bbfe-0dc3eae9dbfb"
# "Wednesday, 29 July 2020","08:00:00 EDT","Wednesday, 29 July 2020","09:00:00 EDT","test time","Default location","description","f605a223-b27f-4049-95bf-20b2deea67d4"
KonsoleKalendarEventTuple = namedtuple('KonsoleKalendarEventTuple', [
	'startDate',
	'startTime',
	'endDate',
	'endTime',
	'summary',
	'location',
	'description',
	'uid',
])
cDateFormat = '%A, %d %B %Y'
cTimeFormat = '%H:%M:%S %Z'

def isoDate(dateStr):
	# LC_TIME=C format: "Wednesday, 29 July 2020"
	dateTime = datetime.strptime(dateStr, cDateFormat)
	return dateTime.date().isoformat()

def isoTime(dateStr, timeStr):
	if timeStr:
		# LC_TIME=C format: "08:00:00 EDT"
		dateTimeFormat = cDateFormat + ' ' + cTimeFormat
		dateTimeStr = dateStr + ' ' + timeStr
		dateTime = datetime.strptime(dateTimeStr, dateTimeFormat)
		return dateTime.time().isoformat()
	else:
		return timeStr

class KonsoleKalendarEvent(KonsoleKalendarEventTuple):
	def isoStartDate(self):
		return isoDate(self.startDate)
	def isoStartTime(self):
		return isoTime(self.startDate, self.startTime)
	def isoEndDate(self):
		# dateTime = datetime.strptime(self.endDate, cDateFormat)
		# dateTime += timedelta(days=1)
		# return dateTime.date().isoformat()
		return isoDate(self.endDate)
	def isoEndTime(self):
		return isoTime(self.endDate, self.endTime)

def konsolekalendarList(calendarId):
	cmd = [
		'konsolekalendar',
		'--all',
		'--calendar',
		calendarId,
		'--export-type',
		'csv',
	]
	env = dict(os.environ)
	env['LC_TIME'] = 'C' # Use a consistent date format for us to parse
	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr, proc.stdout)
		sys.exit(proc.returncode)
	output = proc.stdout.decode('utf-8').rstrip()
	# print(output)
	rows = csv.reader(output.split('\n'))
	rows = list(rows)
	# print()
	# pprint(rows)
	return [KonsoleKalendarEvent(*row) for row in rows]


# PlasmaCalendar API doesn't provide event uids so we need
# to guess which event should be modified or deleted.
def konsolekalendarGetEvent(calendarId, startDate, startTime, summary, description):
	eventList = konsolekalendarList(calendarId)
	selectedEvent = None
	for event in eventList:
		if event.isoStartDate() == startDate \
		and event.isoStartTime() == startTime \
		and event.summary == summary \
		and event.description == description:
			if selectedEvent:
				print('duplicate events')
				print('  selectedEvent', selectedEvent)
				print('  curEvent', event)
				# There's 2 possible events, so return an error code.
				# We don't want to modify or delete the wrong event.
				return None
			else:
				selectedEvent = event
	return selectedEvent

changeKeyMap = {
	'startDate': 'date',
	'startTime': 'time',
	'endDate': 'end-date',
	'endTime': 'end-time',
	# Otherwise key => key
}
def konsolekalendarChange(eventUid, **kwargs):
	cmd = [
		'konsolekalendar',
		'--verbose',
		'--change',
		'--uid',
		eventUid,
	]

	for key, value in kwargs.items():
		cmdArg = '--' + changeKeyMap.get(key, key)
		if not value and (cmdArg == '--time' or cmdArg == '--end-time'):
			continue # Skip
		cmd += [cmdArg, value]
	print('cmd', cmd)

	env = dict(os.environ)
	env['LC_TIME'] = 'C' # Use a consistent date format for us to parse
	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr, proc.stdout)
		sys.exit(proc.returncode)
	output = proc.stdout.decode('utf-8').rstrip()
	print(output)


def konsolekalendarDelete(eventUid):
	cmd = [
		'konsolekalendar',
		'--delete',
		'--uid',
		eventUid,
	]

	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr, proc.stdout)
		sys.exit(proc.returncode)
	output = proc.stdout.decode('utf-8').rstrip()
	print(output)




if __name__ == '__main__':
	calendarId = '12'
	eventDate = '2020-07-29'
	eventTime = ''
	eventSummary = 'test_{}'.format(datetime.now())
	eventDescription = ''
	konsolekalendarAdd(calendarId, eventDate, eventSummary)

	# eventList = konsolekalendarList(calendarId)
	# print()
	# print('eventList', eventList)

	event = konsolekalendarGetEvent(calendarId, eventDate, eventTime, eventSummary, eventDescription)
	print('event', event)
	if event:
		print('event.uid', event.uid)

		# No matter what I do... it will change an "all day" event to an event
		# with both startTime and endTime set at midnight.
		# konsolekalendarChange(event.uid,
		# 	summary=event.summary + '_changed',
		# 	description='New better, longer, and uncut description!',
		# 	# startDate=event.isoStartDate(),
		# 	# startTime=event.isoStartTime(),
		# 	# endDate=event.isoEndDate(),
		# 	# endTime=event.isoEndTime(),
		# )

		konsolekalendarDelete(event.uid)

	else:
		sys.exit(1)
