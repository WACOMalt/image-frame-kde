# KDE Store publishing information

Use this file to keep the KDE Store listing consistent between releases.

## Product

- **Store page**: store.kde.org (log in with the OpenDesktop account)
- **Product name**: Image Frame
- **Plugin Id**: `bsums.xyz.image-frame`
- **Category**: Plasma → Plasma 6 Applets
- **License**: GPL-2.0-or-later
- **Homepage / Source**: https://github.com/WACOMalt/image-frame-kde

## Description

Copy this text into the store description field:

> Image Frame shows a picture, or a slideshow of pictures, on the desktop.
> Transparent pictures show the desktop through them.
>
> Image Frame is a fork of the Media Frame widget. Media Frame always draws
> the widget background behind its picture, so a transparent PNG shows on a
> grey panel. In Image Frame the background is a setting: none, standard or
> translucent. The default is none.
>
> The button that opens the picture in a viewer on hover is off by default.
> You can also hide the previous and next buttons. With one picture there is
> no slideshow: the picture does not fade out and in again.
>
> Add files or folders in the settings, or drop them on the widget. Folders
> are read recursively. The other settings are the same as in Media Frame:
> the time between pictures, the fill mode, the random order, pause on hover,
> and click to open.
>
> Requirements: Plasma 6, and the find, sort and stat commands, which every
> Linux system has.
>
> Source: https://github.com/WACOMalt/image-frame-kde

## Logo

- `logo/logo.svg`: the source file
- `logo/logo.png`: the 512x512 render for the store logo field

Render a new PNG after a change to the SVG:

```
rsvg-convert -w 512 -h 512 logo/logo.svg -o logo/logo.png
```

The logo is an original drawing: a picture frame around a picture on a
transparency checkerboard. It uses the bs-updater orange (`#f67400`). It
carries no third-party licence.

## Screenshots

- `screenshots/screenshot-desktop.png`: a transparent pumpkin PNG in the widget
  on the desktop, with the wallpaper showing around it — **done**

The screenshot is cropped to the widget and the wallpaper. Leave out the
panel, the tray and any window. This hides the applications of the person who
makes the screenshot, so no blur is necessary.

### How the desktop screenshot was made

1. Put the widget on the desktop with a transparent PNG and the background
   set to "None (transparent)". Move every window off that part of the
   screen.
2. Capture the desktop:

   ```
   spectacle -b -n -f -o full.png
   ```

3. Crop a 640x400 area around the widget and scale it 2 times, which gives
   1280x800:

   ```
   magick full.png -crop 640x400+1280+740 +repage -filter Lanczos -resize 200% \
     screenshots/screenshot-desktop.png
   ```

4. Delete `full.png`. It shows the whole desktop.

The crop offsets are for the left 1920x1200 screen, with the widget at the
bottom right above the panel. Find the offsets again after the widget moves.

## Before the first upload

Do these three things one time.

1. **The licence is set.** `metadata.json` declares `GPL-2.0-or-later`,
   because Media Frame is GPL-2.0-or-later. `LICENSE` holds the full GPL-2.0
   text. The QML files keep the Media Frame copyright lines and add their own.
   The metadata lists Lars Pontoppidan, the Media Frame author, as an author.

2. **Do not change the plugin Id.** The Id is `bsums.xyz.image-frame`. It
   follows the same reverse-domain form as `bsums.xyz.bs-updater`. The store
   and Discover use the Id to match an update to an installed widget, so the
   Id cannot change after the first upload without making a new product.

3. **Do not use the name "Media Frame".** That is the KDE widget. The store
   listing and the widget name are "Image Frame", so users can tell the two
   apart in the widget browser.

## How to publish an update

1. Increase `Version` in `plasmoid/bsums.xyz.image-frame/metadata.json`.
2. Build the package:

   ```
   ./make-plasmoid.sh
   ```

3. Open the product page on store.kde.org and go to the Files section.
4. Upload `dist/image-frame-<version>.plasmoid`.
5. Update the description text if the behavior changed. Keep this file and the
   store text identical.
6. Commit and push the version change.

Users receive the update through Discover and the Plasma widget browser.

## How to test the package before upload

Install the built archive into a temporary location. This checks the archive
layout without touching the installed widget:

```
kpackagetool6 --type Plasma/Applet --install dist/image-frame-<version>.plasmoid \
  --packageroot /tmp/plasmoid-test
```

The store expects `metadata.json` at the root of the archive. `make-plasmoid.sh`
builds it that way.
