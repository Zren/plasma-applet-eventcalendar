#include "plugin.h"
#include "volumepeaks.h"

#include <QtQml>

void Plugin::registerTypes(const char* uri) {
    qmlRegisterType<VolumePeaks>(uri, 1, 0, "VolumePeaks");
}
