/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             firmwarePage
    pageComponent:  firmwarePageComponent
    pageName:       qsTr("Firmware")
    showAdvanced:   activeVehicle && activeVehicle.apmFirmware

    signal cancelDialog

    Component {
        id: firmwarePageComponent

        ColumnLayout {
            width:   availableWidth
            height:  availableHeight
            spacing: ScreenTools.defaultFontPixelHeight

            // Those user visible strings are hard to translate because we can't send the
            // HTML strings to translation as this can create a security risk. we need to find
            // a better way to hightlight them, or use less highlights.

            // User visible strings
            readonly property string title:             qsTr("펌웨어 설정") // Popup dialog title
            readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string highlightSuffix:   "</font>"
            readonly property string welcomeText:       qsTr("QGC는 Pixhawk 장치, SiK 라디오 및 PX4 Flow 스마트 카메라의 펌웨어를 업그레이드 할 수 있습니다.").arg(QGroundControl.appName)
            readonly property string welcomeTextSingle: qsTr("자동 조종 장치 펌웨어를 최신 버전으로 업데이트")
            readonly property string plugInText:        "<big>" + highlightPrefix + "USB를 통해 " + highlightSuffix + "장치를 연결하여 " + highlightPrefix + "펌웨어 업그레이드를 시작 " + highlightSuffix + " 하십시오.</big>"
            readonly property string flashFailText:     "업그레이드에 실패한 경우 USB 허브가 아닌 컴퓨터의 전원 공급 USB 포트에 " + highlightPrefix + "직접 연결" + highlightSuffix + "하십시오. " +
                                                        "또한 " + highlightPrefix + "배터리가 아닌 USB" + highlightSuffix + "를 통해서만 전원을 공급해야합니다."
            readonly property string qgcUnplugText1:    qsTr("펌웨어 업그레이드 전에 기기에 대한 ").arg(QGroundControl.appName) + highlightPrefix + "모든 QGroundControl 연결을 해제" + highlightSuffix + "해야합니다."
            readonly property string qgcUnplugText2:    highlightPrefix + "<big>USB에서 Pixhawk 및 / 또는 라디오를 분리하십시오.</big>" + highlightSuffix

            readonly property int _defaultFimwareTypePX4:   12
            readonly property int _defaultFimwareTypeAPM:   3

            property var    _firmwareUpgradeSettings:   QGroundControl.settingsManager.firmwareUpgradeSettings
            property var    _defaultFirmwareFact:       _firmwareUpgradeSettings.defaultFirmwareType
            property bool   _defaultFirmwareIsPX4:      true

            property string firmwareWarningMessage
            property bool   firmwareWarningMessageVisible:  false
            property bool   initialBoardSearch:             true
            property string firmwareName

            property bool _singleFirmwareMode:          QGroundControl.corePlugin.options.firmwareUpgradeSingleURL.length != 0   ///< true: running in special single firmware download mode

            function cancelFlash() {
                statusTextArea.append(highlightPrefix + qsTr("업그레이드 취소") + highlightSuffix)
                statusTextArea.append("------------------------------------------")
                controller.cancel()
            }

            function setupPageCompleted() {
                controller.startBoardSearch()
                _defaultFirmwareIsPX4 = _defaultFirmwareFact.rawValue === _defaultFimwareTypePX4 // we don't want this to be bound and change as radios are selected
            }

            QGCFileDialog {
                id:                 customFirmwareDialog
                title:              qsTr("펌웨어 파일 선택")
                nameFilters:        [qsTr("Firmware Files (*.px4 *.apj *.bin *.ihx)"), qsTr("All Files (*)")]
                selectExisting:     true
                folder:             QGroundControl.settingsManager.appSettings.logSavePath
                onAcceptedForLoad: {
                    controller.flashFirmwareUrl(file)
                    close()
                }
            }

            FirmwareUpgradeController {
                id:             controller
                progressBar:    progressBar
                statusLog:      statusTextArea

                property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

                onActiveVehicleChanged: {
                    if (!activeVehicle) {
                        statusTextArea.append(plugInText)
                    }
                }

                onNoBoardFound: {
                    initialBoardSearch = false
                    if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                        statusTextArea.append(plugInText)
                    }
                }

                onBoardGone: {
                    initialBoardSearch = false
                    if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                        statusTextArea.append(plugInText)
                    }
                }

                onBoardFound: {
                    if (initialBoardSearch) {
                        // Board was found right away, so something is already plugged in before we've started upgrade
                        statusTextArea.append(qgcUnplugText1)
                        statusTextArea.append(qgcUnplugText2)

                        var availableDevices = controller.availableBoardsName()
                        if(availableDevices.length > 1) {
                            statusTextArea.append(highlightPrefix + qsTr("여러 장치가 감지되었습니다! 감지 된 모든 장치를 제거하여 펌웨어 업그레이드를 수행하십시오."))
                            statusTextArea.append(qsTr("Detected [%1]: ").arg(availableDevices.length) + availableDevices.join(", "))
                        }
                        if(QGroundControl.multiVehicleManager.activeVehicle) {
                            QGroundControl.multiVehicleManager.activeVehicle.autoDisconnect = true
                        }
                    } else {
                        // We end up here when we detect a board plugged in after we've started upgrade
                        statusTextArea.append(highlightPrefix + qsTr("발견된 장치") + highlightSuffix + ": " + controller.boardType)
                        if (controller.pixhawkBoard || controller.px4FlowBoard) {
                            mainWindow.showComponentDialog(pixhawkFirmwareSelectDialogComponent, title, mainWindow.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                        }
                    }
                }

                onError: {
                    statusTextArea.append(flashFailText)
                    firmwarePage.cancelDialog()
                }
            }

            Component {
                id: pixhawkFirmwareSelectDialogComponent

                QGCViewDialog {
                    id: pixhawkFirmwareSelectDialog

                    property bool showFirmwareTypeSelection:    _advanced.checked
                    property bool px4Flow:                      controller.px4FlowBoard

                    function firmwareVersionChanged(model) {
                        firmwareWarningMessageVisible = false
                        // All of this bizarre, setting model to null and index to 1 and then to 0 is to work around
                        // strangeness in the combo box implementation. This sequence of steps correctly changes the combo model
                        // without generating any warnings and correctly updates the combo text with the new selection.
                        firmwareBuildTypeCombo.model = null
                        firmwareBuildTypeCombo.model = model
                        firmwareBuildTypeCombo.currentIndex = 1
                        firmwareBuildTypeCombo.currentIndex = 0
                    }

                    function updatePX4VersionDisplay() {
                        var versionString = ""
                        if (_advanced.checked) {
                            switch (controller.selectedFirmwareBuildType) {
                            case FirmwareUpgradeController.StableFirmware:
                                versionString = controller.px4StableVersion
                                break
                            case FirmwareUpgradeController.BetaFirmware:
                                versionString = controller.px4BetaVersion
                                break
                            }
                        } else {
                            versionString = controller.px4StableVersion
                        }
                        px4FlightStackRadio.text = qsTr("PX4 Pro ") + versionString
                        //px4FlightStackRadio2.text = qsTr("PX4 Pro ") + versionString
                    }

                    Component.onCompleted: {
                        firmwarePage.advanced = false
                        firmwarePage.showAdvanced = false
                        updatePX4VersionDisplay()
                    }

                    function accept() {
                        if (_singleFirmwareMode) {
                            controller.flashSingleFirmwareMode(controller.selectedFirmwareBuildType)
                        } else {
                            var stack
                            var firmwareBuildType = firmwareBuildTypeCombo.model.get(firmwareBuildTypeCombo.currentIndex).firmwareType
                            var vehicleType = FirmwareUpgradeController.DefaultVehicleFirmware

                            if (px4Flow) {
                                stack = px4FlowTypeSelectionCombo.model.get(px4FlowTypeSelectionCombo.currentIndex).stackType
                                vehicleType = FirmwareUpgradeController.DefaultVehicleFirmware
                            } else {
                                stack = apmFlightStack.checked ? FirmwareUpgradeController.AutoPilotStackAPM : FirmwareUpgradeController.AutoPilotStackPX4
                                if (apmFlightStack.checked) {
                                    if (firmwareBuildType === FirmwareUpgradeController.CustomFirmware) {
                                        vehicleType = apmVehicleTypeCombo.currentIndex
                                    } else {
                                        if (controller.apmFirmwareNames.length === 0) {
                                            // Not ready yet, or no firmware available
                                            return
                                        }
                                        var firmwareUrl = controller.apmFirmwareUrls[ardupilotFirmwareSelectionCombo.currentIndex]
                                        if (firmwareUrl == "") {
                                            return
                                        }
                                        controller.flashFirmwareUrl(controller.apmFirmwareUrls[ardupilotFirmwareSelectionCombo.currentIndex])
                                        hideDialog()
                                        return
                                    }
                                }
                            }
                            //-- If custom, get file path
                            if (firmwareBuildType === FirmwareUpgradeController.CustomFirmware) {
                                customFirmwareDialog.openForLoad()
                            } else {
                                controller.flash(stack, firmwareBuildType, vehicleType)
                            }
                            hideDialog()
                        }
                    }

                    function reject() {
                        hideDialog()
                        cancelFlash()
                    }

                    Connections {
                        target:         firmwarePage
                        onCancelDialog: reject()
                    }

                    ListModel {
                        id: firmwareBuildTypeList

                        ListElement {
                            text:           qsTr("Standard Version (stable)")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        }
                        ListElement {
                            text:           qsTr("Beta Testing (beta)")
                            firmwareType:   FirmwareUpgradeController.BetaFirmware
                        }
                        ListElement {
                            text:           qsTr("Developer Build (master)")
                            firmwareType:   FirmwareUpgradeController.DeveloperFirmware
                        }
                        ListElement {
                            text:           qsTr("Custom firmware file...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    ListModel {
                        id: px4FlowFirmwareList

                        ListElement {
                            text:           qsTr("PX4 Pro")
                            stackType:   FirmwareUpgradeController.PX4FlowPX4
                        }
                        ListElement {
                            text:           qsTr("ArduPilot")
                            stackType:   FirmwareUpgradeController.PX4FlowAPM
                        }
                    }

                    ListModel {
                        id: px4FlowTypeList

                        ListElement {
                            text:           qsTr("Standard Version (stable)")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        }
                        ListElement {
                            text:           qsTr("Custom firmware file...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    ListModel {
                        id: singleFirmwareModeTypeList

                        ListElement {
                            text:           qsTr("Standard Version")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        }
                        ListElement {
                            text:           qsTr("Custom firmware file...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  mainColumn.height

                        Column {
                            id:             mainColumn
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            spacing:        defaultTextHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       (_singleFirmwareMode || !QGroundControl.apmFirmwareSupported) ? _singleFirmwareLabel : (px4Flow ? _px4FlowLabel : _pixhawkLabel)

                                readonly property string _px4FlowLabel:          qsTr("PX4 플로우 보드가 감지되었습니다. PX4 Flow에서 사용하는 펌웨어는 기기에서 사용중인 AutoPilot 펌웨어 유형과 일치해야합니다. ")
                                readonly property string _pixhawkLabel:          qsTr("Pixhawk 보드를 감지했습니다. 다음 비행편 중에서 선택할 수 있습니다. ")
                                readonly property string _singleFirmwareLabel:   qsTr("기기를 업그레이드하려면 Ok를 누르십시오.")
                            }

                            QGCLabel { text: qsTr("비행 스택"); visible: QGroundControl.apmFirmwareSupported }

                            Column {

                                Component.onCompleted: {
                                    if(!QGroundControl.apmFirmwareSupported) {
                                        _defaultFirmwareFact.rawValue = _defaultFimwareTypePX4
                                        firmwareVersionChanged(firmwareBuildTypeList)
                                    }
                                }

                                QGCRadioButton {
                                    id:             px4FlightStackRadio
                                    text:           qsTr("PX4 Pro ")
                                    textBold:       _defaultFirmwareIsPX4
                                    checked:        _defaultFirmwareIsPX4
                                    visible:        !_singleFirmwareMode && !px4Flow && QGroundControl.apmFirmwareSupported

                                    onClicked: {
                                        _defaultFirmwareFact.rawValue = _defaultFimwareTypePX4
                                        firmwareVersionChanged(firmwareBuildTypeList)
                                    }
                                }

                                QGCRadioButton {
                                    id:             apmFlightStack
                                    text:           qsTr("ArduPilot")
                                    textBold:       !_defaultFirmwareIsPX4
                                    checked:        !_defaultFirmwareIsPX4
                                    visible:        !_singleFirmwareMode && !px4Flow && QGroundControl.apmFirmwareSupported

                                    onClicked: {
                                        _defaultFirmwareFact.rawValue = _defaultFimwareTypeAPM
                                        firmwareVersionChanged(firmwareBuildTypeList)
                                    }
                                }
                            }

                            FactComboBox {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                visible:        !px4Flow && apmFlightStack.checked
                                fact:           _firmwareUpgradeSettings.apmChibiOS
                                indexModel:     false
                            }

                            FactComboBox {
                                id:             apmVehicleTypeCombo
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                visible:        !px4Flow && apmFlightStack.checked
                                fact:           _firmwareUpgradeSettings.apmVehicleType
                                indexModel:     false
                            }

                            QGCComboBox {
                                id:             ardupilotFirmwareSelectionCombo
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                visible:        !px4Flow && apmFlightStack.checked && !controller.downloadingFirmwareList && controller.apmFirmwareNames.length !== 0
                                model:          controller.apmFirmwareNames

                                onModelChanged: console.log("model", model)
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("사용 가능한 펌웨어 목록 다운로드 중 ...")
                                visible:        controller.downloadingFirmwareList
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("사용 가능한 펌웨어가 없습니다.")
                                visible:        !controller.downloadingFirmwareList && (QGroundControl.apmFirmwareSupported && controller.apmFirmwareNames.length === 0)
                            }

                            QGCComboBox {
                                id:             px4FlowTypeSelectionCombo
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                visible:        px4Flow
                                model:          px4FlowFirmwareList
                                textRole:       "text"
                                currentIndex:   _defaultFirmwareIsPX4 ? 0 : 1
                            }

                            Row {
                                width:      parent.width
                                spacing:    ScreenTools.defaultFontPixelWidth / 2
                                visible:    !px4Flow

                                Rectangle {
                                    height:     1
                                    width:      ScreenTools.defaultFontPixelWidth * 5
                                    color:      qgcPal.text
                                    anchors.verticalCenter: _advanced.verticalCenter
                                }

                                QGCCheckBox {
                                    id:         _advanced
                                    text:       qsTr("고급 설정")
                                    checked:    px4Flow ? true : false

                                    onClicked: {
                                        firmwareBuildTypeCombo.currentIndex = 0
                                        firmwareWarningMessageVisible = false
                                        updatePX4VersionDisplay()
                                    }
                                }

                                Rectangle {
                                    height:     1
                                    width:      ScreenTools.defaultFontPixelWidth * 5
                                    color:      qgcPal.text
                                    anchors.verticalCenter: _advanced.verticalCenter
                                }
                            }

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                visible:    showFirmwareTypeSelection
                                text:       _singleFirmwareMode ?  qsTr("표준 버전 또는 파일 시스템 (이전 다운로드)에서 하나를 선택하십시오. ") :
                                                                  (px4Flow ? qsTr("설치할 펌웨어 버전을 선택하십시오. ") :
                                                                             qsTr("설치하려는 위의 비행 스택 버전을 선택하십시오. "))
                            }

                            QGCComboBox {
                                id:             firmwareBuildTypeCombo
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                visible:        showFirmwareTypeSelection
                                textRole:       "text"
                                model:          _singleFirmwareMode ? singleFirmwareModeTypeList : (px4Flow ? px4FlowTypeList : firmwareBuildTypeList)
                                currentIndex:   controller.selectedFirmwareBuildType

                                onActivated: {
                                    controller.selectedFirmwareBuildType = model.get(index).firmwareType
                                    if (model.get(index).firmwareType === FirmwareUpgradeController.BetaFirmware) {
                                        firmwareWarningMessageVisible = true
                                        firmwareVersionWarningLabel.text = qsTr("경고 : 베타 펌웨어. ") +
                                                qsTr("이 펌웨어 버전은 베타 테스터 전용입니다. ") +
                                                qsTr("FLIGHT TESTING을 받았지만 실제로 변경된 코드를 나타냅니다. ") +
                                                qsTr("정상적인 작동에는 사용하지 마십시오. ")
                                    } else if (model.get(index).firmwareType === FirmwareUpgradeController.DeveloperFirmware) {
                                        firmwareWarningMessageVisible = true
                                        firmwareVersionWarningLabel.text = qsTr("경고 : 연속 펌웨어 빌드. ") +
                                                qsTr("이 펌웨어는 테스트되지 않았습니다.") +
                                                qsTr("개발자 전용입니다. ") +
                                                qsTr("소품없이 먼저 벤치 테스트를 실행하십시오. ") +
                                                qsTr("추가 안전 예방 조치없이 비행하지 마십시오. ") +
                                                qsTr("메일링 리스트를 사용할 때는 적극적으로 따르십시오.")
                                    } else {
                                        firmwareWarningMessageVisible = false
                                    }
                                    updatePX4VersionDisplay()
                                }
                            }

                            QGCLabel {
                                id:         firmwareVersionWarningLabel
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                visible:    firmwareWarningMessageVisible
                            }
                        } // Column
                    } // QGCFLickable
                } // QGCViewDialog
            } // Component - pixhawkFirmwareSelectDialogComponent

            Component {
                id: firmwareWarningDialog

                QGCViewMessage {
                    message: firmwareWarningMessage

                    function accept() {
                        hideDialog()
                        controller.doFirmwareUpgrade();
                    }
                }
            }

            ProgressBar {
                id:                     progressBar
                Layout.preferredWidth:  parent.width
                visible:                !flashBootloaderButton.visible
            }

            QGCButton {
                id:         flashBootloaderButton
                text:       qsTr("Flash ChibiOS Bootloader")
                visible:    firmwarePage.advanced
                onClicked:  activeVehicle.flashBootloader()
            }

            TextArea {
                id:                 statusTextArea
                Layout.preferredWidth:              parent.width
                Layout.fillHeight:  true
                readOnly:           true
                frameVisible:       false
                font.pointSize:     ScreenTools.defaultFontPointSize
                textFormat:         TextEdit.RichText
                text:               _singleFirmwareMode ? welcomeTextSingle : welcomeText

                style: TextAreaStyle {
                    textColor:          qgcPal.text
                    backgroundColor:    qgcPal.windowShade
                }
            }
        } // ColumnLayout
    } // Component
} // SetupPage
