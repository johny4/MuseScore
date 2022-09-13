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

import MuseScore.Ui 1.0
import MuseScore.UiComponents 1.0
import MuseScore.AppShell 1.0

ListView {
    id: root

    height: contentItem.childrenRect.height
    width: contentWidth

    property alias appWindow: appMenuModel.appWindow

    orientation: Qt.Horizontal

    interactive: false

    model: appMenuModel

    function openedArea(menuLoader) {
        if (menuLoader.isMenuOpened) {
            if (menuLoader.menu.subMenuLoader && menuLoader.menu.subMenuLoader.isMenuOpened)
                return openedArea(menuLoader.menu.subMenuLoader)
            return Qt.rect(menuLoader.menu.x, menuLoader.menu.y, menuLoader.menu.width, menuLoader.menu.height)
        }
        return Qt.rect(0, 0, 0, 0)
    } 

    AppMenuModel {
        id: appMenuModel

        appMenuAreaRect: Qt.rect(root.x, root.y, root.width, root.height)
        openedMenuAreaRect: openedArea(menuLoader)

        onOpenMenuRequested: {
            prv.openMenu(menuId)
        }

        onCloseOpenedMenuRequested: {
            menuLoader.close()
        }
    }

    Component.onCompleted: {
        appMenuModel.load()
    }

    QtObject {
        id: prv

        property var openedMenu: null
        property bool needRestoreNavigationAfterClose: false
        property string lastOpenedMenuId: ""

        function openMenu(menuId, byHover) {
            for (var i = 0; i < root.count; ++i) {
                var item = root.itemAtIndex(i)
                if (Boolean(item) && item.menuId === menuId) {
                    needRestoreNavigationAfterClose = true
                    lastOpenedMenuId = menuId

                    if (!byHover) {
                        if (menuLoader.isMenuOpened && menuLoader.parent === item) {
                            menuLoader.close()
                            return
                        }
                    }

                    menuLoader.menuId = menuId
                    menuLoader.parent = item
                    menuLoader.open(item.item.subitems)

                    return
                }
            }
        }

        function hasNavigatedItem() {
            return appMenuModel.highlightedMenuId !== ""
        }
    }

    delegate: FlatButton {
        id: radioButtonDelegate

        property var item: model ? model.itemRole : null
        property string menuId: Boolean(item) ? item.id : ""
        property string title: Boolean(item) ? item.title : ""

        property bool isMenuOpened: menuLoader.isMenuOpened && menuLoader.parent === this

        property bool highlight: appMenuModel.highlightedMenuId === menuId
        onHighlightChanged: {
            if (highlight) {
                forceActiveFocus()
                accessibleInfo.readInfo()
            } else {
                accessibleInfo.resetFocus()
            }
        }

        property int viewIndex: index

        buttonType: FlatButton.TextOnly
        isNarrow: true
        margins: 8
        drawFocusBorderInsideRect: true

        transparent: !isMenuOpened
        accentButton: isMenuOpened

        AccessibleItem {
            id: accessibleInfo

            visualItem: radioButtonDelegate
            role: MUAccessible.Button
            name: Utils.removeAmpersands(radioButtonDelegate.title)

            function readInfo() {
                accessibleInfo.ignored = false
                accessibleInfo.focused = true
            }

            function resetFocus() {
                accessibleInfo.ignored = true
                accessibleInfo.focused = false
            }
        }

        contentItem: StyledTextLabel {
            id: textLabel

            width: textMetrics.width

            text: correctText(radioButtonDelegate.title)
            textFormat: Text.RichText
            font: ui.theme.defaultFont

            TextMetrics {
                id: textMetrics

                font: textLabel.font
                text: textLabel.removeAmpersands(radioButtonDelegate.title)
            }

            function correctText(text) {
                if (!appMenuModel.isNavigationStarted) {
                    return removeAmpersands(text)
                }

                return makeMnemonicText(text)
            }

            function removeAmpersands(text) {
                return Utils.removeAmpersands(text)
            }

            function makeMnemonicText(text) {
                return Utils.makeMnemonicText(text)
            }
        }

        backgroundItem: AppButtonBackground {
            mouseArea: radioButtonDelegate.mouseArea

            highlight: radioButtonDelegate.highlight

            color: radioButtonDelegate.normalColor
        }

        mouseArea.onHoveredChanged: {
            if (!mouseArea.containsMouse) {
                return
            }

            if (menuLoader.isMenuOpened && menuLoader.parent !== this) {
                appMenuModel.openMenu(radioButtonDelegate.menuId, true)
            }
        }

        onClicked: {
            appMenuModel.openMenu(radioButtonDelegate.menuId, false)
        }
    }

    StyledMenuLoader {
        id: menuLoader

        property string menuId: ""

        onHandleMenuItem: {
            Qt.callLater(appMenuModel.handleMenuItem, itemId)
        }

        onOpened: {
            appMenuModel.openedMenuId = menuLoader.menuId
        }

        onClosed: {
            appMenuModel.openedMenuId = ""
        }
    }
}
