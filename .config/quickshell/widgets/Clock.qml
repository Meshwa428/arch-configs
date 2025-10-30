// quickshell/widgets/Clock.qml

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: clockRoot 
    implicitWidth: 310
    implicitHeight: 220

    signal positionSaved(real newX, real newY)
    signal resetPosition()

    property color textColor: "white"
    property color shadowColor: "#98000000"

    Behavior on textColor { ColorAnimation { duration: 800; easing.type: Easing.OutCubic } }
    Behavior on shadowColor { ColorAnimation { duration: 800; easing.type: Easing.OutCubic } }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property point startPos: "0,0"
        
        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                startPos = Qt.point(clockRoot.parent.x, clockRoot.parent.y)
            }
        }
        
        onPositionChanged: (mouse) => {
            if (mouse.buttons & Qt.LeftButton) {
                var newX = startPos.x + mouse.x - mouse.startX
                var newY = startPos.y + mouse.y - mouse.startY
                
                clockRoot.parent.x = newX
                clockRoot.parent.y = newY
            }
        }
        
        onReleased: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                clockRoot.positionSaved(clockRoot.parent.x, clockRoot.parent.y)
            }
        }
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                clockRoot.resetPosition()
            }
        }
    }

    property string dayOfWeek: Qt.formatDateTime(new Date(), "dddd").toUpperCase()
    property string fullDate: Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
    property string timeStr: "-   " + Qt.formatDateTime(new Date(), "HH:mm") + "   -"

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            dayOfWeek = Qt.formatDateTime(new Date(), "dddd").toUpperCase()
            fullDate  = Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
            timeStr   = "-   " + Qt.formatDateTime(new Date(), "HH:mm") + "   -"
        }
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6
        width: clockRoot.implicitWidth

        // Day of week (shadow + main)
        Item {
            width: parent.width;
            height: 120
            Text {
                text: clockRoot.dayOfWeek;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 6
                font.family: "Anurati";
                font.pixelSize: 110;
                color: clockRoot.shadowColor
                font.letterSpacing: 10
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: clockRoot.dayOfWeek;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 0
                font.family: "Anurati";
                font.pixelSize: 110;
                color: clockRoot.textColor
                font.letterSpacing: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Date (shadow + main)
        Item {
            width: parent.width;
            height: 36
            Text {
                text: clockRoot.fullDate;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 4
                font.family: "Orbitron";
                font.pixelSize: 22;
                color: clockRoot.shadowColor
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: clockRoot.fullDate;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 0
                font.family: "Orbitron";
                font.pixelSize: 22;
                color: clockRoot.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Time (shadow + main)
        Item {
            width: parent.width;
            height: 40
            Text {
                text: clockRoot.timeStr;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 4
                font.family: "Orbitron";
                font.pixelSize: 26;
                color: clockRoot.shadowColor
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: clockRoot.timeStr;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: 0
                font.family: "Orbitron";
                font.pixelSize: 26;
                color: clockRoot.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}