import QtQuick 2.7
import QtCharts 2.1
import QtQuick.Controls.Material 2.0

ChartView {
    id: chart

    theme: ChartView.ChartThemeLight

    legend.visible: false
    antialiasing: true

    property double zoom_f: 0.0

    property real max_x: 0.0
    property real min_x: 10.0
    property real zoom_x_ste: 0

    property real max_y: 0.0
    property real min_y: 10.0
    property real zoom_y_ste: 0

    property int current_point: 0
    property int point_count: 0

    MouseArea {
        x: parent.plotArea.x
        y: parent.plotArea.y

        height: parent.plotArea.height
        width: parent.plotArea.width

        Rectangle {
            id: zoom_rect

            color: "grey"
            border.color: "black"
            border.width: 1
            visible: false

            opacity: 0.4

            property int rect_pos_x: 0
            property int rect_pos_y: 0

            property int mouseX: parent.mouseX < 0 ? 0 : (
            parent.mouseX > parent.width ? parent.width : parent.mouseX)
            property int mouseY: parent.mouseY < 0 ? 0 : (
            parent.mouseY > parent.height ? parent.height : parent.mouseY)

            property int dx: rect_pos_x-mouseX
            property int dy: rect_pos_y-mouseY

            x: dx > 0 ? mouseX : rect_pos_x
            y: dy > 0 ? mouseY : rect_pos_y

            width: Math.abs(dx)
            height: Math.abs(dy)
        }

        onDoubleClicked: {
            parent.zoomReset()
        }

        onPressed: {
            zoom_rect.rect_pos_x = mouseX
            zoom_rect.rect_pos_y = mouseY
            zoom_rect.visible = true
        }

        onReleased: {
            zoom_rect.visible = false

            var zx = x+zoom_rect.x
            var zy = y+zoom_rect.y
            var zw = zoom_rect.width
            var zh = zoom_rect.height

            var zoom_r1 = Qt.rect(zx,zy,zw,zh)
            parent.zoomIn(zoom_r1)
        }
    }

    Markers {
        id: markers

        max_x: data_series.axisX.max
        min_x: data_series.axisX.min

        max_y: data_series.axisY.max
        min_y: data_series.axisY.min
    }

    ValueAxis {
        id: xAxis

        min: chart.min_x
        max: chart.max_x
        minorTickCount: 4

        titleText: "Energy [eV]"
    }

    ValueAxis {
        id: yAxis

        min: chart.min_y
        max: chart.max_y
        minorTickCount: 4

        titleText: "Counts [a.u.]"
        labelFormat: xAxis.labelFormat
    }

    LineSeries {
        id: data_series
        color: "grey"
        width: 2
        visible: true

        axisX: xAxis
        axisY: yAxis

        useOpenGL: true
    }

    LineSeries {
        id: kineticE_data_series
        color: "grey"
        width: 2
        visible: false

        axisX: xAxis
        axisY: yAxis

        useOpenGL: true
    }

    LineSeries {
        id: bindingE_data_series
        color: "grey"
        width: 2
        visible: false

        axisX: xAxis
        axisY: yAxis

        useOpenGL: true
    }

    LineSeries {
        id: current_pos
        color: "green"
        width: 2

        axisX: data_series.axisX
        axisY: data_series.axisY

        useOpenGL: true
    }

    function show_horizontal_rulers(show) {
        markers.h_show(show)
    }

    function show_vertical_rulers(show) {
        markers.v_show(show)
    }

    function set_point(n, x, y) {
        var kx = x + controller.analyzerPassEnergy()
        var bx = 21.22 - controller.analyzerPassEnergy() - x
        current_point = n

        if (n < data_series.count)
        {
            var old_x = data_series.at(n).x
            var old_y = data_series.at(n).y

            var old_kx = kineticE_data_series.at(n).x
            var old_ky = kineticE_data_series.at(n).y

            var old_bx = bindingE_data_series.at(n).x
            var old_by = bindingE_data_series.at(n).y

            data_series.replace(old_x,old_y,x,y)
            kineticE_data_series.replace(old_kx,old_ky,kx,y)
            bindingE_data_series.replace(old_bx,old_by,bx,y)
        }
        else
        {
            data_series.append(x,y)
            kineticE_data_series.append(kx,y)
            bindingE_data_series.append(bx,y)
        }

        current_pos.remove(0)
        current_pos.remove(0)

        var cx = 0
        if (data_series.visible)
            cx = x
        else if (kineticE_data_series.visible)
            cx = kx
        else
            cx = bx

        current_pos.insert(0,cx,current_pos.axisY.max)
        current_pos.insert(0,cx,current_pos.axisY.min)

        if (y > yAxis.max)
        {
            var aux_y = Math.ceil((y)/10.0) * 10.0
            yAxis.max = aux_y
        }
    }

    function set_point_count(n) {
        data_series.clear()
        kineticE_data_series.clear()
        bindingE_data_series.clear()
        var e_ste = controller.energyStep()

        point_count = n
        current_point = 0

        yAxis.max = 10.0
        yAxis.min = 0
        xAxis.max = controller.upperEnergyBound()
        xAxis.min = controller.lowerEnergyBound()

        if (data_series.visible)
            set_to_standard()
        else if (kineticE_data_series.visible)
            set_to_kineticE()
        else
            set_to_bindingE()
    }

    function set_axisY_max(max) {
        max_y = max
    }

    function set_axisY_min(min) {
        min_y = min
    }

    function set_axisX_max(max) {
        max_x = max
    }

    function set_axisX_min(min) {
        min_x = min
    }

    function set_to_standard() {
        xAxis.max = controller.upperEnergyBound()
        xAxis.min = controller.lowerEnergyBound()
        xAxis.titleText = "DAC Voltage [V]"

        data_series.visible = true
        kineticE_data_series.visible = false
        bindingE_data_series.visible = false

        var dx = (xAxis.max - xAxis.min) / (point_count - 1)
        var cx = xAxis.min + dx * current_point

        current_pos.remove(0)
        current_pos.remove(0)

        current_pos.insert(0,cx,current_pos.axisY.max)
        current_pos.insert(0,cx,current_pos.axisY.min)
    }

    function set_to_kineticE() {
        var E0 = controller.analyzerPassEnergy()
        xAxis.max = controller.upperEnergyBound() + E0
        xAxis.min = controller.lowerEnergyBound() + E0
        xAxis.titleText = "Kinetic Energy [eV]"

        data_series.visible = false
        kineticE_data_series.visible = true
        bindingE_data_series.visible = false

        var dx = (xAxis.max - xAxis.min) / (point_count - 1)
        var cx = xAxis.min + dx * current_point

        current_pos.remove(0)
        current_pos.remove(0)

        current_pos.insert(0,cx,current_pos.axisY.max)
        current_pos.insert(0,cx,current_pos.axisY.min)
    }

    function set_to_bindingE() {
        var E0 = controller.analyzerPassEnergy()
        xAxis.min = 21.22 - E0 - controller.upperEnergyBound()
        xAxis.max = 21.22 - E0 - controller.lowerEnergyBound()
        xAxis.titleText = "Binding Energy [eV]"

        data_series.visible = false
        kineticE_data_series.visible = false
        bindingE_data_series.visible = true

        var dx = (xAxis.max - xAxis.min) / (point_count - 1)
        var cx = xAxis.min + dx * (point_count - 1 - current_point)

        current_pos.remove(0)
        current_pos.remove(0)

        current_pos.insert(0,cx,current_pos.axisY.max)
        current_pos.insert(0,cx,current_pos.axisY.min)
    }

    Component.onCompleted: {
        var x = current_pos.axisX.min

        current_pos.insert(0,x,current_pos.axisY.max)
        current_pos.insert(0,x,current_pos.axisY.min)
    }
}
