// quickshell/shell.qml

import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "widgets"
import "modules/common"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: clockWindow
            property var modelData
            screen: modelData

            property string currentWallpaperPath: ""
            property real targetClockX: screen.width / 2
            property real targetClockY: screen.height / 2
            property color dominantColor: "#FFFFFF"

            // A PanelWindow must be anchored to the screen edges to become full-screen.
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            mask: Region {}
            WlrLayershell.layer: WlrLayer.Bottom

            // Timer to periodically check for wallpaper changes.
            Timer {
                interval: 3000
                repeat: true
                running: true
                onTriggered: getWallpaperProc.running = true
                Component.onCompleted: triggered()
            }

            Process {
                id: getWallpaperProc
                command: ["hydectl", "wallpaper", "get"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const newPath = text.trim();
                        if (newPath && newPath !== "unknown request" && newPath !== clockWindow.currentWallpaperPath) {
                            console.log("Wallpaper changed to:", newPath);
                            clockWindow.currentWallpaperPath = newPath;
                            updateClockPosition();
                        }
                    }
                }
            }

            function updateClockPosition() {
                if (content.width <= 0 || content.height <= 0 || clockWindow.currentWallpaperPath === "") {
                    return;
                }
                
                console.log("Analyzing wallpaper for best clock position...");
                console.log("Screen dimensions:", clockWindow.screen.width, "x", clockWindow.screen.height);
                console.log("Widget dimensions:", content.width, "x", content.height);
                
                leastBusyRegionProc.exec([
                    Quickshell.shellPath("scripts/least-busy-region.sh"),
                    clockWindow.currentWallpaperPath,
                    "--width", Math.floor(content.width),
                    "--height", Math.floor(content.height),
                    "--screen-width", clockWindow.screen.width,
                    "--screen-height", clockWindow.screen.height,
                    "--top-padding", "20",
                    "--bottom-padding", "100",
                    "--horizontal-padding", "100"
                ]);
            }
            
            Process {
                id: leastBusyRegionProc
                stdout: StdioCollector {
                    onStreamFinished: {
                        if (text.trim() === "") return;
                        try {
                            const result = JSON.parse(text);
                            if (result.error) {
                                console.error("Script error:", result.error);
                                return;
                            }
                            console.log("Found least busy region:", JSON.stringify(result));
                            clockWindow.targetClockX = result.center_x;
                            clockWindow.targetClockY = result.center_y;
                            clockWindow.dominantColor = result.dominant_color;
                        } catch (e) {
                            console.error("Failed to parse region data:", e, text);
                        }
                    }
                }
            }

            Item {
                id: content
                implicitWidth: clockWidget.implicitWidth
                implicitHeight: clockWidget.implicitHeight
                width: implicitWidth
                height: implicitHeight
                
                // Calculate clamped position whenever targets change
                property real clampedX: {
                    var safetyMargin = 20; // Extra margin to prevent text cutoff
                    var currentWidth = content.width;
                    if (Config.options.clock.manualPosition) {
                        return Math.max(safetyMargin, Math.min(Config.options.clock.x, 
                                                     clockWindow.screen.width - currentWidth - safetyMargin));
                    } else {
                        var leftX = clockWindow.targetClockX - currentWidth / 2;
                        return Math.max(safetyMargin, Math.min(leftX, clockWindow.screen.width - currentWidth - safetyMargin));
                    }
                }
                
                property real clampedY: {
                    var safetyMargin = 20; // Extra margin to prevent text cutoff
                    var currentHeight = content.height;
                    if (Config.options.clock.manualPosition) {
                        return Math.max(safetyMargin, Math.min(Config.options.clock.y, 
                                                     clockWindow.screen.height - currentHeight - safetyMargin));
                    } else {
                        var topY = clockWindow.targetClockY - currentHeight / 2;
                        return Math.max(safetyMargin, Math.min(topY, clockWindow.screen.height - currentHeight - safetyMargin));
                    }
                }
                
                // Bind position to clamped values
                x: clampedX
                y: clampedY
                
                onClampedXChanged: {
                    console.log("Position update - Target:", 
                                Math.floor(clockWindow.targetClockX - content.width/2),
                                Math.floor(clockWindow.targetClockY - content.height/2),
                                "Final:", Math.floor(clampedX), Math.floor(clampedY),
                                "Size:", content.width, "x", content.height);
                }
                
                // Trigger position update when size is known
                onWidthChanged: {
                    if (width > 0 && !Config.options.clock.manualPosition) {
                        Qt.callLater(updateClockPosition);
                    }
                }

                Behavior on x { 
                    enabled: !Config.options.clock.manualPosition
                    NumberAnimation { duration: 800; easing.type: Easing.OutCubic } 
                }
                Behavior on y { 
                    enabled: !Config.options.clock.manualPosition
                    NumberAnimation { duration: 800; easing.type: Easing.OutCubic } 
                }

                Clock {
                    id: clockWidget
                    textColor: Qt.color(clockWindow.dominantColor).hslLightness > 0.5 ? "#1A1A1A" : "#ffffff"
                    shadowColor: Qt.color(clockWindow.dominantColor).hslLightness > 0.5 ? "#9fffffff" : "#98000000"

                    onPositionSaved: (newX, newY) => {
                        console.log("Saving manual position:", newX, newY);
                        var clampedX = Math.max(0, Math.min(newX, clockWindow.screen.width - content.width));
                        var clampedY = Math.max(0, Math.min(newY, clockWindow.screen.height - content.height));
                        Config.options.clock.manualPosition = true;
                        Config.options.clock.x = clampedX;
                        Config.options.clock.y = clampedY;
                    }

                    onResetPosition: () => {
                        console.log("Resetting to automatic position.");
                        Config.options.clock.manualPosition = false;
                        updateClockPosition();
                    }
                }
            }
        }
    }
}