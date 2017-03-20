import QtQuick 2.7
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

Item {
    property string color: "cyan"
    property bool log: false

    x: parent.width*rel_x - space
    y: -space
    z: 5

    property int hide_duration: 150

    property double max_x: 100
    property double min_x: 0

    property int space: pixel_density*5

    height: Math.round(parent.height) + 2*space
    width:  Math.round(r1_text.width + pixel_density*4) + 2*space

    Drag.active: true
    property double rel_x: 0.75

    layer.enabled: true

    Item {
        id: marker_item
        layer.enabled: true

        height: parent.height - 2*space
        width: parent.width - 2*space
        visible: false

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        property int space: parent.space

        Rectangle {
            id: ruler
            color: parent.parent.color

            height: Math.round(parent.height - r1.height / 2.0)
            width: pixel_density

            anchors.left: parent.left
            anchors.bottom: parent.bottom

            radius: width / 2.0
        }

        Rectangle {
            id: r1
            color: parent.parent.color

            height: r1_text.height + pixel_density*2
            width: parent.width

            radius: Screen.pixelDensity
        }

        Rectangle {
            id: r2

            height: Math.round(r1.height / 2.0)
            width: Math.round(r1.width / 2.0)

            color: r1.color

            x: 0
            y: r1.height - height
        }

        Rectangle {
            id: r3_source

            height: Math.round(r3_mask.height / 2.0)
            width: Math.round(r3_mask.width / 2.0)
            visible: false

            x: r3_mask.x
            y: r3_mask.y

            color: r1.color
        }

        Rectangle {
            id: r3_mask

            height: r1.height
            width: r1.width
            visible: false

            x: ruler.width
            y: r1.height

            radius: r1.radius

            Rectangle {
                height: r3_source.height
                width: r3_source.width

                anchors.right: parent.right
                anchors.top: parent.top
            }

            Rectangle {
                height: r3_source.height
                width: r3_source.width

                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }

            Rectangle {
                height: r3_source.height
                width: r3_source.width

                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }
        }

        OpacityMask {
            anchors.fill: r3_mask

            source: r3_source
            maskSource: r3_mask
            invert: true
        }

        Text {
            id: r1_text
            anchors.verticalCenter: r1.verticalCenter
            anchors.horizontalCenter: r1.horizontalCenter

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 8
        }
    }

    NumberAnimation on opacity {
        id: hide_animation

        from: 0
        to: 0
        duration: parent.hide_duration
    }

    DropShadow {
        id: shadow_effect

        anchors.fill: marker_item
        horizontalOffset: 0
        verticalOffset: Math.round(pixel_density*0.5)
        radius: pixel_density*2
        samples: 17
        color: "#80000000"
        source: marker_item
    }

    MouseArea {
        height: r1.height
        width:  r1.width

        x: parent.space
        y: parent.space

        drag.target: parent

        drag.minimumX: -parent.space
        drag.maximumX: parent.parent.width - parent.space

        drag.minimumY: -parent.space
        drag.maximumY: -parent.space

        onPositionChanged: {
            rel_x = (parent.x + parent.space) /
                    (parent.parent.width)
            set_text()
        }
    }

    function set_text() {
        if (log)
        {

        }
        else
        {
            var dx = max_x - min_x
            var pos = rel_x*dx + min_x
            r1_text.text = pos.toLocaleString(Qt.locale("en_EN"),"G",4)
        }
    }

    function show(to_show) {
        enabled = to_show
        hide_animation.stop()
        hide_animation.from = opacity
        hide_animation.to = to_show ? 1 : 0
        hide_animation.start()
    }

    onLogChanged: set_text()
    onRel_xChanged: set_text()
    Component.onCompleted: set_text()
}
