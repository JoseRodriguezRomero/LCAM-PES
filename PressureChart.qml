import QtQuick 2.7
import QtCharts 2.1

ChartView {
    id: pressure_chart

    theme: ChartView.ChartThemeLight

    legend.visible: false
    antialiasing: true
    localizeNumbers: true

    LogValueAxis {
        id: yAxis
        min: 1E-3
        max: 1

        labelFormat: "%.2E"

        titleText: "Pressure [mbar]"
    }

    ValueAxis {
        id: xAxis
        min: 0
        max: 1

        titleText: "Time [s]"
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

    function reset() {
        data_series.clear()
        xAxis.min = 0
        xAxis.max = 0
    }

    function addPoint(t,p) {
        data_series.append(t,p)

        if (yAxis.max < t)
        {
            yAxis.max = t
        }
    }
}
