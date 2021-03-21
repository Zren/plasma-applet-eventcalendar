import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "Shared.js" as Shared
import "./weather/WeatherApi.js" as WeatherApi

Item {
	id: meteogramView
	width: 400
	height: 100
	property bool clock24h: appletConfig.clock24h
	property int visibleDuration: 9
	property bool showIconOutline: false
	property bool showGridlines: true
	property alias xAxisScale: graph.xAxisScale
	property int xAxisLabelEvery: 1
	property alias rainUnits: graph.rainUnits

	property bool populated: false

	onClock24hChanged: {
		graph.gridData = formatXAxisLabels(graph.gridData)
		graph.update()
	}

	onVisibleDurationChanged: {
		graph.update()
	}

	Rectangle {
		visible: typeof root === 'undefined'
		color: PlasmaCore.ColorScope.backgroundColor
		anchors.fill: parent
	}

	Connections {
		target: appletConfig
		onMeteogramTextColorChanged: graph.update()
		onMeteogramScaleColorChanged: graph.update()
		onMeteogramPositiveTempColorChanged: graph.update()
		onMeteogramNegativeTempColorChanged: graph.update()
		onMeteogramPrecipitationRawColorChanged: graph.update()
	}

	Item {
		id: graph
		anchors.fill: parent

		property int xAxisLabelHeight: 20
		property int xAxisMin: 0
		property int xAxisMax: 10
		property double xAxisScale: 0.333333333333 // 3 lines per data point
		property int yAxisLabelWidth: 30
		property int yAxisMin: -10
		property int yAxisMax: 20
		property int yAxisScale: 2
		property int yAxisScaleCount: 4
		property double yAxisRainMinScale: 2
		property double yAxisRainMax: 2
		property bool showYAxisRainMax: true
		property string rainUnits: 'mm'

		property double freezingPoint: {
			if (plasmoid.configuration.weatherUnits === "kelvin") {
				return 273.15 // https://en.wikipedia.org/wiki/Kelvin
			} else if (plasmoid.configuration.weatherUnits === "imperial") {
				return 32 // https://en.wikipedia.org/wiki/Fahrenheit
			} else { // "metric"
				return 0
			}
		}

		property int gridX: yAxisLabelWidth
		property int gridX2: width
		property int gridWidth: gridX2 - gridX
		property int gridY: 5
		property int gridY2: height - xAxisLabelHeight
		property int gridHeight: gridY2 - gridY

		property var gridData: []
		property var yData: []

		onGridDataChanged: {
			xAxisMax = Math.max(1, gridData.length - 1)

			yData = []
			var yDataMin = 0
			var yDataMax = 1
			yAxisRainMax = yAxisRainMinScale
			for (var i = 0; i < gridData.length; i++) {
				var y = gridData[i].y
				yData.push(y)
				if (i === 0 || y < yDataMin) {
					yDataMin = y
				}
				if (i === 0 || y > yDataMax) {
					yDataMax = y
				}
				if (rainUnits == 'mm') {
					if (gridData[i].precipitation > yAxisRainMax) {
						yAxisRainMax = Math.ceil(gridData[i].precipitation)
					}
				}
			}
			if (rainUnits === '%') {
				yAxisRainMax = 100
			}

			yAxisScale = Math.ceil((yDataMax-yDataMin) / (yAxisScaleCount))
			yAxisMin = Math.floor(yDataMin)
			yAxisMax = Math.ceil(yDataMax)
		}

		function iconsInRange(gData, s, e) {
			var out = [];
			for (var i = Math.max(0, s); i <= e && i < gData.length; i++) {
				out.push(gData[i].weatherIcon)
			}
			return out
		}

		function getAggregatedIcon(gData, s, e) {
			return WeatherApi.getMostSevereIcon(iconsInRange(gData, s, e))
		}

		function updateGridItemAreas() {
			var areas = [];
			// Skip the first gridItem since it's area starts at the edge of the grid.
			for (var i = 1; i < gridData.length; i++) {
				var a = graph.gridPoint(i-2, graph.yAxisMin)
				var b = graph.gridPoint(i-1, graph.yAxisMin)
				var area = {}
				area.areaX = a.x
				area.areaY = a.y
				area.areaWidth = b.x - a.x
				area.areaHeight = graph.gridHeight
				// console.log(JSON.stringify(area))
				area.gridItem = gridData[i]
				if (area.areaWidth <= appletConfig.meteogramColumnWidth) {
					// Show icon representing 3 hours.
					area.showIcon = (i-1) % 3 === 1 // .X..X..X.
					area.aggregratedIcon = getAggregatedIcon(gridData, i-1, i+1)
				} else {
					area.showIcon = true
					area.aggregratedIcon = area.gridItem.weatherIcon
				}
				areas.push(area)
			}
			// console.log(JSON.stringify(areas))
			gridDataAreas.model = areas
		}


		function gridPoint(x, y) {
			return {
				x: (x - xAxisMin) / (xAxisMax - xAxisMin) * gridWidth + gridX,
				y: gridHeight - (y - yAxisMin) / (yAxisMax - yAxisMin) * gridHeight + gridY,
			}
		}

		function update() {
			gridCanvas.requestPaint()
			// console.log('updated')
		}

		Item {
			id: layers
			anchors.fill: parent

			Canvas {
				id: gridCanvas
				anchors.fill: parent
				canvasSize.width: parent.width
				canvasSize.height: parent.height
				contextType: '2d'

				function drawLine(x1, y1, x2, y2) {
					var p1 = graph.gridPoint(x1, y1)
					var p2 = graph.gridPoint(x2, y2)
					context.moveTo(p1.x, p1.y)
					context.lineTo(p2.x, p2.y)
					context.stroke()
					// console.log(JSON.stringify(p1), JSON.stringify(p2))
				}

				// https://stackoverflow.com/questions/7054272/how-to-draw-smooth-curve-through-n-points-using-javascript-html5-canvas
				function drawCurve(path) {
					if (path.length < 3) return

					var gridPath = []
					for (var i = 0; i < path.length; i++) {
						var item = path[i]
						var p = graph.gridPoint(item.x, item.y)
						gridPath.push(p)
					}

					context.beginPath()
					context.moveTo(gridPath[0].x, gridPath[0].y)

					// curve from 1 .. n-2
					for (var i = 1; i < path.length - 2; i++) {
						var xc = (gridPath[i].x + gridPath[i+1].x) / 2
						var yc = (gridPath[i].y + gridPath[i+1].y) / 2
						
						context.quadraticCurveTo(gridPath[i].x, gridPath[i].y, xc, yc)
					}
					var n = path.length-1
					context.quadraticCurveTo(gridPath[n-1].x, gridPath[n-1].y, gridPath[n].x, gridPath[n].y)

					context.stroke()
				}

				onPaint: {
					if (!context) {
						var ctx = gridCanvas.getContext("2d")
					}
					if (!context) return
					context.reset()
					if (graph.gridData.length < 2) return
					if (graph.yAxisMin === graph.yAxisMax) return

					// rain
					graph.showYAxisRainMax = false
					var gridDataAreaWidth = 0
					for (var i = 1; i < graph.gridData.length; i++) {
						var item = graph.gridData[i]
						// console.log(i, item, item.precipitation, graph.yAxisRainMax)
						if (item.precipitation) {
							graph.showYAxisRainMax = true
							var rainY = Math.min(item.precipitation, graph.yAxisRainMax) / graph.yAxisRainMax
							// console.log('rainY', i, rainY)
							var a = graph.gridPoint(i-1, graph.yAxisMin)
							var b = graph.gridPoint(i, graph.yAxisMin)
							var h = rainY * graph.gridHeight
							gridDataAreaWidth = b.x-a.x
							context.fillStyle = appletConfig.meteogramPrecipitationColor
							context.fillRect(a.x, a.y, gridDataAreaWidth, -h)
						}
					}

					// yAxis scale
					for (var y = graph.yAxisMin; y <= graph.yAxisMax; y += graph.yAxisScale) {
						context.strokeStyle = appletConfig.meteogramScaleColor
						context.lineWidth = 1
						drawLine(graph.xAxisMin, y, graph.xAxisMax, y)

						// yAxis label: temp
						var p = graph.gridPoint(graph.xAxisMin, y)
						context.fillStyle = appletConfig.meteogramTextColor
						context.font = "12px sans-serif"
						context.textAlign = 'end'
						var labelText = y + '°'
						context.fillText(labelText, p.x - 2, p.y + 6)
					}

					// xAxis scale
					for (var x = graph.xAxisMin; x <= graph.xAxisMax; x += graph.xAxisScale) {
						context.strokeStyle = appletConfig.meteogramScaleColor
						context.lineWidth = 1
						drawLine(x, graph.yAxisMin, x, graph.yAxisMax)
					}
					for (var i = 0; i < graph.gridData.length; i++) {
						var item = graph.gridData[i]
						var p = graph.gridPoint(i, graph.yAxisMin)

						context.fillStyle = appletConfig.meteogramTextColor
						context.font = "12px sans-serif"
						context.textAlign = 'center'

						if (item.xLabel) {
							context.fillText(item.xLabel, p.x, p.y + 12 + 2)
						}
					}


					// temp
					// context.strokeStyle = '#900'
					context.lineWidth = 3
					var path = []
					var pathMinY
					var pathMaxY
					for (var i = 0; i < graph.gridData.length; i++) {
						var item = graph.gridData[i]
						path.push({ x: i, y: item.y })
						if (i === 0 || item.y < pathMinY) pathMinY = item.y
						if (i === 0 || item.y > pathMaxY) pathMaxY = item.y
					}
					
					var pZeroY = graph.gridPoint(0, graph.freezingPoint).y
					var pMaxY = graph.gridPoint(0, pathMinY).y // y axis gets flipped
					var pMinY = graph.gridPoint(0, pathMaxY).y // y axis gets flipped
					var height = pMaxY - pMinY
					var pZeroYRatio = (pZeroY-pMinY) / height
					// console.log(pMinY, pMaxY)
					// console.log(height)
					// console.log(pZeroY, pZeroYRatio)
					if (pZeroYRatio <= 0) {
						context.strokeStyle = appletConfig.meteogramNegativeTempColor
					} else if (pZeroYRatio >= 1) {
						context.strokeStyle = appletConfig.meteogramPositiveTempColor
					} else {
						var gradient = context.createLinearGradient(0, pMinY, 0, pMaxY)
						gradient.addColorStop(pZeroYRatio-0.0001, appletConfig.meteogramPositiveTempColor)
						gradient.addColorStop(pZeroYRatio, appletConfig.meteogramNegativeTempColor)
						context.strokeStyle = gradient
					}
					drawCurve(path)


					// yAxis label: precipitation
					var lastLabelText = ''
					var lastLabelVisible = false
					var lastLabelStaggered = false
					for (var i = 1; i < graph.gridData.length; i++) {
						var item = graph.gridData[i]
						// console.log('label', graph.rainUnits, i, item.precipitation)
						if (item.precipitation && (
							(graph.rainUnits === 'mm' && item.precipitation > 0.3)
							|| (graph.rainUnits === '%')
						)) {
							var labelText = formatPrecipitation(item.precipitation)

							if (labelText == lastLabelText) {
								lastLabelText = labelText
								lastLabelVisible = false
								lastLabelStaggered = false
								continue
							}

							context.fillStyle = appletConfig.meteogramPrecipitationTextColor
							context.font = "12px sans-serif"
							context.strokeStyle = appletConfig.meteogramPrecipitationTextOutlineColor
							context.lineWidth = 3

							var labelWidth = context.measureText(labelText).width
							var p
							// If there isn't enough room
							if (gridDataAreaWidth < labelWidth) { // left align using previous point
								p = graph.gridPoint(i-1, graph.yAxisMin)
								context.textAlign = 'left'
							} else { // otherwise right align
								p = graph.gridPoint(i, graph.yAxisMin)
								context.textAlign = 'end'
							}

							var pY = graph.gridY + 6

							// Stagger the labels so they don't overlap.
							if (gridDataAreaWidth < labelWidth && lastLabelVisible && !lastLabelStaggered) {
								pY += 12 // 12px
								lastLabelStaggered = true
							} else {
								lastLabelStaggered = false
							}
							lastLabelVisible = true
							lastLabelText = labelText

							context.strokeText(labelText, p.x, pY)
							context.fillText(labelText, p.x, pY)
						} else {
							lastLabelText = ''
							lastLabelVisible = false
							lastLabelStaggered = false
						}
					}
					// if (graph.showYAxisRainMax) {
					// 	context.fillStyle = graph.precipitationColor
					// 	context.font = "12px sans-serif"
					// 	context.textAlign = 'end'
					// 	var labelText = graph.yAxisRainMax + 'mm';
					// 	context.strokeStyle = graph.precipitationTextOulineColor;
					// 	context.lineWidth = 3;
					// 	context.strokeText(labelText, graph.gridX2, graph.gridY + 6)
					// 	context.fillText(labelText, graph.gridX2, graph.gridY + 6)
					// }
					

					// Area
					graph.updateGridItemAreas()

					// console.log('painted')
				}

			}


 
			Repeater {
				id: gridDataAreas
				anchors.fill: parent
				model: ListModel {}

				delegate: Rectangle {
					x: modelData.areaX+modelData.areaWidth
					y: modelData.areaY-modelData.areaHeight
					width: modelData.areaWidth
					height: modelData.areaHeight
					// color: ["#880", "#008"][index % 2]
					color: "transparent"

					PlasmaCore.ToolTipArea {
						id: tooltip
						anchors.fill: parent
						icon: modelData.gridItem.weatherIcon
						mainText: modelData.gridItem.tooltipMainText
						subText: modelData.gridItem.tooltipSubText
						location: PlasmaCore.Types.BottomEdge
					}

					FontIcon {
						id: weatherIcon
						visible: modelData.showIcon
						anchors.centerIn: parent
						color: appletConfig.meteogramIconColor
						source: modelData.aggregratedIcon
						height: appletConfig.meteogramIconSize
						opacity: tooltip.containsMouse ? 0.1 : 1
						showOutline: meteogramView.showIconOutline
					}

					Component.onCompleted: {
						// console.log(x, y)
					}
				}

			}


		}
	}

	Component.onCompleted: {
		graph.update()
	}

	function parseWeatherForecast(currentWeatherData, data) {
		// console.log(JSON.stringify(data, null, '\t'))
		var gData = []

		function parseHourlyWeatherItem(item) {
			// console.log('parseHourlyWeatherItem', JSON.stringify(item))
			var tooltipSubText = item.description
			if (item.precipitation) {
				tooltipSubText += ' (' + formatPrecipitation(item.precipitation) + ')'
			}
			tooltipSubText += '<br>' + item.temp + '°'

			return {
				y: item.temp,
				xTimestamp: item.dt * 1000,
				precipitation: item.precipitation,
				tooltipMainText: new Date(item.dt * 1000),
				tooltipSubText: tooltipSubText,
				weatherIcon: item.iconName || 'question',
			}
		}

		if (currentWeatherData) {
			gData.push(parseHourlyWeatherItem(currentWeatherData))
		} else {
			if (data.list.length > 0) {
				gData.push({
					y: data.list[0].temp,
					xTimestamp: Date.now(),
					precipitation: 0,
				})
			}
		}

		for (var i = 0; i < data.list.length; i++) {
			var item = data.list[i]
			gData.push(parseHourlyWeatherItem(item))
		}

		// console.log(JSON.stringify(gData, null, '\t'))

		// Only forcast next _ hours
		gData = gData.slice(0, Math.max(3, Math.ceil(meteogramView.visibleDuration * meteogramView.xAxisScale) + 1))

		// Format xAxis Labels
		gData = formatXAxisLabels(gData)

		graph.gridData = gData
		graph.update()
		meteogramView.populated = true
	}

	function formatXAxisLabels(gData) {
		for (var i = 0; i < gData.length; i++) {
			var firstOrLast = i === 0 || i === gData.length-1
			var labelSkipped = i % Math.ceil(meteogramView.xAxisLabelEvery) != 0
			// if (i != 0 && i != gData.length-1) {
			if (!firstOrLast && !labelSkipped) {
				var date = new Date(gData[i].xTimestamp)
				var hour = date.getHours()
				var label = ''
				if (clock24h) {
					label += hour
				} else {
					// 12 hour clock
					// (3am = 3) (11pm = 11p)
					label += hour % 12 === 0 ? 12 : hour % 12
					label += (hour < 12 ? '' : 'p')
				}
				gData[i].xLabel = label
			} else {
				gData[i].xLabel = ''
			}
		}
		return gData
	}

	function formatDecimal(x, afterDecimal) {
		return x >= 1 ? Math.round(x) : x.toFixed(afterDecimal)
	}
	function formatPrecipitation(value) {
		var valueText = formatDecimal(value, 1)
		if (graph.rainUnits === 'mm') {
			return i18n("%1mm", valueText)
		} else { // rainUnits == '%'
			return i18n('%1%', valueText) // Not translated as we use ''
		}
	}
}
