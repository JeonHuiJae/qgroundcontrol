import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Vehicle           1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.SettingsManager   1.0
import QGroundControl.Controllers       1.0

// Editor for Mission Settings
Rectangle {
    id:                 valuesRect
    width:              availableWidth
    height:             valuesColumn.height + (_margin * 2)
    color:              qgcPal.windowShadeDark
    visible:            missionItem.isCurrentItem
    radius:             _radius

    property var    _masterControler:               masterController
    property var    _missionController:             _masterControler.missionController
    property var    _missionVehicle:                _masterControler.controllerVehicle
    property bool   _vehicleHasHomePosition:        _missionVehicle.homePosition.isValid
    property bool   _offlineEditing:                _missionVehicle.isOfflineEditingVehicle
    property bool   _enableOfflineVehicleCombos:    _offlineEditing && _noMissionItemsAdded
    property bool   _showCruiseSpeed:               !_missionVehicle.multiRotor
    property bool   _showHoverSpeed:                _missionVehicle.multiRotor || _missionVehicle.vtol
    property bool   _multipleFirmware:              QGroundControl.supportedFirmwareCount > 2
    property bool   _multipleVehicleTypes:          QGroundControl.supportedVehicleCount > 1
    property real   _fieldWidth:                    ScreenTools.defaultFontPixelWidth * 16
    property bool   _mobile:                        ScreenTools.isMobile
    property var    _savePath:                      QGroundControl.settingsManager.appSettings.missionSavePath
    property var    _fileExtension:                 QGroundControl.settingsManager.appSettings.missionFileExtension
    property var    _appSettings:                   QGroundControl.settingsManager.appSettings
    property bool   _waypointsOnlyMode:             QGroundControl.corePlugin.options.missionWaypointsOnly
    property bool   _showCameraSection:             (_waypointsOnlyMode || QGroundControl.corePlugin.showAdvancedUI) && !_missionVehicle.apmFirmware
    property bool   _simpleMissionStart:            QGroundControl.corePlugin.options.showSimpleMissionStart
    property bool   _showFlightSpeed:               !_missionVehicle.vtol && !_simpleMissionStart && !_missionVehicle.apmFirmware

    readonly property string _firmwareLabel:    qsTr("펌웨어")
    readonly property string _vehicleLabel:     qsTr("드론")
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2

    QGCPalette { id: qgcPal }
    QGCFileDialogController { id: fileController }

    Column {
        text:       qsTr("경유지 고도")
        id:                 valuesColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        spacing:            _margin

        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  ScreenTools.defaultFontPixelWidth
            rowSpacing:     columnSpacing
            columns:        2

            QGCLabel {
                text:       qsTr("경유지 고도")
            }
            FactTextField {
                fact:               QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                Layout.fillWidth:   true
            }

            QGCCheckBox {
                id:         flightSpeedCheckBox
                text:       qsTr("비행 속도")
                visible:    _showFlightSpeed
                checked:    missionItem.speedSection.specifyFlightSpeed
                onClicked:   missionItem.speedSection.specifyFlightSpeed = checked
            }
            FactTextField {
                Layout.fillWidth:   true
                fact:               missionItem.speedSection.flightSpeed
                visible:            _showFlightSpeed
                enabled:            flightSpeedCheckBox.checked
            }
        }

        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        !_simpleMissionStart

            CameraSection {
                id:         cameraSection
                checked:    !_waypointsOnlyMode && missionItem.cameraSection.settingsSpecified
                visible:    _showCameraSection
            }

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                text:                   qsTr("해당 카메라 명령은 미션이 시작되는 즉시 수행됩니다.")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter다
                font.pointSize:         ScreenTools.smallFontPointSize
                visible:                _showCameraSection && cameraSection.checked
            }

            SectionHeader {
                id:             vehicleInfoSectionHeader
                anchors.left:   parent.left
                anchors.right:  parent.right
                text:           qsTr("드론 정보")
                visible:        _offlineEditing && !_waypointsOnlyMode
                checked:        false
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  ScreenTools.defaultFontPixelWidth
                rowSpacing:     columnSpacing
                columns:        2
                visible:        vehicleInfoSectionHeader.visible && vehicleInfoSectionHeader.checked

                QGCLabel {
                    text:               _firmwareLabel
                    Layout.fillWidth:   true
                    visible:            _multipleFirmware
                }
                FactComboBox {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingFirmwareType
                    indexModel:             false
                    Layout.preferredWidth:  _fieldWidth
                    visible:                _multipleFirmware
                    enabled:                _enableOfflineVehicleCombos
                }

                QGCLabel {
                    text:               _vehicleLabel
                    Layout.fillWidth:   true
                    visible:            _multipleVehicleTypes
                }
                FactComboBox {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingVehicleType
                    indexModel:             false
                    Layout.preferredWidth:  _fieldWidth
                    visible:                _multipleVehicleTypes
                    enabled:                _enableOfflineVehicleCombos
                }

                QGCLabel {
                    text:               qsTr("크루즈 속도")
                    visible:            _showCruiseSpeed
                    Layout.fillWidth:   true
                }
                FactTextField {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingCruiseSpeed
                    visible:                _showCruiseSpeed
                    Layout.preferredWidth:  _fieldWidth
                }

                QGCLabel {
                    text:               qsTr("호버 속도")
                    visible:            _showHoverSpeed
                    Layout.fillWidth:   true
                }
                FactTextField {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingHoverSpeed
                    visible:                _showHoverSpeed
                    Layout.preferredWidth:  _fieldWidth
                }
            } // GridLayout

            SectionHeader {
                id:             plannedHomePositionSection
                anchors.left:   parent.left
                anchors.right:  parent.right
                text:           qsTr("시작 위치 고도")
                visible:        !_vehicleHasHomePosition
                checked:        false
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        plannedHomePositionSection.checked && !_vehicleHasHomePosition

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  ScreenTools.defaultFontPixelWidth
                    rowSpacing:     columnSpacing
                    columns:        2

                    QGCLabel {
                        text: qsTr("고도")
                    }
                    FactTextField {
                        fact:               missionItem.plannedHomePositionAltitude
                        Layout.fillWidth:   true
                    }
                }

                QGCLabel {
                    width:                  parent.width
                    wrapMode:               Text.WordWrap
                    font.pointSize:         ScreenTools.smallFontPointSize
                    text:                   qsTr("실제 위치는 드론 비행 시 설정됩니다.")
                    horizontalAlignment:    Text.AlignHCenter
                }

                QGCButton {
                    text:                       qsTr("맵 중심에 시작 위치 지정")
                    onClicked:                  missionItem.coordinate = map.center
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }
        } // Column
    } // Column
} // Rectangle
