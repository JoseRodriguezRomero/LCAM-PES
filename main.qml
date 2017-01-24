import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: main_form

    visible: true
    width: minimumWidth
    height: minimumHeight
    title: qsTr("LCAM - PES")

    minimumHeight: Math.round(Screen.pixelDensity*130)
    minimumWidth: Math.round(Screen.pixelDensity*210)

    Material.theme: Material.Light
    Material.primary: Material.Teal

    header: top_panel

    Pane {
        id: top_panel
        width: parent.width
        height: Math.round(Screen.pixelDensity*15)

        x: 0
        y: 0
        z: 1

        Material.elevation: 3
        Material.background: Material.Teal

        Text {
            id: title
            text: qsTr("LCAM - PES")

            color: "white"

            font.pointSize: 32
            anchors.verticalCenter: parent.verticalCenter
            x: 0
        }

        SettingsMenu {
            id: settings_button
            height: parent.height*1.25
            width: height

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
        }
    }

    Item {
        id: main_page
        anchors.fill: parent

        Pane {
            id: side_panel

            property int min_space: parent.width*0.025

            width: Math.round(Screen.pixelDensity*60)
            height: parent.height

            Material.elevation: 3
            Material.background: "#f2f2f2"

            anchors.top: parent.top
            anchors.left: specter_chart.right

            Button {
                id: start_button

                width: parent.width
                height: Math.round(Screen.pixelDensity*12.5)

                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.y + parent.height - height -
                   Math.round(Screen.pixelDensity*2.0)

                text: "Start"

                highlighted: true
                Material.accent: Material.Green

                onReleased: {
                    if (controller.isRunning())
                    {
                        controller.stop()
                    }
                    else
                    {
                        start_dialog.open()
                    }
                }
            }

            Button {
                id: save_button

                width: start_button.width
                height: start_button.height

                anchors.horizontalCenter: parent.horizontalCenter
                y: start_button.y - start_button.height

                text: "Save"

                onReleased: save_dialog.open()
            }

            Text {
                id: energy_step
                text: qsTr("Energy Step: 0.0 eV")

                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
            }

            Text {
                id: specter_num
                text: qsTr("Specter nº: 0 of 0")

                anchors.horizontalCenter: parent.horizontalCenter
                y: energy_step.y + energy_step.height*1.25
            }

            Text {
                id: time_per_step
                text: qsTr("Time per step: 0 ms")

                anchors.horizontalCenter: parent.horizontalCenter
                y: specter_num.y + energy_step.height*1.25
            }

            Text {
                id: elapsed_time
                text: qsTr("Elapsed time: 0 min")

                anchors.horizontalCenter: parent.horizontalCenter
                y: time_per_step.y + energy_step.height*1.25
            }
        }

        SpecterChart {
            id: specter_chart
            width: parent.width - side_panel.width
            height: parent.height

            anchors.left: parent.left
            anchors.top: parent.top
        }
    }

    VISA_Settings {
        id: visa_settings
    }

    FileDialog {
        id: save_dialog
        visible: false
        selectFolder: false
        selectExisting: false

        folder: shortcuts.home

        title: "Save"
        nameFilters: [ "Plain Text (*.txt)" ,
                       "XML Document (*xml)",
                       "Comma Separarated Values (*.csv)"]

        onAccepted: {
            var name_filter
            if (selectedNameFilter == "Plain Text (*.txt)")
                name_filter = ".txt"
            else if (selectedNameFilter == "XML Document (*xml)")
                name_filter = ".xml"
            else
                name_filter = ".csv"

            controller.save(folder,fileUrl,name_filter)
        }
    }

    Start_Dialog {
        id: start_dialog
    }

    function set_energy_step(e_ste) {
        var aux_string = "Energy Step: "
        aux_string += Number(e_ste).toLocaleString(
                    Qt.locale("en_US"),'g')
        aux_string += " eV"
        energy_step.text = aux_string
    }

    function set_specter_num(specter_n, specters) {
        var aux_string = "Specter nº: "
        aux_string += Number(specter_n).toString()
        aux_string += " of "
        aux_string += Number(specters).toString()
        specter_num.text = aux_string
    }

    function set_time_per_step(ste_time) {
        var aux_string = "Time per step: "
        aux_string += Number(ste_time).toString()
        aux_string += " ms"
        time_per_step.text = aux_string
    }

    function has_started() {
        start_button.text = "Stop"
        start_button.Material.accent = Material.Red
        save_button.enabled = false
        settings_button.enable_visa_settings(false)
    }

    function has_stopped() {
        start_button.text = "Start"
        start_button.Material.accent = Material.Green
        save_button.enabled = true
        settings_button.enable_visa_settings(true)
    }

    function set_specter_point(n, x, y) {
        specter_chart.set_point(n,x,y)
    }

    function set_specter_points(n) {
        specter_chart.set_point_count(n)
    }

    function set_specter_lin_axisY_max(max) {
        specter_chart.set_lin_axisY_max(max)
    }

    function set_specter_lin_axisY_min(min) {
        specter_chart.set_lin_axisY_min(min)
    }

    function set_specter_lin_axisX_max(max) {
        specter_chart.set_lin_axisX_max(max)
    }

    function set_specter_lin_axisX_min(min) {
        specter_chart.set_lin_axisX_min(min)
    }
}
