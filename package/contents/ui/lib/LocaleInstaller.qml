import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons

ConfigSection {
	id: lacaleInstaller
	visible: langCode != "en" && isTranslated

	property var locale: Qt.locale("de")
	property string localeCode: locale.name
	property string langCode: localeCode.substr(0, 2)
	property string countryCode: localeCode.length >= 5 ? localeCode.substr(3, 2).toLowerCase() : ''
	property bool isTranslated: false
	property bool isInstalled: false

	property string metadataUrl: plasmoid.file("", "../metadata.desktop")
	property string packageRootUrl: metadataUrl.substr(0, metadataUrl.length - "contents//../metadata.desktop".length)
	property string packageLocaleDir: packageRootUrl + "locale"
	property string packageName // TODO: Parse the metadata file for the name.

	FolderListModel {
		folder: packageLocaleDir
		nameFilters: [ "*.po" ]
		onCountChanged: {
			// console.log('poFolder', folder)
			for (var i = 0; i < count; i++) {
				var fileName = get(i, 'fileName')
				// console.log(i, fileName)
				var poLangCode = fileName.substr(0, 2)
				if (poLangCode == lacaleInstaller.langCode) {
					lacaleInstaller.isTranslated = true
				}
			}
		}
	}

	// property string shareDir: packageRootUrl.substr(0, packageRootUrl.length - "plasma/plasmoids//".length - packageName.length)
	property string shareDir: 'file:///home/' + kuser.loginName + '/.local/share/'
	property string localeDir: shareDir  + "locale/" + langCode + "/LC_MESSAGES/"

	// onMetadataUrlChanged: console.log('metadataUrl', metadataUrl)
	// onPackageRootUrlChanged: console.log('packageRootUrl', packageRootUrl)
	// onShareDirChanged: console.log('shareDir', shareDir)
	// onLocaleDirChanged: console.log('localeDir', localeDir)
	// onPackageLocaleDirChanged: console.log('packageLocaleDir', packageLocaleDir)

	KCoreAddons.KUser {
		id: kuser
	}

	FolderListModel {
		folder: localeDir
		nameFilters: [ "*.mo" ]
		onCountChanged: {
			// console.log('moFolder', folder)
			var packageFilename = "plasma_applet_" + packageName + ".mo"
			for (var i = 0; i < count; i++) {
				var fileName = get(i, 'fileName')
				// console.log(i, fileName)
				if (fileName == packageFilename) {
					lacaleInstaller.isInstalled = true
				}
			}
		}
	}

	property string installCommand: "x-terminal-emulator -e \'sh -c \"(cd " + packageLocaleDir + " && sh ./install)\"\'"

	PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]
			exited(exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
		}
		function exec(cmd) {
			connectSource(cmd)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
	}

	RowLayout {
		// FreeDesktop mentions flags use "flag-ca" format, but breeze-icons doesn't ship with any.
		// KDE ships flag icons with kf5, seen in kcmformats:
		// https://github.com/KDE/plasma-desktop/blob/master/kcms/formats/kcmformats.cpp
		PlasmaCore.IconItem {
			visible: countryCode && valid
			property string flagUrl: "/usr/share/kf5/locale/countries/" + countryCode + "/flag.png"
			source: countryCode ? flagUrl : ""
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			Label {
				Layout.fillWidth: true
				text: locale.nativeLanguageName + " / " + locale.nativeCountryName
			}
			Label {
				Layout.fillWidth: true
				text: "Translation installation will restart plasmashell"
				opacity: 0.7
			}
		}

		Button {
			enabled: packageLocaleDir
			iconName: isInstalled ? "package-reinstall" : "package-install"
			text: isInstalled ? "Reinstall" : "Install"
			onClicked: {
				console.log('translationInstallCommand:', installCommand)
				if (packageLocaleDir) {
					executable.exec(installCommand)
				}
			}

			Connections {
				target: executable
				onExited: {
					// The applet config dialog will remain open luckily, but it will
					// not be linked to the newly launched plasmashell instance, so
					// we should close the dialog since the other config options will
					// do nothing.
					configDialog.close()
				}
			}
		}
	}
}
