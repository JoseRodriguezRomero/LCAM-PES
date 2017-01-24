import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Button {
    id: settings_button

    background: Rectangle {
        anchors.fill: parent
        color: Material.color(Material.DeepOrange)
        radius: height / 2.0
    }

    DropShadow {
        anchors.fill: parent
        horizontalOffset: 0
        verticalOffset: Math.round(Screen.pixelDensity*0.5)
        radius: Math.round(Screen.pixelDensity*2)
        samples: 18
        color: "#80000000"
        source: parent.background
    }

    Menu {
        id: menu
        y: settings_button.height

        width: hr_check.width
        closePolicy: Menu.CloseOnPressOutside

        MenuItem {
            id: hr_check
            text: "Horizontal Markers"
            checkable: true

            onCheckedChanged: {
                if (checked)
                {
                    vr_check.checked = hr_check.checked ? false : false
                }
                specter_chart.show_horizontal_rulers(checked)
            }
        }
        MenuItem {
            id: vr_check
            text: "Vertical Markers"
            checkable: true

            onCheckedChanged: {
                if (checked)
                {
                    hr_check.checked = hr_check.checked ? false : false
                }
                specter_chart.show_vertical_rulers(checked)
            }
        }

        MenuItem {
            text: "Log X Scale"
            checkable: true
        }
        MenuItem {
            text: "Log Y Scale"
            checkable: true
        }

        MenuItem {
            text: "VISA Settings"
            id: visa_settings_menu_item

            onReleased: {
                visa_settings.set_asciipar_text(controller.asciipar4ResourceName())
                visa_settings.set_counter_text(controller.counterResourceName())
                visa_settings.open()
            }
        }
        MenuItem {
            text: "Exit"

            onReleased: {
                main_form.close()
            }
        }
    }

    Item {
        height: parent.height*0.65
        width: height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: r1
            color: "white"

            height: parent.height / 4.0
            width: height
            radius: height

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
        }

        Rectangle {
            id: r2
            color: "white"

            height: parent.height / 4.0
            width: height
            radius: height

            anchors.horizontalCenter: parent.horizontalCenter
            y: r1.y + height + parent.height/8.0
        }

        Rectangle {
            id: r3
            color: "white"

            height: parent.height / 4.0
            width: height
            radius: height

            anchors.horizontalCenter: parent.horizontalCenter
            y: r2.y + height + parent.height/8.0
        }
    }

    function enable_visa_settings(enabled) {
        visa_settings_menu_item.enabled = enabled
    }

    onClicked: {
        if (!menu.visible)
        {
            menu.open()
        }
    }
}
