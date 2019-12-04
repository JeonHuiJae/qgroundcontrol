import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

QGCFlickable {
    height:         outerEditorRect.height
    contentHeight:  outerEditorRect.height
    clip:           true

    property var controller ///< RallyPointController

    readonly property real  _margin: ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius: ScreenTools.defaultFontPixelWidth / 2

    Rectangle {
        id:     outerEditorRect
        width:  parent.width
        height: innerEditorRect.y + innerEditorRect.height + (_margin * 2)
        radius: _radius
        color:  qgcPal.missionItemEditor

        QGCLabel {
            id:                 editorLabel
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.top:        parent.top
            text:               qsTr("랠리 포인트")
        }

        Rectangle {
            id:                 innerEditorRect
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        editorLabel.bottom
            height:             infoLabel.height + (_margin * 2)
            color:              qgcPal.windowShadeDark
            radius:             _radius

            QGCLabel {
                id:                 infoLabel
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                wrapMode:           Text.WordWrap
                font.pointSize:     ScreenTools.smallFontPointSize
                text:               qsTr("랠리 포인트는 시작 지점으로 복귀할 때 대체 착지 지점을 제공합니다.")
            }

            /*
            QGCLabel {
                id:                 helpLabel
                anchors.margins:    _margin
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.top:        infoLabel.bottom
                wrapMode:           Text.WordWrap
                text:               controller.supported ?
                                        qsTr("Click in the map to add new rally points.") :
                                        qsTr("This vehicle does not support Rally Points.")
            }
            */
        }
    }
}
