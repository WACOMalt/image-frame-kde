# Image Frame

Image Frame is a KDE Plasma 6 desktop widget that shows an image, or a
slideshow of images from files and folders.

It is a fork of the Media Frame widget from kdeplasma-addons 6.7.5. Media
Frame always draws the Plasma widget background behind its image, so a
transparent PNG shows on a grey panel. Image Frame can leave out the
background, so transparent areas of the image show the desktop.

![A transparent pumpkin PNG in Image Frame on the desktop](screenshots/screenshot-desktop.png)

## Changes from Media Frame

| Setting | Media Frame | Image Frame |
| --- | --- | --- |
| Background | Plasma theme background | None (default), Standard or Translucent |
| "Open in viewer" button on hover | Always on | Off by default |
| Previous and next buttons on hover | Always on | On by default |

Image Frame also has these changes in behavior:

- With one picture there is no slideshow. Media Frame faded the same picture
  out and in again at every interval.
- "Pause slideshow when cursor is over image" is obeyed. Media Frame paused
  even when that setting was off.

## Requirements

- KDE Plasma 6
- `find`, `sort` and `stat` (GNU coreutils and findutils)

Media Frame reads folders in C++, which a widget package cannot contain.
Image Frame reads them with `find`, and checks the shown picture for
changes with `stat` every 5 seconds.

## Installation

```sh
./install.sh
systemctl --user restart plasma-plasmashell.service
```

Then add the widget "Image Frame" to the desktop.

To remove it:

```sh
kpackagetool6 -t Plasma/Applet -r bsums.xyz.image-frame
```

## Configuration

Right-click the widget and select "Configure Image Frame".

- **Media**: the files and folders to show. Folders are read recursively.
  You can also drop files and folders on the widget.
- **Appearance**: the background, and the buttons that show on hover.
- **Behavior**: the time between pictures, the fill mode, the random order,
  pause on hover, and click to open.

## Layout

- `plasmoid/bsums.xyz.image-frame/metadata.json`: applet Id, name, version
- `plasmoid/bsums.xyz.image-frame/contents/ui/main.qml`: the widget, forked
  from Media Frame
- `plasmoid/bsums.xyz.image-frame/contents/ui/MediaFrame.qml`: the QML port of
  the Media Frame C++ class, which reads the folders
- `plasmoid/bsums.xyz.image-frame/contents/ui/config*.qml`: the settings pages
- `install.sh`: installs the widget for the current user
- `make-plasmoid.sh`: builds `dist/image-frame-<version>.plasmoid` for the KDE
  Store
- `PUBLISHING.md`: KDE Store listing text and release steps
- `logo/`, `screenshots/`: KDE Store images

## Publishing

See [PUBLISHING.md](PUBLISHING.md). Build the store package with:

```sh
./make-plasmoid.sh
```

Tested on Plasma 6.7.5, Wayland, Nobara/Fedora 44.

## License

GPL-2.0-or-later, the same as Media Frame. See [LICENSE](LICENSE).
