import QtQuick 2.0
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

PlasmaNM.NetworkStatus {
	id: plasmaNMStatus
	// onActiveConnectionsChanged: logger.debug('NetworkStatus.activeConnections', activeConnections)
	onNetworkStatusChanged: logger.debug('NetworkStatus.networkStatus', networkStatus)
	Component.onCompleted: {
		// logger.debug('NetworkStatus.activeConnections', activeConnections)
		logger.debug('NetworkStatus.networkStatus', networkStatus)
	}
}
