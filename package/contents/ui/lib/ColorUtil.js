.pragma library
// Version: 2

// https://stackoverflow.com/questions/9733288/how-to-programmatically-calculate-the-contrast-ratio-between-two-colors
// https://www.w3.org/TR/AERT/#color-contrast
function brightness(c) {
	return (c.r*299 + c.g*587 + c.b*114) / 1000
}

// https://www.w3.org/TR/AERT/#color-contrast
function contrast(c1, c2) {
	return Math.max(c1.r, c2.r) - Math.min(c1.r, c2.r) + Math.max(c1.g, c2.g) - Math.min(c1.g, c2.g) + Math.max(c1.b, c2.b) - Math.min(c1.b, c2.b)
}

// https://www.w3.org/TR/AERT/#color-contrast
// w3 mentions 500 using rgb 255 values. QML rgba is 0..1 however, and 500/255=1.96
function hasEnoughContrast(c1, c2) {
	return contrast(c1, c2) >= 1.96
}

function setAlpha(c, a) {
	return Qt.rgba(c.r, c.g, c.b, a)
}

function _interpolate(a, b, t) {
	return (a - b) * t + b
}
// Linear Interpolation from color1 to color2 by a ratio of t.
function lerp(c1, c2, t) {
	var r = _interpolate(c1.r, c2.r, t)
	var g = _interpolate(c1.g, c2.g, t)
	var b = _interpolate(c1.b, c2.b, t)
	var a = _interpolate(c1.a, c2.a, t)
	return Qt.rgba(r, g, b, a)
}
