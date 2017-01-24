import QtQuick 2.7
import QtCharts 2.1
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.0

Item {
    x: parent.plotArea.x
    y: parent.plotArea.y

    height: parent.plotArea.height
    width: parent.plotArea.width

    property double min_x: 0
    property double max_x: 10

    property double min_y: 0
    property double max_y: 10

    property bool h_log: false
    property bool v_log: false

    property int hide_duration: 500

    HorizontalRuler {
        id: h_marker1
        rel_x: 0.25

        color: Material.color(Material.Blue)
        log: parent.h_log

        min_x: parent.min_x
        max_x: parent.max_x

        hide_duration: parent.hide_duration

        onRel_xChanged: {
            parent.resize_h_center()
        }

        onXChanged: {
            parent.resize_h_center()
        }
    }

    HorizontalRuler {
        id: h_marker2
        rel_x: 0.75

        color: Material.color(Material.Red)
        log: parent.h_log

        min_x: parent.min_x
        max_x: parent.max_x

        hide_duration: parent.hide_duration

        onRel_xChanged: {
            parent.resize_h_center()
        }
    }

    HorizontalDistanceMarker {
        id: h_center
        opacity: h_marker1.opacity
    }

    Item {

    }

    VerticalRuler {
        id: v_marker1
        rel_y: 0.25

        color: Material.color(Material.LightGreen)
        log: parent.v_log

        min_y: parent.min_y
        max_y: parent.max_y

        hide_duration: parent.hide_duration
    }

    VerticalRuler {
        id: v_marker2
        rel_y: 0.75

        color: Material.color(Material.Yellow)
        log: parent.v_log

        min_y: parent.min_y
        max_y: parent.max_y

        hide_duration: parent.hide_duration
    }

    function resize_h_center() {
        var rel_x, val_x

        if (h_marker1.x >= h_marker2.x)
        {
            h_center.width = h_marker1.x - h_marker2.x
            h_center.x = h_marker2.x + h_marker2.space

            rel_x = h_marker1.rel_x - h_marker2.rel_x
            val_x = rel_x*(max_x-min_x)
            h_center.dx = val_x
        }
        else
        {
            h_center.width = h_marker2.x - h_marker1.x
            h_center.x = h_marker1.x + h_marker1.space

            rel_x = h_marker2.rel_x - h_marker1.rel_x
            val_x = rel_x*(max_x-min_x)
            h_center.dx = val_x
        }
    }

    function h_show(to_show) {
        h_marker1.show(to_show)
        h_marker2.show(to_show)
    }

    function v_show(to_show) {
        v_marker1.show(to_show)
        v_marker2.show(to_show)
    }

    function set_h_markers_tex() {
        h_marker1.min_x = min_x
        h_marker1.max_x = max_x

        h_marker2.min_x = min_x
        h_marker2.max_x = max_x

        h_marker1.set_text()
        h_marker2.set_text()
    }

    function set_v_markers_text() {
        v_marker1.min_y = min_y
        v_marker1.max_y = max_y

        v_marker2.min_y = min_y
        v_marker2.max_y = max_y

        v_marker1.set_text()
        v_marker2.set_text()
    }

    onMax_xChanged: set_h_markers_tex()
    onMin_xChanged: set_h_markers_tex()
    onMax_yChanged: set_v_markers_text()
    onMin_yChanged: set_v_markers_text()
}
