import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("@title", "Media")
        icon: "folder-image"
        source: "configMedia.qml"
    }
    ConfigCategory {
        name: i18nc("@title", "Appearance")
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18nc("@title", "Behavior")
        icon: "image"
        source: "configBehavior.qml"
    }
}
