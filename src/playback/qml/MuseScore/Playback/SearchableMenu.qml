/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Muse.Ui 1.0
import Muse.UiComponents 1.0
import Muse.Audio 1.0
import MuseScore.Playback 1.0

Item {
    width: 400
    height: 600

    property alias model: listView.model

    ColumnLayout {
        spacing: 10

        TextField {
            id: searchBox
            placeholderText: "Search..."
            onTextChanged: {
                proxyModel.filterPattern = text
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: proxyModel

            delegate: ItemDelegate {
                width: listView.width
                text: model.display
            }
        }
    }

    SortFilterProxyModel {
        id: proxyModel
        sourceModel: menuModel
        filterRole: "display"
        filterCaseSensitivity: Qt.CaseInsensitive
        filterRegExp: ""
    }
}
