import os, sys
import datetime
from icalendar import Calendar
import json
import urllib.parse
import urllib.request

debugging=False
def debug(*args):
	if debugging:
		print(*args)

def dateToJson(dateObj):
	if isinstance(dateObj.dt, datetime.datetime):
		# { "dateTime": "2010-08-04T02:44:20.063Z" }
		dateTimeStr = dateObj.dt.isoformat() # 2014-10-02T18:00:00+00:00
		return { 'dateTime': dateTimeStr }
	else: # datetime
		# { "date": "2010-08-04" }
		dateStr = dateObj.dt.isoformat()
		return { 'date': dateStr }

def eventsToJson(eventList=None, indent=4):
	if eventList is None:
		eventList = list(self.cal.walk('vevent'))

	data = {}
	data['items'] = []
	for event in eventList:
		item = {}

		item['kind'] = 'calendar#event'
		item['etag'] = '\"0123456789012345\"'
		item['iCalUID'] = event['UID']
		item['id'] = "ics_{}_{}_{}".format(item['iCalUID'],
			event['DTSTART'].dt.isoformat(),
			event['DTEND'].dt.isoformat()
		)
		
		item['status'] = 'confirmed' # TODO: event['STATUS']
		item['htmlLink'] = ''
		if 'CREATED' in event:
			item['created'] = event['CREATED'].dt.isoformat()
		if 'LAST-MODIFIED' in event:
			item['updated'] = event['LAST-MODIFIED'].dt.isoformat()

		item['summary'] = event['SUMMARY']
		if 'LOCATION' in event:
			item['location'] = event['LOCATION']

		item['start'] = dateToJson(event['DTSTART'])
		item['end'] = dateToJson(event['DTEND'])
		
		# item['transparency'] = event['TRANSP'] # 'transparent'
		# item['recurringEventId'] = ''

		data['items'].append(item)

	return json.dumps(data, indent=indent)

def ensureDateTime(dt):
	if isinstance(dt, datetime.date):
		return datetime.datetime.combine(dt, datetime.time.min)
	else:
		return dt

def eventWithin(event, startTime, endTime):
	eventStart = ensureDateTime(event['DTSTART'].dt)
	eventEnd = ensureDateTime(event['DTEND'].dt)
	startTime = ensureDateTime(startTime)
	endTime = ensureDateTime(endTime)
	# If it starts before endTime and it ends after startTime
	return eventStart <= endTime and eventEnd >= startTime

class CalendarManager:
	def __init__(self, url):
		self.url = url
		self.cal = None
	
	def read(self):
		with urllib.request.urlopen(self.url) as sock:
			text = sock.read()
			self.cal = Calendar.from_ical(text)

	@property
	def events(self):
		return self.cal.walk('vevent')

	def query(self, startTime, endTime):
		for event in self.events:
			if eventWithin(event, startTime, endTime):
				debug("within", event['DTSTART'].dt, event['DTEND'].dt)
				yield event
			else:
				debug("out", event['DTSTART'].dt, event['DTEND'].dt)


	def toJson(self):
		return eventsToJson(self.events)


def parseDate(dateStr):
	return datetime.datetime.strptime(dateStr, '%Y-%m-%d')

def argparse_date(s):
	try:
		return parseDate(s)
	except ValueError:
		msg = "Not a valid date: '{0}'.".format(s)
		raise argparse.ArgumentTypeError(msg)

if __name__ == '__main__':
	import argparse

	parser = argparse.ArgumentParser(description="calculate X to the power of Y")
	parser.add_argument("--url", type=str, required=True, help="The .ics file to read/write")
	subparsers = parser.add_subparsers(help='Commands', dest='subcommand')

	query = subparsers.add_parser('query')
	query.add_argument("startTime", type=argparse_date, help="Inclusive starting date in YYYY-MM-DD format")
	query.add_argument("endTime", type=argparse_date, help="Inclusive ending date in YYYY-MM-DD format")

	add = subparsers.add_parser('add')

	delete = subparsers.add_parser('delete')

	# debugging = True
	if debugging:
		args = parser.parse_args(['--url', 'basic.ics', 'query', '2016-09-15', '2016-09-16'])
	else:
		args = parser.parse_args()

	url = urllib.parse.urlparse(args.url, scheme='file').geturl()

	manager = CalendarManager(url)
	if args.subcommand == 'query':
		manager.read()
		eventList = manager.query(args.startTime, args.endTime)
		print(eventsToJson(eventList))

	elif args.subcommand == 'add':
		pass
	elif args.subcommand == 'delete':
		pass



