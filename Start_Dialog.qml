import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Dialog {
    id: start_dialog
    title: "Start"

    contentItem: Rectangle {
        color: "#f2f2f2"

        implicitHeight: Math.round(80*Screen.pixelDensity)
        implicitWidth: Math.round(180*Screen.pixelDensity)

        Flickable {
            height: parent.height - Math.round(2*Screen.pixelDensity) -
                    start.height - parent.button_space
            width: parent.width - Math.round(4*Screen.pixelDensity)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ScrollBar.vertical: ScrollBar {}

            contentHeight: flick_item.height
            contentWidth: flick_item.width

            Item {
                id: flick_item

                width: parent.parent.width
                height: childrenRect.height

                property int label_width: parent.width / 3.0
                property int txt_width: Math.round(45*Screen.pixelDensity)

                Grid {
                    id: grid1

                    rows: 2
                    columns: 2

                    anchors.left: parent.left
                    anchors.top: parent.top

                    verticalItemAlignment: Grid.AlignVCenter
                    spacing: Math.round(2*Screen.pixelDensity)

                    Label {
                        text: qsTr("Operator name:")
                        verticalAlignment: Label.AlignVCenter
                    }

                    TextField {
                        id: operator_name_txt
                        width: Math.round(120*Screen.pixelDensity)
                        verticalAlignment: TextField.AlignVCenter
                    }

                    Label {
                        text: qsTr("Specter name:")
                        verticalAlignment: Label.AlignVCenter
                    }

                    TextField {
                        id: spec_name_txt
                        width: operator_name_txt.width
                        verticalAlignment: TextField.AlignVCenter
                    }
                }

                Item {
                    id: spacer_1

                    height: Math.round(5*Screen.pixelDensity)
                    anchors.top: grid1.bottom
                }

                Grid {
                    id: grid2

                    rows: 2
                    columns: 3

                    anchors.top: spacer_1.bottom
                    width: parent.width

                    Label {
                        text: "Lower Bound [eV]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Upper Bound [eV]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Data points"
                        width: parent.parent.label_width
                    }

                    TextField {
                        id: l_bound_txt
                        width: parent.parent.txt_width
                        text: "0"

                        validator: DoubleValidator{
                            bottom: 0
                            top: 23.0
                        }

                        onFocusChanged: correct_bounds()
                    }

                    TextField {
                        id: u_bound_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator{
                            bottom: 0
                            top: 23.0
                        }

                        onFocusChanged: correct_bounds()
                    }

                    TextField {
                        id: n_points_txt
                        width: l_bound_txt.width
                        text: "2"

                        validator: IntValidator{
                            bottom:2
                        }
                    }
                }

                Item {
                    id: spacer_2

                    height: spacer_1.height
                    anchors.top: grid2.bottom
                }

                Grid {
                    id: grid3

                    rows: 2
                    columns: 3

                    anchors.top: spacer_2.bottom
                    width: parent.width

                    Label {
                        text: "Pedestal Voltage [V]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Channeltron Voltage [V]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "He current [A]"
                        width: parent.parent.label_width
                    }

                    TextField {
                        id: ped_volt_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator {
                            bottom: 0
                        }
                    }

                    TextField {
                        id: chn_volt_txt
                        width: l_bound_txt.width
                        text: "0"
                        validator: DoubleValidator {}
                    }

                    TextField {
                        id: h_current_txt
                        width: l_bound_txt.width
                        text: "0"
                        validator: DoubleValidator {}
                    }
                }

                Item {
                    id: spacer_3

                    height: spacer_1.height
                    anchors.top: grid3.bottom
                }

                Grid {
                    id: grid4

                    rows: 2
                    columns: 3

                    anchors.top: spacer_3.bottom
                    width: parent.width

                    Label {
                        text: "Timer per step [ms]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Vertical Magnetic Field [T]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Horizontal Magnetic Field [T]"
                        width: parent.parent.label_width
                    }

                    TextField {
                        id: time_per_step_txt
                        width: l_bound_txt.width
                        text: "20"

                        validator: IntValidator { }

                        onFocusChanged: {
                            var ste_time = Number(text)
                            ste_time = ste_time < 100 ? 100 : ste_time
                            text = ste_time
                        }
                    }

                    TextField {
                        id: vm_field_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator {
                            bottom: 0
                        }
                    }

                    TextField {
                        id: hm_field_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator {
                            bottom: 0
                        }
                    }
                }

                Item {
                    id: spacer_4

                    height: spacer_1.height
                    anchors.top: grid4.bottom
                }

                Grid {
                    id: grid5

                    rows: 2
                    columns: 3

                    anchors.top: spacer_4.bottom
                    width: parent.width

                    Label {
                        text: "Collision Chamber Pressure [mBar]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Lamp Pressure [mBar]"
                        width: parent.parent.label_width
                    }

                    Label {
                        text: "Number of swipes"
                        width: parent.parent.label_width
                    }

                    TextField {
                        id: cc_pressure_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator{
                            bottom: 0
                        }
                    }

                    TextField {
                        id: l_pressure_txt
                        width: l_bound_txt.width
                        text: "0"

                        validator: DoubleValidator{
                            bottom: 0
                        }
                    }

                    TextField {
                        id: swipes_txt
                        width: l_bound_txt.width
                        text: "1"

                        validator: IntValidator { bottom: 0 }

                        onFocusChanged: {
                            var swipes = Number(text)
                            swipes = swipes < 1 ? 1 : swipes
                            text = swipes
                        }
                    }
                }
            }
        }

        property int button_space: Screen.pixelDensity*2

        Button {
            id: cancel

            height: start.height
            width: start.width

            text: qsTr("Cancel")

            Material.accent: Material.Red
            highlighted: true

            anchors.bottom: parent.bottom
            x: parent.width - width - parent.button_space/2

            onReleased: start_dialog.close()
        }

        Button {
            id: start

            height: Math.round(Screen.pixelDensity*12.5)
            width: Math.round(Screen.pixelDensity*40)

            text: qsTr("Start")

            Material.accent: Material.Green
            highlighted: true

            anchors.bottom: parent.bottom
            x: cancel.x - width - parent.button_space

            onReleased: set_start()
        }
    }

    onVisibleChanged: {
        if (visible)
        {
            operator_name_txt.text = controller.operatorName()
            spec_name_txt.text = controller.specterName()

            ped_volt_txt.text = controller.pedestalVoltage()
            chn_volt_txt.text = controller.channeltronVoltage()
            h_current_txt.text = controller.heliumCurrent()

            cc_pressure_txt.text = controller.collisionChamberPressure()
            l_pressure_txt.text = controller.lampPressure()

            var e_min = controller.lowerEnergyBound()
            var e_max = controller.upperEnergyBound()
            var n_point = Math.round((e_max - e_min) / controller.energyStep())
            n_point++;

            l_bound_txt.text = e_min
            u_bound_txt.text = e_max
            n_points_txt.text = n_point

            vm_field_txt.text = controller.verticalMagneticField()
            hm_field_txt.text = controller.horizontalMagneticField()

            time_per_step_txt.text = controller.stepTime()
            swipes_txt.text = controller.numSpecters()
        }
    }

    function correct_bounds() {
        var l_bound_n = Number(l_bound_txt.text)
        var u_bound_n = Number(u_bound_txt.text)

        l_bound_n = l_bound_n > 34 ? 34 : l_bound_n
        u_bound_n = u_bound_n > 34 ? 34 : u_bound_n

        if (l_bound_n > u_bound_n)
        {
            var top = l_bound_n
            var bot = u_bound_n

            l_bound_n = bot
            u_bound_n = top
        }

        l_bound_txt.text = l_bound_n
        u_bound_txt.text = u_bound_n
    }

    function set_start() {
        controller.setOperatorName(operator_name_txt.text)
        controller.setSpecterName(spec_name_txt.text)

        controller.setPedestalVoltage(Number(ped_volt_txt.text))
        controller.setChanneltronVoltage(Number(chn_volt_txt.text))
        controller.setHeliumCurrent(Number(h_current_txt.text))

        controller.setCollisionChamberPressure(Number(cc_pressure_txt.text))
        controller.setLampPressure(Number(l_pressure_txt.text))

        var e_max = 1.0*Number(u_bound_txt.text)
        var e_min = 1.0*Number(l_bound_txt.text)
        var n_ste = 1.0*Number(n_points_txt.text)

        n_ste = n_ste < 2 ? 2 : n_ste
        var e_ste = (e_max - e_min) / (n_ste - 1)

        controller.setLowerEnergyBound(e_min)
        controller.setUpperEnergyBound(e_max)
        controller.setEnergyStep(e_ste)

        controller.setVerticalMagneticField(Number(vm_field_txt.text))
        controller.setHorizontalMagneticField(Number(hm_field_txt.text))

        controller.setStepTime(Number(time_per_step_txt.text))
        controller.setNumSpecters(Number(swipes_txt.text))

        controller.start()
        start_dialog.close()
    }
}
