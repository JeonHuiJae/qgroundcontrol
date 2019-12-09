/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Layouts  1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          telemIcon.width * 1.1

    property bool showIndicator: _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _hasTelemetry:    _activeVehicle ? _activeVehicle.telemetryLRSSI !== 0 : false

    Component {
        id: telemRSSIInfo
        Rectangle {
            width:  telemCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: telemCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            Column {
                id:                 telemCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(telemGrid.width, telemLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent
                QGCLabel {
                    id:             telemLabel
                    text:           qsTr("Telemetry RSSI 상태")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                GridLayout {
                    id:                 telemGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter
                    QGCLabel { text: qsTr("로컬 RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryLRSSI + " dBm"}
                    QGCLabel { text: qsTr("원격 RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryRRSSI + " dBm"}
                    QGCLabel { text: qsTr("RX 오차:") }
                    QGCLabel { text: activeVehicle.telemetryRXErrors }
                    QGCLabel { text: qsTr("교정된 오차:") }
                    QGCLabel { text: activeVehicle.telemetryFixed }
                    QGCLabel { text: qsTr("TX 버퍼:") }
                    QGCLabel { text: activeVehicle.telemetryTXBuffer }
                    QGCLabel { text: qsTr("로컬 노이즈:") }
                    QGCLabel { text: activeVehicle.telemetryLNoise }
                    QGCLabel { text: qsTr("원격 노이즈:") }
                    QGCLabel { text: activeVehicle.telemetryRNoise }
                }
            }
        }
    }
    QGCColoredImage {
        id:                 telemIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/TelemRSSI.svg"
        fillMode:           Image.PreserveAspectFit
        color:              qgcPal.buttonText
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            mainWindow.showPopUp(_root, telemRSSIInfo)
        }
    }
}
