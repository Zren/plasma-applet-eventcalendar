.pragma library

// Since we use the ErrorType enum outside a single class and it's
// dependencies, we can't use QML's enums.

var NoError = 0
var NetworkError = 1
var ClientError = 2
var ServerError = 3
var UnknownError = 4
