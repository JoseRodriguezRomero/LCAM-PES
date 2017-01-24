import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2

Dialog {
    id: visa_settings_dialog
    visible: false
    title: "VISA Settings"

    contentItem: Rectangle {
        implicitHeight: Math.round(Screen.pixelDensity*50)
        implicitWidth: Math.round(Screen.pixelDensity*180)
        color: "#f2f2f2"

        Item {
            id: visa_settings_rect

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            height: parent.height - Math.round(Screen.pixelDensity*2)
            width:  parent.width - Math.round(Screen.pixelDensity*4)

            property int button_space: Screen.pixelDensity*2

            Button {
                id: visa_cancel

                height: start_button.height
                width: Math.round(Screen.pixelDensity*40)

                text: qsTr("Cancel")

                Material.accent: Material.Red
                highlighted: true

                anchors.bottom: parent.bottom
                x: parent.width - width

                onReleased: {
                    visa_settings_dialog.close()
                }
            }

            Button {
                id: visa_accept

                height: visa_cancel.height
                width: visa_cancel.width

                text: qsTr("Accept")

                Material.accent: Material.Green
                highlighted: true

                anchors.bottom: parent.bottom
                x: visa_cancel.x - width - parent.button_space

                onReleased: {
                    controller.setAsciipar4Name(asciipar4_txt.text)
                    controller.setCounterName(counter_txt.text)
                    visa_settings.close()
                }
            }

            Button {
                id: visa_reload

                height: visa_accept.height
                width: visa_accept.width

                text: qsTr("Reload")

                anchors.bottom: parent.bottom
                anchors.left: parent.left

                onReleased: {
                    controller.setAsciipar4Name(asciipar4_txt.text)
                    controller.setCounterName(counter_txt.text)
                    visa_settings_dialog.check_open_status()
                }
            }

            Item {
                width: parent.width
                height: parent.height-visa_accept.height

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                Item {
                    width: parent.width - Math.round(Screen.pixelDensity*10)
                    height: parent.height - Math.round(Screen.pixelDensity*10)

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        spacing: Math.round(Screen.pixelDensity*20)

                        Column {
                            id: visa_c1
                            spacing: Screen.pixelDensity*2

                            Label {
                                text: qsTr("asciipar4")
                            }

                            TextField {
                                id: asciipar4_txt
                                width: Screen.pixelDensity*65
                            }
                        }

                        Column {
                            id: visa_c2
                            spacing: visa_c1.spacing

                            Label {
                                text: qsTr("counter")
                            }

                            TextField {
                                id: counter_txt
                                width: asciipar4_txt.width
                            }
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        check_open_status()
    }

    function set_asciipar_text(text) {
        asciipar4_txt.text = text
    }

    function set_counter_text(text) {
        counter_txt.text = text
    }

    function check_open_status() {
        if (controller.counterIsReachable())
        {
            counter_txt.color = Material.color(Material.Green)
        }
        else
        {
            counter_txt.color = Material.color(Material.Red)
        }

        if (controller.asciipar4IsReachable())
        {
            asciipar4_txt.color = Material.color(Material.Green)
        }
        else
        {
            asciipar4_txt.color = Material.color(Material.Red)
        }
    }
}
