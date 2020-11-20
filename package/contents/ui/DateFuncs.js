.pragma library

/****************************************************************************
**
** Copyright (C) 2020 Chris Holland
** Copyright (C) 2020 The Qt Company Ltd.
** Copyright (C) 2016 Intel Corporation.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the QtCore module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

// https://github.com/qt/qtbase/blob/dev/src/corelib/time/qgregoriancalendar.cpp#L123
function getJulian(year, month, day) {
	// Math from The Calendar FAQ at http://www.tondering.dk/claus/cal/julperiod.php
	// This formula is correct for all julian days, when using mathematical integer
	// division (round to negative infinity), not c++11 integer division (round to zero)
	var a = month < 3 ? 1 : 0
	var y = year + 4800 - a
	var m = month + 12 * a - 3
	var jd = day + Math.floor((153 * m + 2) / 5) - 32045 + 365 * y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400)
	// console.log(year, month, day, a, y, m, jd)
	return jd
}

// https://github.com/qt/qtbase/blob/dev/src/corelib/time/qdatetime.cpp#L641
function getDayOfYear(date) {
	var year = date.getFullYear()
	var month = date.getMonth() + 1
	var day = date.getDate()
	var first = getJulian(year, 1, 1)
	var jd = getJulian(year, month, day)
	var doy = jd - first + 1
	// console.log(year, month, day, first, jd, doy)
	return doy
}

// https://github.com/qt/qtbase/blob/dev/src/corelib/time/qdatetime.cpp#L730
function getWeekNumber(date) {
	var dayOfWeek = date.getDay()
	// The Thursday of the same week determines our answer:
	var thursday = new Date(date)
	thursday.setDate(thursday.getDate() + 4 - dayOfWeek)
	// Week n's Thurs's DOY has 1 <= DOY - 7*(n-1) < 8, so 0 <= DOY + 6 - 7*n < 7:
	var week = Math.floor((getDayOfYear(thursday) + 6) / 7)
	// console.log(date, week)
	return week
}
