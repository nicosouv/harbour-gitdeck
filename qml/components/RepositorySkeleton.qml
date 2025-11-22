import QtQuick 2.0
import Sailfish.Silica 1.0

// Skeleton loader for repository items
Item {
    id: skeleton
    height: Theme.itemSizeLarge + Theme.paddingLarge * 2
    width: parent ? parent.width : 0

    Column {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingSmall

        // Title
        SkeletonItem {
            width: parent.width * 0.6
            height: Theme.fontSizeMedium + Theme.paddingSmall
        }

        // Description
        SkeletonItem {
            width: parent.width * 0.9
            height: Theme.fontSizeExtraSmall * 2 + Theme.paddingSmall
        }

        // Metadata
        Row {
            spacing: Theme.paddingLarge

            SkeletonItem {
                width: Theme.itemSizeSmall
                height: Theme.fontSizeExtraSmall + Theme.paddingSmall
            }

            SkeletonItem {
                width: Theme.itemSizeSmall * 0.7
                height: Theme.fontSizeExtraSmall + Theme.paddingSmall
            }
        }
    }
}
