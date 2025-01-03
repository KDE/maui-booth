// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQml
import QtQuick
import QtQuick.Controls
import QtMultimedia

import org.mauikit.controls as Maui

import org.mauikit.filebrowsing as FB

import org.kde.prison.scanner as Prison

import "../widgets"

Pane
{
    id: cameraPage
    padding: 0
    property bool manualMode: false
    readonly property alias camera : _camera
    readonly property alias mediaDevices: _mediaDevices

    state: "PhotoCapture"

    background: Rectangle
    {
        color: "black"
    }

    states: [
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    // camera.captureMode = Camera.CaptureStillImage
                    camera.start()
                }
            }
        },
        State {
            name: "PhotoPreview"
        },
        State {
            name: "VideoCapture"
            StateChangeScript {
                script: {
                    // camera.captureMode = Camera.CaptureVideo
                    camera.start()
                }
            }
        },
        State {
            name: "VideoPreview"
            StateChangeScript {
                script: {
                    camera.stop()
                }
            }
        }
    ]

    contentItem: PinchArea
    {
        pinch.minimumScale: 0
        pinch.maximumScale: camera.maximumDigitalZoom
        enabled: camera.maximumDigitalZoom > 1 && Maui.Handy.isTouch

        onPinchUpdated:
        {
            console.log("PINCH ZOOMING", pinch.previousScale)
            camera.setDigitalZoom(Math.round(pinch.previousScale + pinch.scale))
            pinch.accepted = true
        }

        MediaDevices
        {
            id: _mediaDevices
        }

        CaptureSession
        {
            imageCapture: ImageCapture
            {
                onImageCaptured:
                {
                    _previewImage.source = preview
                    //                        stillControls.previewAvailable = true
                    //                        cameraPage.state = "PhotoPreview"
                }
            }


            camera: Camera
            {
                id: _camera
                        cameraDevice: mediaDevices.defaultVideoInput
                focusMode: Camera.FocusModeAutoNear
                //                    flash.mode: Camera.FlashRedEyeReduction
                //                    imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait

                //                            focusPointMode: Camera.FocusPointCustom
                customFocusPoint: Qt.point(0.2, 0.2) // Focus relative to top-left corner

            }

            videoOutput: viewfinder
        }

        VideoOutput
        {
            id: viewfinder
            // visible: cameraPage.state == "PhotoCapture" || cameraPage.state == "VideoCapture"
            anchors.fill: parent

            // autoOrientation: true

            // Repeater
            // {
            //     model: _camera.focus.focusZones

            //     Rectangle
            //     {
            //         border
            //         {
            //             width: 2
            //             color: status == Camera.FocusAreaFocused ? "green" : "white"
            //         }

            //         color: "transparent"

            //         // Map from the relative, normalized frame coordinates
            //         property variant mappedRect: viewfinder.mapNormalizedRectToItem(area);

            //         x: mappedRect.x
            //         y: mappedRect.y
            //         width: mappedRect.width
            //         height: mappedRect.height
            //     }
            // }


            Maui.Chip
            {
                text: _camera.digitalZoom+"x"
                visible: _camera.digitalZoom >1
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Maui.Style.space.big
            }

            Item
            {
                height: 100
                width: 100

                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: Maui.Style.space.big

                Image
                {
                    id: _previewImage
                    anchors.fill: parent
                    sourceSize.width: width
                    sourceSize.height: height

                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        Prison.VideoScanner
        {
            id: scanner
            // videoSink: viewFinder.videoSink
            // enabled: settings.readQR
            //         formats: Prison.Format.QRCode | Prison.Format.Aztec
            formats: Prison.Format.QRCode | Prison.Format.Aztec
            onResultChanged: (result) =>
                             {
                                 if (result.hasText) {
                                     console.log(result.text, result.format);
                                 } else if (result.hasBinaryData) {
                                     console.log("<binary content>", result.format);
                                 } else {
                                     console.log("no barcode found");
                                 }
                             }
        }



        Item
        {
            anchors.fill: parent

            Label
            {
                text: {
                    if (camera.lockStatus == Camera.Unlocked)
                        "Focus";
                    else if (camera.lockStatus == Camera.Searching)
                        "Focusing"
                    else
                        "Unlock"
                }
            }

            TapHandler
            {
                onTapped:
                {
                    var mappedPoint = viewfinder.mapPointToSourceNormalized(eventPoint.scenePosition);

                    var point = Qt.point(eventPoint.scenePosition.x/viewfinder.contentRect.width, mappedPoint.y/viewfinder.contentRect.height)

                    console.log("TAPPED POINT", point.x, point.y)
                    camera.focus.customFocusPoint = mappedPoint

                    if (camera.lockStatus == Camera.Unlocked)
                    {
                        camera.searchAndLock();
                    }
                    else
                    {
                        camera.unlock();
                        camera.searchAndLock();
                    }
                }

                onDoubleTapped:
                {
                    var mappedPoint = viewfinder.mapPointToSourceNormalized(eventPoint.scenePosition);

                    var point = Qt.point(eventPoint.scenePosition.x/viewfinder.contentRect.width, mappedPoint.y/viewfinder.contentRect.height)

                    console.log("TAPPED POINT", point.x, point.y)
                    camera.focus.customFocusPoint = mappedPoint

                    camera.searchAndLock();
                }
            }
        }

        Rectangle
        {
            color: "#80ff0000"
            x: viewfinder.mapRectToItem(scanner.result.boundingRect).x
            y: viewfinder.mapRectToItem(scanner.result.boundingRect).y
            width: viewfinder.mapRectToItem(scanner.result.boundingRect).width
            height: viewfinder.mapRectToItem(scanner.result.boundingRect).height

            Maui.Chip
            {
                z: parent.z + 9999
                anchors.top: parent.bottom
                anchors.left: parent.left

                text: scanner.result.text

                onClicked:
                {
                    console.log("Trying to open URL")
                    Qt.openUrlExternally(scanner.result.text)
                }
            }
        }

    }


    //            PhotoPreview
    //            {
    //                id : photoPreview
    //                anchors.fill : parent
    //                onClosed: cameraPage.state = "PhotoCapture"
    //                visible: cameraPage.state == "PhotoPreview"
    //                focus: visible
    //            }

    //            VideoPreview
    //            {
    //                id : videoPreview
    //                anchors.fill : parent
    //                onClosed: cameraPage.state = "VideoCapture"
    //                visible: cameraPage.state == "VideoPreview"
    //                focus: visible

    //                //don't load recorded video if preview is invisible
    //                source: visible ? camera.videoRecorder.actualLocation : ""
    //            }


    //            PhotoCaptureControls
    //            {
    //                id: stillControls
    //                anchors.fill: parent
    //                camera: camera
    //                visible: cameraPage.state == "PhotoCapture"
    //                onPreviewSelected: cameraPage.state = "PhotoPreview"
    //            }

    //            VideoCaptureControls
    //            {
    //                id: videoControls
    //                anchors.fill: parent
    //                camera: camera
    //                visible: cameraPage.state == "VideoCapture"
    //                onPreviewSelected: cameraPage.state = "VideoPreview"
    //            }

    function flipCamera()
    {

    }

    function capture()
    {
        if(cameraPage.state === "PhotoCapture" && camera.imageCapture.ready)
        {
            cameraPage.camera.imageCapture.capture()
        }

        if(cameraPage.state === "VideoCapture" && _cameraPage.camera.videoRecorder.recorderStatus == CameraRecorder.LoadedStatus)
        {

            cameraPage.camera.videoRecorder.record()
        }
    }

    Component.onCompleted:
    {
        cameraPage.state = "PhotoCapture"
    }
}

