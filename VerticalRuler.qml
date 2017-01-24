import QtQuick 2.7
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

Item {
    property string color: "cyan"
    property bool log: false

    x: -space
    y: rel_y * parent.height - height + space

    property int hide_duration: 150

    property int space: Math.round(Screen.pixelDensity*5)

    property double max_y: 100
    property double min_y: 0

    height: Math.round(Screen.pixelDensity*2 + r1_text.height) + 2*space
    width: Math.round(parent.width) + 2*space

    Drag.active: true
    property double rel_y: 0.75

    layer.enabled: true

    Item {
        id: marker_item

        height: parent.height - 2*parent.space
        width: parent.width - 2*parent.space

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled:  true
        visible: false

        Rectangle {
            id: ruler

            height: Math.round(Screen.pixelDensity)
            width: Math.round(parent.width - r1.width / 2.0)
            radius: height / 2.0

            anchors.left: parent.left
            anchors.bottom: parent.bottom

            color: parent.parent.color
        }

        Rectangle {
            id: r1

            height: parent.height
            width: Math.round(Screen.pixelDensity*4 + r1_text.width)

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            radius: Screen.pixelDensity
            color: ruler.color
        }

        Rectangle {
            id: r2

            height: r1.height / 2
            width: r1.width / 2

            anchors.bottom: r1.bottom
            anchors.left: r1.left

            color: r1.color
        }

        Rectangle {
            id: r3_source

            height: r3_mask.height / 2.0
            width: r3_mask.width / 2.0

            color: r1.color
            visible: false

            anchors.right: r3_mask.right
            anchors.bottom: r3_mask.bottom
        }

        Rectangle {
            id: r3_mask

            height: r1.height - ruler.height
            width: r1.width
            radius: r1.radius

            visible: false

            anchors.right: r1.left
            anchors.bottom: ruler.top

            Rectangle {
                height: parent.height / 2.0
                width: parent.width / 2.0

                anchors.right: parent.right
                anchors.top: parent.top
            }

            Rectangle {
                height: parent.height / 2.0
                width: parent.width / 2.0

                anchors.left: parent.left
                anchors.top: parent.top
            }

            Rectangle {
                height: parent.height / 2.0
                width: parent.width / 2.0

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
        duration: hide_duration
    }

    DropShadow {
        id: shadow_effect

        anchors.fill: marker_item
        horizontalOffset: 0
        verticalOffset: Math.round(Screen.pixelDensity*0.5)
        radius: Math.round(Screen.pixelDensity*2)
        samples: 17
        color: "#80000000"
        source: marker_item
    }

    MouseArea {
        height: r1.height
        width: r1.width

        x: parent.width-width-parent.space
        y: parent.space

        drag.target: parent

        drag.minimumX: -parent.space
        drag.maximumX: -parent.space

        drag.minimumY: -parent.space - shadow_effect.height
        drag.maximumY: parent.parent.height - parent.space -
                       shadow_effect.height

        onPositionChanged: {
            rel_y = (parent.y + parent.height - parent.space) /
                    parent.parent.height
            set_text()
        }
    }

    function show(to_show) {
        enabled = to_show
        hide_animation.stop()
        hide_animation.to = to_show ? 1 : 0
        hide_animation.from = opacity
        hide_animation.start()
    }

    function set_text() {
        if (log)
        {

        }
        else
        {
            var dy = max_y - min_y
            var pos = (1 - rel_y)*dy + min_y
            r1_text.text = pos.toLocaleString(Qt.locale("en_EN"),"G",4)
        }
    }

    onLogChanged: set_text()
    onRel_yChanged: set_text()
    Component.onCompleted: set_text()
}

