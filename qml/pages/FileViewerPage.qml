import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: fileViewerPage

    property string repositoryOwner
    property string repositoryName
    property string filePath
    property string fileName
    property string fileContent: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/blob/main/" + filePath)
            }
            MenuItem {
                text: "Copy content"
                onClicked: {
                    Clipboard.text = fileContent
                    appWindow.showNotification("Content copied to clipboard")
                }
            }
        }

        Column {
            id: contentColumn
            width: parent.width
            spacing: 0

            PageHeader {
                title: fileName
                description: repositoryName
            }

            Rectangle {
                width: parent.width
                height: codeLabel.height + Theme.paddingLarge * 2
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)

                Label {
                    id: codeLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.paddingLarge
                    }
                    text: formatCodeWithLineNumbers(fileContent)
                    color: Theme.primaryColor
                    font.family: "Monospace"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                }
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: githubApi.loading && fileContent.length === 0
        size: BusyIndicatorSize.Large
    }

    Connections {
        target: githubApi
        onFileContentReceived: {
            if (file.content) {
                // Decode base64 content
                fileContent = Qt.atob(file.content.replace(/\n/g, ''))
            }
        }
    }

    Component.onCompleted: {
        githubApi.fetchFileContent(repositoryOwner, repositoryName, filePath)
    }

    function formatCodeWithLineNumbers(code) {
        if (!code) return ""

        var lines = code.split('\n')
        var result = []
        var lineNumWidth = String(lines.length).length

        for (var i = 0; i < lines.length; i++) {
            var lineNum = String(i + 1)
            // Pad line number
            while (lineNum.length < lineNumWidth) {
                lineNum = ' ' + lineNum
            }

            // Escape HTML
            var line = lines[i]
            line = line.replace(/&/g, '&amp;')
            line = line.replace(/</g, '&lt;')
            line = line.replace(/>/g, '&gt;')

            // Basic syntax highlighting for common patterns
            line = highlightSyntax(line)

            result.push('<font color="' + Theme.secondaryColor + '">' + lineNum + '</font>  ' + line)
        }

        return result.join('<br>')
    }

    function highlightSyntax(line) {
        // Comments
        if (line.match(/^\s*(\/\/|#|<!--)/)) {
            return '<font color="' + Theme.secondaryHighlightColor + '">' + line + '</font>'
        }

        // Strings
        line = line.replace(/"([^"]*)"/g, '<font color="' + Theme.highlightColor + '">"$1"</font>')
        line = line.replace(/'([^']*)'/g, '<font color="' + Theme.highlightColor + '">\'$1\'</font>')

        // Keywords (basic)
        var keywords = ['function', 'var', 'let', 'const', 'if', 'else', 'for', 'while', 'return', 'import', 'export', 'class', 'def', 'print']
        for (var i = 0; i < keywords.length; i++) {
            var keyword = keywords[i]
            var regex = new RegExp('\\b' + keyword + '\\b', 'g')
            line = line.replace(regex, '<b>' + keyword + '</b>')
        }

        return line
    }
}
