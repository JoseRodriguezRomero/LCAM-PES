import QtQuick 2.7
import QtCharts 2.1
import QtQuick.Controls.Material 2.0

ChartView {
    id: chart

    theme: ChartView.ChartThemeLight

    legend.visible: false
    antialiasing: true

    property double zoom_f: 1.0

    Markers {
        id: markers

        max_x: data_series.axisX.max
        min_x: data_series.axisX.min

        max_y: data_series.axisY.max
        min_y: data_series.axisY.min
    }

    ValueAxis {
        id: xAxis

        min: 0
        max: 10
        minorTickCount: 4

        titleText: "Energy [eV]"
        labelFormat: "%.3G"
    }

    ValueAxis {
        id: yAxis

        min: 0
        max: 10
        minorTickCount: 4

        titleText: "Counts [a.u.]"
        labelFormat: xAxis.labelFormat
    }

    LogValueAxis {
        id: xAxis_log

        min: 1E-3
        max: 1E2

        titleText: xAxis.titleText
        labelFormat: xAxis.labelFormat
    }

    LogValueAxis {
        id: yAxis_log

        min: 0
        max: 100

        titleText: yAxis.titleText
        labelFormat: xAxis.labelFormat
    }

    LineSeries {
        id: data_series
        color: "Grey"
        width: 2

        axisX: xAxis
        axisY: yAxis
    }

    LineSeries {
        id: current_pos
        color: "green"
        width: 2

        axisX: data_series.axisX
        axisY: data_series.axisY
    }

    function set_xlog(is_log) {
        h_markers.log = is_log
    }

    function set_ylog(is_log) {

    }

    function show_horizontal_rulers(show) {
        markers.h_show(show)
    }

    function show_vertical_rulers(show) {
        markers.v_show(show)
    }

    function set_point(n, x, y) {
        data_series.remove(n)
        data_series.insert(n,x,y)

        current_pos.remove(0)
        current_pos.remove(0)

        current_pos.insert(0,x,current_pos.axisY.max)
        current_pos.insert(0,x,current_pos.axisY.min)

        if (y > yAxis.max)
        {
            var aux_y = Math.ceil(y/10.0) * 10.0
            yAxis.max = aux_y
        }
    }

    function set_point_count(n) {
        data_series.removePoints(0,data_series.count)
        for (var i = 0; i < n; i++)
        {
            data_series.append(0.0,0.0)
        }
    }

    function set_lin_axisY_max(max) {
        yAxis.max = max
    }

    function set_lin_axisY_min(min) {
        yAxis.min = min
    }

    function set_lin_axisX_max(max) {
        xAxis.max = max
    }

    function set_lin_axisX_min(min) {
        xAxis.min = min
    }

    Component.onCompleted: {
        var x = current_pos.axisX.min

        current_pos.insert(0,x,current_pos.axisY.max)
        current_pos.insert(0,x,current_pos.axisY.min)
    }
}
