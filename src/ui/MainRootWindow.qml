/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.11
import QtQuick.Window   2.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0

/// Native QML top level window
ApplicationWindow {
    property bool flag1: false
    property bool flag2: false
    property bool flag3: false
    id:             mainWindow
    minimumWidth:   ScreenTools.isMobile ? Screen.width  : Math.min(215 * Screen.pixelDensity, Screen.width)
    minimumHeight:  ScreenTools.isMobile ? Screen.height : Math.min(120 * Screen.pixelDensity, Screen.height)
    visible:        true

    Popup {
        id:login
        width: parent.width
        height: parent.height
        padding: 0
        Image {
            width: parent.width
            height: parent.height
            source: "qrc:///res/firmware/3drradio.png"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColumnLayout{
            anchors.horizontalCenter : parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30
            Image {
                width:60
                height:60
                anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:///res/firmware/apm.png"
            }
            ColumnLayout{
                spacing: 10
                TextField{
                    id:text1
                    width : 100
                    height : 30
                    text : id
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                TextField{
                    id:text2
                    width : 100
                    height : 30
                    text : pw
                    anchors.horizontalCenter: parent.horizontalCenter
                    echoMode: "Password"
                }
                Button{
                    id:bt1
                    width: 100
                    height : 30
                    text:qsTr("LOGIN")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked:
                    {
                        if(text1.text == "root" && text2.text == "root")
                        {
                            swifeDialog.open();
                            s_view.currentIndex = 0;
                            toolbarRoot.visible = true;
                            login.close();
                        }
                        else
                        {
                            loginFail.open();
                        }
                    }
                }
            }
        }
    }
    /// Native QML top level windowz

    Component.onCompleted: {
        //-- Full screen on mobile or tiny screens
        if(ScreenTools.isMobile || Screen.height / ScreenTools.realPixelDensity < 120) {
            mainWindow.showFullScreen()
        } else {
            width   = ScreenTools.isMobile ? Screen.width  : Math.min(250 * Screen.pixelDensity, Screen.width)
            height  = ScreenTools.isMobile ? Screen.height : Math.min(150 * Screen.pixelDensity, Screen.height)
        }
        login.open()
    }

    readonly property real      _topBottomMargins:          ScreenTools.defaultFontPixelHeight * 0.5
    readonly property string    _mainToolbar:               QGroundControl.corePlugin.options.mainToolbarUrl
    readonly property string    _planToolbar:               QGroundControl.corePlugin.options.planToolbarUrl

    //-------------------------------------------------------------------------
    //-- Global Scope Variables

    property var                activeVehicle:              QGroundControl.multiVehicleManager.activeVehicle
    property bool               communicationLost:          activeVehicle ? activeVehicle.connectionLost : false
    property string             formatedMessage:            activeVehicle ? activeVehicle.formatedMessage : ""
    property real               availableHeight:            mainWindow.height - mainWindow.header.height - mainWindow.footer.height

    property var                currentPlanMissionItem:     planMasterControllerPlan ? planMasterControllerPlan.missionController.currentPlanViewItem : null
    property var                planMasterControllerPlan:   null
    property var                planMasterControllerView:   null
    property var                flightDisplayMap:           null

    readonly property string    navButtonWidth:             ScreenTools.defaultFontPixelWidth * 24
    readonly property real      defaultTextHeight:          ScreenTools.defaultFontPixelHeight
    readonly property real      defaultTextWidth:           ScreenTools.defaultFontPixelWidth

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    //-------------------------------------------------------------------------
    //-- Actions

    signal armVehicle
    signal disarmVehicle
    signal vtolTransitionToFwdFlight
    signal vtolTransitionToMRFlight

    //-------------------------------------------------------------------------
    //-- Global Scope Functions

    function viewSwitch(isPlanView) {
        settingsWindow.visible  = false
        setupWindow.visible     = false
        analyzeWindow.visible   = false
        flightView.visible      = false
        planViewLoader.visible  = false
        if(isPlanView) {
            toolbar.source  = _planToolbar
        } else {
            toolbar.source  = _mainToolbar
        }
    }

    function showFlyView() {
        viewSwitch(false)
        flightView.visible = true
    }

    function showPlanView() {
        viewSwitch(true)
        planViewLoader.visible = true
    }

    function showAnalyzeView() {
        viewSwitch(false)
        analyzeWindow.visible = true
    }

    function showSetupView() {
        viewSwitch(false)
        setupWindow.visible = true
    }

    function showSettingsView() {
        viewSwitch(false)
        settingsWindow.visible = true
    }

    function showHelper() { //////
        swifeDialog.open()
        s_view.currentIndex = 0;
    }

    function showMissionHelper() { //////
        if(flag1 == false)
            missionDialog.open()
    }
    function showFenseHelper() { //////
        if(flag2 == false)
            fenseDialog.open()
    }
    function showRallyHelper() { //////
        if(flag3 == false)
            rallyDialog.open()
    }


    //-------------------------------------------------------------------------
    //-- Global simple message dialog

    function showMessageDialog(title, text) {
        if(simpleMessageDialog.visible) {
            simpleMessageDialog.close()
        }
        simpleMessageDialog.title = title
        simpleMessageDialog.text  = text
        simpleMessageDialog.open()
    }

    MainWindowSavedState {
        window: mainWindow
    }

    MessageDialog {
        id:                 simpleMessageDialog
        standardButtons:    StandardButton.Ok
        modality:           Qt.ApplicationModal
        visible:            false
    }

    //-------------------------------------------------------------------------
    //-- Global complex dialog

    /// Shows a QGCViewDialogContainer based dialog
    ///     @param component The dialog contents
    ///     @param title Title for dialog
    ///     @param charWidth Width of dialog in characters
    ///     @param buttons Buttons to show in dialog using StandardButton enum

    readonly property int showDialogFullWidth:      -1  ///< Use for full width dialog
    readonly property int showDialogDefaultWidth:   40  ///< Use for default dialog width

    function showComponentDialog(component, title, charWidth, buttons) {
        var dialogWidth = charWidth === showDialogFullWidth ? mainWindow.width : ScreenTools.defaultFontPixelWidth * charWidth
        mainWindowDialog.width = dialogWidth
        mainWindowDialog.dialogComponent = component
        mainWindowDialog.dialogTitle = title
        mainWindowDialog.dialogButtons = buttons
        mainWindowDialog.open()
        if(buttons & StandardButton.Cancel || buttons & StandardButton.Close || buttons & StandardButton.Discard || buttons & StandardButton.Abort || buttons & StandardButton.Ignore) {
            mainWindowDialog.closePolicy = Popup.NoAutoClose;
            mainWindowDialog.interactive = false;
        } else {
            mainWindowDialog.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside;
            mainWindowDialog.interactive = true;
        }
    }

    Drawer {
        id:             mainWindowDialog
        y:              mainWindow.header.height
        height:         mainWindow.height - mainWindow.header.height
        edge:           Qt.RightEdge
        interactive:    false
        background: Rectangle {
            color:  qgcPal.windowShadeDark
        }
        property var    dialogComponent: null
        property var    dialogButtons: null
        property string dialogTitle: ""
        Loader {
            id:             dlgLoader
            anchors.fill:   parent
            onLoaded: {
                item.setupDialogButtons()
            }
        }
        onOpened: {
            dlgLoader.source = "QGCViewDialogContainer.qml"
        }
        onClosed: {
            dlgLoader.source = ""
        }
    }

    property bool _forceClose: false

    function finishCloseProcess() {
        QGroundControl.linkManager.shutdown()
        _forceClose = true
        mainWindow.close()
    }

    // On attempting an application close we check for:
    //  Unsaved missions - then
    //  Pending parameter writes - then
    //  Active connections
    onClosing: {
        if (!_forceClose) {
            unsavedMissionCloseDialog.check()
            close.accepted = false
        }
    }

    MessageDialog {
        id:                 unsavedMissionCloseDialog
        title:              qsTr("%1 close").arg(QGroundControl.appName)
        text:               qsTr("You have a mission edit in progress which has not been saved/sent. If you close you will lose changes. Are you sure you want to close?")
        standardButtons:    StandardButton.Yes | StandardButton.No
        modality:           Qt.ApplicationModal
        visible:            false
        onYes:              pendingParameterWritesCloseDialog.check()
        function check() {
            if (planMasterControllerPlan && planMasterControllerPlan.dirty) {
                unsavedMissionCloseDialog.open()
            } else {
                pendingParameterWritesCloseDialog.check()
            }
        }
    }

    MessageDialog {
        id:                 pendingParameterWritesCloseDialog
        title:              qsTr("%1 close").arg(QGroundControl.appName)
        text:               qsTr("You have pending parameter updates to a vehicle. If you close you will lose changes. Are you sure you want to close?")
        standardButtons:    StandardButton.Yes | StandardButton.No
        modality:           Qt.ApplicationModal
        visible:            false
        onYes:              activeConnectionsCloseDialog.check()
        function check() {
            for (var index=0; index<QGroundControl.multiVehicleManager.vehicles.count; index++) {
                if (QGroundControl.multiVehicleManager.vehicles.get(index).parameterManager.pendingWrites) {
                    pendingParameterWritesCloseDialog.open()
                    return
                }
            }
            activeConnectionsCloseDialog.check()
        }
    }

    MessageDialog {
        id:                 activeConnectionsCloseDialog
        title:              qsTr("%1 close").arg(QGroundControl.appName)
        text:               qsTr("There are still active connections to vehicles. Are you sure you want to exit?")
        standardButtons:    StandardButton.Yes | StandardButton.Cancel
        modality:           Qt.ApplicationModal
        visible:            false
        onYes:              finishCloseProcess()
        function check() {
            if (QGroundControl.multiVehicleManager.activeVehicle) {
                activeConnectionsCloseDialog.open()
            } else {
                finishCloseProcess()
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Main, full window background (Fly View)
    background: Item {
        id:             rootBackground
        anchors.fill:   parent
    }

    //-------------------------------------------------------------------------
    //-- Toolbar
    header: ToolBar {
        id:             toolbarRoot
        height:         ScreenTools.toolbarHeight/*
        visible:        !QGroundControl.videoManager.fullScreen*/
        visible:        false
        background:     Rectangle {
            color:      qgcPal.globalTheme === QGCPalette.Light ? QGroundControl.corePlugin.options.toolbarBackgroundLight : QGroundControl.corePlugin.options.toolbarBackgroundDark
        }
        Loader {
            id:             toolbar
            anchors.fill:   parent
            source:         _mainToolbar
            //-- Toggle Full Screen / Windowed
            MouseArea {
                anchors.fill:   parent
                enabled:        !ScreenTools.isMobile
                onDoubleClicked: {
                    if(mainWindow.visibility === Window.Windowed) {
                        mainWindow.showFullScreen()
                    } else {
                        mainWindow.showNormal()
                    }
                }
            }
        }
    }

    footer: LogReplayStatusBar {
        visible: QGroundControl.settingsManager.flyViewSettings.showLogReplayStatusBar.rawValue
    }

    //-------------------------------------------------------------------------
    //-- Fly View
    FlightDisplayView {
        id:             flightView
        anchors.fill:   parent
        //-----------------------------------------------------------------
        //-- Loader helper for any child, no matter how deep, to display
        //   elements on top of the fly (video) window.
        Loader {
            id: rootVideoLoader
            anchors.centerIn: parent
        }
    }

    //-------------------------------------------------------------------------
    //-- Plan View
    Loader {
        id:             planViewLoader
        anchors.fill:   parent
        visible:        false
        source:         "PlanView.qml"
    }

    //-------------------------------------------------------------------------
    //-- Settings
    Loader {
        id:             settingsWindow
        anchors.fill:   parent
        visible:        false
        source:         "AppSettings.qml"
    }

    //-------------------------------------------------------------------------
    //-- Setup
    Loader {
        id:             setupWindow
        anchors.fill:   parent
        visible:        false
        source:         "SetupView.qml"
    }

    //-------------------------------------------------------------------------
    //-- Analyze
    Loader {
        id:             analyzeWindow
        anchors.fill:   parent
        visible:        false
        source:         "AnalyzeView.qml"
    }

    //-------------------------------------------------------------------------
    //-- Loader helper for any child, no matter how deep, to display elements
    //   on top of the main window.
    //   This is DEPRECATED. Use Popup instead.
    Loader {
        id: rootLoader
        anchors.centerIn: parent
    }

    //-------------------------------------------------------------------------
    //-- Vehicle Messages

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + qgcPal.text + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    function showVehicleMessages() {
        if(!vehicleMessageArea.visible) {
            if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                messageText.text = formatMessage(activeVehicle.formatedMessages)
                //-- Hack to scroll to last message
                for (var i = 0; i < activeVehicle.messageCount; i++)
                    messageFlick.flick(0,-5000)
                activeVehicle.resetMessages()
            } else {
                messageText.text = qsTr("No Messages")
            }
            vehicleMessageArea.open()
        }
    }

    onFormatedMessageChanged: {
        if(vehicleMessageArea.visible) {
            messageText.append(formatMessage(formatedMessage))
            //-- Hack to scroll down
            messageFlick.flick(0,-500)
        }
    }

    Popup {
        id:                 vehicleMessageArea
        width:              mainWindow.width  * 0.666
        height:             mainWindow.height * 0.666
        modal:              true
        focus:              true
        x:                  Math.round((mainWindow.width  - width)  * 0.5)
        y:                  Math.round((mainWindow.height - height) * 0.5)
        closePolicy:        Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            anchors.fill:   parent
            color:          qgcPal.window
            border.color:   qgcPal.text
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
        }
        QGCFlickable {
            id:                 messageFlick
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            anchors.fill:       parent
            contentHeight:      messageText.height
            contentWidth:       messageText.width
            pixelAligned:       true
            clip:               true
            TextEdit {
                id:             messageText
                readOnly:       true
                textFormat:     TextEdit.RichText
                color:          qgcPal.text
            }
        }
        //-- Dismiss Vehicle Messages
        QGCColoredImage {
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            anchors.top:        parent.top
            anchors.right:      parent.right
            width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
            height:             width
            sourceSize.height:  width
            source:             "/res/XDelete.svg"
            fillMode:           Image.PreserveAspectFit
            mipmap:             true
            smooth:             true
            color:              qgcPal.text
            MouseArea {
                anchors.fill:       parent
                anchors.margins:    ScreenTools.isMobile ? -ScreenTools.defaultFontPixelHeight : 0
                onClicked: {
                    vehicleMessageArea.close()
                }
            }
        }
        //-- Clear Messages
        QGCColoredImage {
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            height:             ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
            width:              height
            sourceSize.height:   height
            source:             "/res/TrashDelete.svg"
            fillMode:           Image.PreserveAspectFit
            mipmap:             true
            smooth:             true
            color:              qgcPal.text
            MouseArea {
                anchors.fill:   parent
                onClicked: {
                    if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                        activeVehicle.clearMessages();
                        vehicleMessageArea.close()
                    }
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- System Messages

    property var    _messageQueue:      []
    property string _systemMessage:     ""

    function showMessage(message) {
        vehicleMessageArea.close()
        if(systemMessageArea.visible || QGroundControl.videoManager.fullScreen) {
            _messageQueue.push(message)
        } else {
            _systemMessage = message
            systemMessageArea.open()
        }
    }

    function showMissingParameterOverlay(missingParamName) {
        showError(qsTr("Parameters missing: %1").arg(missingParamName))
    }

    function showFactError(errorMsg) {
        showError(qsTr("Fact error: %1").arg(errorMsg))
    }

    Popup {
        id:                 systemMessageArea
        y:                  ScreenTools.defaultFontPixelHeight
        x:                  Math.round((mainWindow.width - width) * 0.5)
        width:              mainWindow.width  * 0.55
        height:             ScreenTools.defaultFontPixelHeight * 6
        modal:              false
        focus:              true
        closePolicy:        Popup.CloseOnEscape

        background: Rectangle {
            anchors.fill:   parent
            color:          qgcPal.alertBackground
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            border.color:   qgcPal.alertBorder
            border.width:   2
        }

        onOpened: {
            systemMessageText.text = mainWindow._systemMessage
        }

        onClosed: {
            //-- Are there messages in the waiting queue?
            if(mainWindow._messageQueue.length) {
                mainWindow._systemMessage = ""
                //-- Show all messages in queue
                for (var i = 0; i < mainWindow._messageQueue.length; i++) {
                    var text = mainWindow._messageQueue[i]
                    if(i) mainWindow._systemMessage += "<br>"
                    mainWindow._systemMessage += text
                }
                //-- Clear it
                mainWindow._messageQueue = []
                systemMessageArea.open()
            } else {
                mainWindow._systemMessage = ""
            }
        }

        Flickable {
            id:                 systemMessageFlick
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            anchors.fill:       parent
            contentHeight:      systemMessageText.height
            contentWidth:       systemMessageText.width
            boundsBehavior:     Flickable.StopAtBounds
            pixelAligned:       true
            clip:               true
            TextEdit {
                id:             systemMessageText
                width:          systemMessageArea.width - systemMessageClose.width - (ScreenTools.defaultFontPixelHeight * 2)
                anchors.centerIn: parent
                readOnly:       true
                textFormat:     TextEdit.RichText
                font.pointSize: ScreenTools.defaultFontPointSize
                font.family:    ScreenTools.demiboldFontFamily
                wrapMode:       TextEdit.WordWrap
                color:          qgcPal.alertText
            }
        }

        //-- Dismiss Critical Message
        QGCColoredImage {
            id:                 systemMessageClose
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            anchors.top:        parent.top
            anchors.right:      parent.right
            width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
            height:             width
            sourceSize.height:  width
            source:             "/res/XDelete.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.alertText
            MouseArea {
                anchors.fill:       parent
                anchors.margins:    -ScreenTools.defaultFontPixelHeight
                onClicked: {
                    systemMessageArea.close()
                }
            }
        }

        //-- More text below indicator
        QGCColoredImage {
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
            height:             width
            sourceSize.height:  width
            source:             "/res/ArrowDown.svg"
            fillMode:           Image.PreserveAspectFit
            visible:            systemMessageText.lineCount > 5
            color:              qgcPal.alertText
            MouseArea {
                anchors.fill:   parent
                onClicked: {
                    systemMessageFlick.flick(0,-500)
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Indicator Popups

    function showPopUp(item, dropItem) {
        indicatorDropdown.currentIndicator = dropItem
        indicatorDropdown.currentItem = item
        indicatorDropdown.open()
    }

    Popup {
        id:             indicatorDropdown
        y:              ScreenTools.defaultFontPixelHeight
        modal:          true
        focus:          true
        closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property var    currentItem:        null
        property var    currentIndicator:   null
        background: Rectangle {
            width:  loader.width
            height: loader.height
            color:  Qt.rgba(0,0,0,0)
        }
        Loader {
            id:             loader
            onLoaded: {
                var centerX = mainWindow.contentItem.mapFromItem(indicatorDropdown.currentItem, 0, 0).x - (loader.width * 0.5)
                if((centerX + indicatorDropdown.width) > (mainWindow.width - ScreenTools.defaultFontPixelWidth)) {
                    centerX = mainWindow.width - indicatorDropdown.width - ScreenTools.defaultFontPixelWidth
                }
                indicatorDropdown.x = centerX
            }
        }
        onOpened: {
            loader.sourceComponent = indicatorDropdown.currentIndicator
        }
        onClosed: {
            loader.sourceComponent = null
            indicatorDropdown.currentIndicator = null
        }
    }

    Dialog {
           id: swifeDialog
           x: (window.width - width) / 2
           y: window.height / 10
           width: 500
           height: 610

           SwipeView {
               id: s_view
               currentIndex: 0
               anchors.fill: parent

                   Pane {
                       width: s_view.width
                       height: s_view.height

                       Column {
                           spacing: 40
                           width: parent.width


                           Image {
                               width: s_view.width
                               height: s_view.height

                               source: "qrc:///res/calibration/accel_back.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
                   Pane {
                       width: s_view.width
                       height: s_view.height

                       Column {
                           spacing: 40
                           width: parent.width

                           Image {
                               width: s_view.width
                               height: s_view.height

                               source: "qrc:///res/calibration/accel_down.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
                   Pane {
                       width: s_view.width
                       height: s_view.height

                       Column {
                           spacing: 40
                           width: parent.width

                           Image {
                               width: s_view.width
                               height: s_view.height

                               source: "qrc:///res/calibration/accel_front.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
                   Pane {
                       width: s_view.width
                       height: s_view.height

                       Column {
                           spacing: 40
                           width: parent.width

                           Image {
                               width: s_view.width
                               height: s_view.height

                               source: "qrc:///res/calibration/accel_left.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
                   Pane {
                       width: s_view.width
                       height: s_view.height

                       Column {
                           spacing: 40
                           width: parent.width

                           Image {
                               width: s_view.width
                               height: s_view.height

                               source: "qrc:///res/calibration/accel_right.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
               }
               PageIndicator {
                   count: s_view.count
                   currentIndex: s_view.currentIndex
                   anchors.bottom: parent.bottom
                   anchors.horizontalCenter: parent.horizontalCenter
               }
            }

    Dialog {
           id: missionDialog
           x: (window.width - width) / 2
           y: window.height / 10
           width: 500
           height: 620

           SwipeView {
               id: s_view1
               currentIndex: 0
               anchors.fill: parent
                   Pane {
                       width: 500
                       height: 600

                       Column {
                           width: parent.width

                           Image {
                               width: 500
                               height: 600

                               source: "qrc:///qml/calibration/mode1/radioCenter.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
            }
           CheckBox{
               id:c1
               text:"다시 보지 않기"
              // anchors.right: parent.left
               anchors.bottom: parent.bottom
               onCheckedChanged: {
                   flag1 = true
                   missionDialog.close()
               }
           }
        }
    Dialog {
           id: fenseDialog
           x: (window.width - width) / 2
           y: window.height / 10
           width: 500
           height: 620

           SwipeView {
               id: s_view2
               currentIndex: 0
               anchors.fill: parent
                   Pane {
                       width: 500
                       height: 600

                       Column {
                           width: parent.width

                           Image {
                               width: 500
                               height: 600

                               source: "qrc:///qml/calibration/mode1/radioHome.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
            }
           CheckBox{
               id:c2
               text:"다시 보지 않기"
              // anchors.right: parent.left
               anchors.bottom: parent.bottom
               onCheckedChanged: {
                   flag2 = true
                   fenseDialog.close()
               }
           }
        }
    Dialog {
           id: rallyDialog
           x: (window.width - width) / 2
           y: window.height / 10
           width: 500
           height: 620

           SwipeView {
               id: s_view3
               currentIndex: 0
               anchors.fill: parent
                   Pane {
                       width: 500
                       height: 600

                       Column {
                           width: parent.width

                           Image {
                               width: 500
                               height: 600

                               source: "qrc:///qml/calibration/mode1/radioPitchDown.png"
                               anchors.horizontalCenter: parent.horizontalCenter
                           }
                       }
                   }
            }
           CheckBox{
               id:c3
               text:"다시 보지 않기"
               //anchors.right: parent.left
               anchors.bottom: parent.bottom
               onCheckedChanged: {
                   flag3 = true
                   rallyDialog.close()
               }
           }
      }

    Dialog {
           id: loginFail
           width: 230
           height: 80
           Label{
               anchors.horizontalCenter: parent.horizontalCenter
                text:qsTr("아이디나 비밀번호가 틀렸습니다.")
           }

    }
 }

