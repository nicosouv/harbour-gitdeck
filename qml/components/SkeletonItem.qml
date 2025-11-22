import QtQuick 2.0
import Sailfish.Silica 1.0

// WebOS-style skeleton loader with shimmer effect
Rectangle {
    id: skeleton

    property int animationDuration: 1500

    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
    radius: Theme.paddingSmall / 2

    // Shimmer effect
    Rectangle {
        id: shimmer
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: Theme.rgba(Theme.highlightColor, 0.15) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        SequentialAnimation on x {
            running: skeleton.visible
            loops: Animation.Infinite

            NumberAnimation {
                from: -skeleton.width
                to: skeleton.width
                duration: skeleton.animationDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
