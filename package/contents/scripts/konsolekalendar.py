#!/bin/python3

import os
import sys
import subprocess
import datetime
import csv
from pprint import pprint
from collections import namedtuple
import time

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

	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr)
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
class KonsoleKalendarEvent(KonsoleKalendarEventTuple):
	def isoStartDate(self):
		# LC_TIME=C format: "Wednesday, 29 July 2020"
		startDate = datetime.datetime.strptime(self.startDate, '%A, %d %B %Y')
		return startDate.date().isoformat()
	def isoStartTime(self):
		if self.startTime:
			# LC_TIME=C format: "08:00:00 EDT"
			startTime = datetime.time.strptime(self.startTime, '%H:%M:%S %Z')
			return startTime.isoformat()
		else:
			return self.startTime

def parseEventDateTime(startDate, startTime):
	# "Wednesday, 29 July 2020"
	isoStartDate = datetime.datetime.strptime(startDate, '%A, %d %B %Y')
	isoStartDate = isoStartDate.date().isoformat()
	if startTime:
		# "08:00:00 EDT"
		isoStartTime = datetime.time.strptime(startTime, '%H:%M:%S %Z')
		isoStartTime = startTime.isoformat()
		return isoStartDate, isoStartTime
	else:
		return isoStartDate, event.startTime

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
		print(proc.returncode, proc.stderr)
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
	for event in eventList:
		if event.isoStartDate() == startDate \
		and event.isoStartTime() == startTime \
		and event.summary == summary \
		and event.description == description:
			return event
	return None

def konsolekalendarChange(eventUid, **kwargs):
	cmd = [
		'konsolekalendar',
		'--change',
		'--uid',
		eventUid,
		
	]
	env = dict(os.environ)
	env['LC_TIME'] = 'C' # Use a consistent date format for us to parse
	proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
	if proc.returncode != 0:
		print(proc.returncode, proc.stderr)
		sys.exit(proc.returncode)
	output = proc.stdout.decode('utf-8').rstrip()
	# print(output)


if __name__ == '__main__':
	calendarId = '12'
	eventDate = '2020-07-29'
	eventTime = ''
	eventSummary = 'test_{}'.format(datetime.datetime.now())
	eventDescription = ''
	konsolekalendarAdd(calendarId, eventDate, eventSummary)

	# eventList = konsolekalendarList(calendarId)
	# print()
	# print('eventList', eventList)

	event = konsolekalendarGetEvent(calendarId, eventDate, eventTime, eventSummary, eventDescription)
	print('event', event)
	if event:
		print('event.uid', event.uid)
	else:
		sys.exit(1)
