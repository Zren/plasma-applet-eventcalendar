import org.kde.plasma.core 2.1 as PlasmaCore

PlasmaCore.SortFilterModel {
    filterCallback: function(source_row, value) {
        // console.log('filterCallback', source_row, value)
        var idx = sourceModel.index(source_row, 0);
        var virtualStream = sourceModel.data(idx, sourceModel.role("VirtualStream"));
        // console.log('\t', 'virtualStream', virtualStream)
        if (virtualStream)
            return false;

        // var name = sourceModel.data(idx, sourceModel.role("Name"));
        // console.log('filterCallback', source_row, value, name)
        // if (name == "Echo-Cancel Source Stream" || name == "Echo-Cancel Sink Stream") // not localized
        //     return false;

        return true;
    }
}
