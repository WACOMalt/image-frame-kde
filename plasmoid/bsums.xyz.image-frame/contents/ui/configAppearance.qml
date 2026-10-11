/*
 *  SPDX-FileCopyrightText: 2026 BSumsXYZ <ben@bsums.xyz>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // Values of PlasmaCore.Types.BackgroundHints.
    property int cfg_backgroundHint: 0
    property int cfg_backgroundHintDefault: 0
    property alias cfg_showOpenButton: showOpenButtonBox.checked
    property bool cfg_showOpenButtonDefault: false
    property alias cfg_showNavigationButtons: showNavigationButtonsBox.checked
    property bool cfg_showNavigationButtonsDefault: true

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: backgroundBox
            Kirigami.FormData.label: i18nc("@label:listbox", "Background:")
            textRole: "text"
            valueRole: "value"
            model: [
                {
                    text: i18nc("@item:inlistbox", "None (transparent)"),
                    description: i18nc("@info", "Only the picture is drawn. Transparent areas of the picture show the desktop."),
                    value: 0
                },
                {
                    text: i18nc("@item:inlistbox", "Standard"),
                    description: i18nc("@info", "The Plasma theme's widget background, as in Media Frame."),
                    value: 1
                },
                {
                    text: i18nc("@item:inlistbox", "Translucent"),
                    description: i18nc("@info", "A see-through version of the Plasma theme's widget background."),
                    value: 2
                }
            ]
            currentIndex: Math.max(0, [0, 1, 2].indexOf(root.cfg_backgroundHint))
            onActivated: index => root.cfg_backgroundHint = model[index].value
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: backgroundBox.model[backgroundBox.currentIndex]
                ? backgroundBox.model[backgroundBox.currentIndex].description : ""
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: showOpenButtonBox
            Kirigami.FormData.label: i18nc("@label:checkbox", "On hover, show:")
            text: i18nc("@option:check", "Button to open the picture in a viewer")
        }

        QQC2.CheckBox {
            id: showNavigationButtonsBox
            text: i18nc("@option:check", "Previous and next buttons")
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
            text: i18nc("@info", "The previous and next buttons only show when there is more than one picture.")
        }
    }
}
