set(yolo_SRC
    contents/ui/Header.qml
    contents/ui/main.qml

    contents/ui/ListItemBase.qml

    contents/ui/StreamListItemBase.qml
    contents/ui/SinkInputListItem.qml
    contents/ui/SourceOutputListItem.qml

    contents/ui/DeviceListItemBase.qml
    contents/ui/SinkListItem.qml
    contents/ui/SourceListItem.qml
)
plasma_install_package(. org.kde.plasma.volume)
add_custom_target(QmlFiles ALL echo SOURCES ${yolo_SRC})

