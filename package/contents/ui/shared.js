.import "utils.js" as Utils

function openGoogleCalendarNewEventUrl(date) {
    function dateString(year, month, day) {
        var s = '' + year;
        s += (month < 10 ? '0' : '') + month;
        s += (day < 10 ? '0' : '') + day;
        return s;
    }

    var nextDay = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)

    var url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
    var startDate = dateString(date.getFullYear(), date.getMonth() + 1, date.getDate())
    var endDate = dateString(nextDay.getFullYear(), nextDay.getMonth() + 1, nextDay.getDate())
    url += '&dates=' + startDate + '/' + endDate
    Qt.openUrlExternally(url)
}
