import QtQuick 2.0
import org.kde.plasma.core 2.1 as PlasmaCore

PlasmaCore.SortFilterModel {
    id: dynamicFilterModel

    function doFiltering(source_row, value) {
        // console.log('filterCallback.doFiltering', source_row, value)
        var idx = sourceModel.index(source_row, 0);
        var virtualStream = sourceModel.data(idx, sourceModel.role("VirtualStream"));
        // console.log('\t', 'virtualStream', virtualStream)
        if (virtualStream && !plasmoid.configuration.showVirtualStreams)
            return false;

        // var name = sourceModel.data(idx, sourceModel.role("Name"));
        // console.log('filterCallback', source_row, value, name)
        // if (name == "Echo-Cancel Source Stream" || name == "Echo-Cancel Sink Stream") // not localized
        //     return false;

        return true;
    }

    function emptyFilter(source_row, value) {
        // console.log('filterCallback.emptyFilter', source_row, value)
        return false
    }

    filterCallback: dynamicFilterModel.doFiltering

    property var configConnnection: Connections {
        target: plasmoid.configuration
        onShowVirtualStreamsChanged: {
            // console.log('onShowVirtualStreamsChanged', plasmoid.configuration.showVirtualStreams)

            // Manually trigger setFilterCallback() which will invalidate the filter.
            dynamicFilterModel.filterCallback = dynamicFilterModel.emptyFilter
            dynamicFilterModel.filterCallback = dynamicFilterModel.doFiltering
            // console.log('dynamicFilterModel.filterCallback', dynamicFilterModel.filterCallback)
        }
    }
}
