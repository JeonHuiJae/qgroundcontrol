import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0

// Toolbar for Plan View
Rectangle {
    id:                 _root
    color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.8) : Qt.rgba(0,0,0,0.75)
    anchors.fill:       parent
    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }
    RowLayout {
        anchors.bottomMargin:   1
        //anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.fill:           parent
        spacing:                ScreenTools.defaultFontPixelWidth / 2
        QGCToolBarButton {
            id:                 settingsButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            icon.source:        "/res/QGCLogoWhite"
            logo:               true
            visible:            !QGroundControl.corePlugin.options.combineSettingsAndSetup
            onClicked: {
                //checked = true
                //mainWindow.showSettingsView()
            }
        }

        QGCToolBarButton {
            id:                 flyButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            icon.source:        "/qmlimages/PaperPlane.svg"
            onClicked: {
                checked = true
                mainWindow.showFlyView()
            }
        }

        QGCToolBarButton {
            id:                 planButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            icon.source:        "/qmlimages/Plan.svg"
            checked:            true
            onClicked: {
                checked = true
                mainWindow.showPlanView()
            }
        }

        QGCToolBarButton {
            id:                 setupButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            icon.source:        "/qmlimages/Gears.svg"
            onClicked: {
                checked = true
                mainWindow.showSetupView()
            }
        }

//            QGCToolBarButton {
//                id:                 analyzeButton
//                anchors.top:        parent.top
//                anchors.bottom:     parent.bottom
//                icon.source:        "/qmlimages/Analyze.svg"
//                visible:            QGroundControl.corePlugin.showAdvancedUI
//                onClicked: {
//                    checked = true
//                    mainWindow.showAnalyzeView()
//                }
//            }
        Loader {
            source:             "PlanToolBarIndicators.qml"
            Layout.fillWidth:   true
            Layout.fillHeight:  true
        }
    }
}

