import org.kde.plasma.core 2.1 as PlasmaCore

PlasmaCore.SortFilterModel {
    filterCallback: function(source_row, value) {
        var idx = sourceModel.index(source_row, 0);
        return !sourceModel.data(idx, sourceModel.role("VirtualStream"));
    }
}
