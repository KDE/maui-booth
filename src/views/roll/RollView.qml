import QtQuick.Controls 2.14
import QtQuick 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.2 as FB

Maui.Page
{
    id: control


    Kirigami.ScrollablePage
    {
        anchors.fill: parent


        Flow
        {

            //            property int rowCount: parent.width / (elements.itemAt(0).width + spacing)
            //            property int rowWidth: rowCount * elements.itemAt(0).width + (rowCount - 1) * spacing
            //            property int mar: (parent.width - rowWidth) / 2

            //            anchors {
            //                fill: parent
            //                leftMargin: mar
            //                rightMargin: mar
            //            }

            spacing: 6

            Repeater
            {
                id: elements
                model: Maui.BaseModel
                {
                    list: FB.FMList
                    {
                        path: "file:///home/camilo/Pictures"
                        filterType: Maui.FMList.IMAGE

                    }
                }
                delegate: Image
                {
                    sourceSize.height: 120
                    //        width: 100

                    fillMode: Image.PreserveAspectFit
                    source: model.path
                }

            }


        }
    }
}
