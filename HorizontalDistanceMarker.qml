import QtQuick 2.7
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.0

Item {
    id: h_center
    height: Math.round(Screen.pixelDensity*7)
    property double dx: 0

    //anchors.verticalCenter: parent.verticalCenter
    y: Math.round(parent.height*0.15)
    Drag.active: true

    Item {
        id: background
        anchors.fill: parent
        opacity: parent.opacity*0.5

        LinearGradient {
            height: parent.height / 2.0
            width: parent.width

            start: Qt.point(0,0)
            end: Qt.point(0,height)

            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.4; color: "black" }
            }

            anchors.top: parent.top
            anchors.left: parent.left
        }

        LinearGradient {
            height: parent.height / 2.0
            width: parent.width

            start: Qt.point(0,height)
            end: Qt.point(0,0)

            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.4; color: "black" }
            }

            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }

    Text {
        id: dist_text
        text: dx.toLocaleString(Qt.locale("en_EN"),"G",4)
        font.pointSize: 8

        color: "white"

        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        drag.target: parent

        drag.minimumX: parent.x
        drag.maximumX: parent.x

        drag.minimumY: 1
        drag.maximumY: parent.parent.height - parent.height - 1
    }
}
