/*
 *  SPDX-FileCopyrightText: 2015 Lars Pontoppidan <dev.larpon@gmail.com>
 *  SPDX-FileCopyrightText: 2026 BSumsXYZ <ben@bsums.xyz>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

// A QML port of the MediaFrame C++ class from the Media Frame widget
// (kdeplasma-addons, applets/mediaframe/mediaframe.cpp). Media Frame compiles
// that class into a binary plugin. This port keeps the same API so that
// main.qml can stay close to the original, and the widget installs as a
// plain QML package.
//
// Differences from the C++ class:
// - Folders are read with `find` through the executable engine, so add()
//   is asynchronous. `count` goes up when the results arrive.
// - The current file is checked for changes with `stat` on a timer, not
//   with QFileSystemWatcher.
// - Remote URLs go straight to the Image item, which downloads them. They
//   are not cached in /tmp first.

import QtQuick
import org.kde.plasma.plasma5support as P5Support

Item {
    id: frame

    visible: false

    property bool random: false

    readonly property int count: allFiles.length
    readonly property int historyLength: history.length
    readonly property int futureLength: future.length

    // How often the current file is checked for changes, in milliseconds.
    property int watchInterval: 5000

    signal itemChanged(string path)

    // The same extensions that QImageReader reads on a standard Plasma
    // system, lower case. find matches them with -iname.
    readonly property var extensions: [
        "png", "apng", "jpg", "jpeg", "jpe", "jfif", "gif", "webp", "avif",
        "jxl", "heic", "heif", "svg", "svgz", "bmp", "dib", "tif", "tiff",
        "ico", "cur", "tga", "xpm", "xbm", "pbm", "pgm", "ppm", "pnm",
        "jp2", "j2k", "exr", "hdr", "pcx", "qoi", "ras", "dds", "psd",
        "kra", "ora", "xcf", "jxr", "wbmp"
    ]

    property var pathMap: ({})
    property var allFiles: []
    property var history: []
    property var future: []
    property int current: -1

    // Incremented by clear(). A folder scan that started before the last
    // clear() is ignored when its results arrive.
    property int generation: 0
    property var pendingScans: ({})

    property string watchFile: ""
    property string watchStamp: ""

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function isLocalUrl(path) {
        return String(path).startsWith("file://") || String(path).startsWith("/");
    }

    function toLocalPath(path) {
        var s = String(path);
        if (s.startsWith("/")) {
            return s;
        }
        try {
            return decodeURIComponent(s.replace(/^file:\/\//, ""));
        } catch (e) {
            return s.replace(/^file:\/\//, "");
        }
    }

    function toFileUrl(localPath) {
        return "file://" + localPath.split("/").map(encodeURIComponent).join("/");
    }

    // A best guess for drops, where there is no time to ask the file
    // system. The value only labels the entry in the settings; add()
    // reads folders and files the same way.
    function isDir(path) {
        var name = String(path).split("/").pop().toLowerCase();
        var dot = name.lastIndexOf(".");
        return dot < 0 || extensions.indexOf(name.slice(dot + 1)) < 0;
    }

    function isAdded(path) {
        return pathMap.hasOwnProperty(path);
    }

    function appendFiles(path, files) {
        if (files.length === 0) {
            console.warn("Image Frame: no images found in", path);
            return;
        }
        var map = pathMap;
        map[path] = files;
        pathMap = map;
        allFiles = allFiles.concat(files);
    }

    // Folders are read recursively unless `recursive` is false. main.qml
    // always passes true, as Media Frame does.
    function add(path, recursive) {
        if (isAdded(path) || pendingScans.hasOwnProperty(path)) {
            return;
        }

        if (!isLocalUrl(path)) {
            appendFiles(path, [path]);
            return;
        }

        var local = toLocalPath(path);
        var names = extensions.map(function (ext) {
            return "-iname '*." + ext + "'";
        }).join(" -o ");
        var depth = recursive === false ? " -maxdepth 1" : "";
        // A folder gives its images, sorted. A file is taken as it is,
        // whatever its extension, as Media Frame does. The comment at the
        // end makes the command unique, because the engine does not run a
        // command again while the same command is still connected.
        var cmd = "p=" + shellQuote(local) + "; "
            + "if [ -d \"$p\" ]; then find -L \"$p\"" + depth
            + " -type f \\( " + names + " \\) | LC_ALL=C sort; "
            + "elif [ -f \"$p\" ]; then printf '%s\\n' \"$p\"; fi"
            + " # image-frame " + generation + " " + Date.now();

        var pending = pendingScans;
        pending[path] = { "cmd": cmd, "generation": generation };
        pendingScans = pending;
        executable.connectSource(cmd);
    }

    function clear() {
        generation++;
        pendingScans = {};
        pathMap = {};
        allFiles = [];
        current = -1;
    }

    function watch(path) {
        watchStamp = "";
        watchFile = (path && isLocalUrl(path)) ? toLocalPath(path) : "";
        if (watchFile !== "") {
            checkWatchFile();
        }
    }

    function watchCommand(file) {
        return "stat -L -c '%Y %s' -- " + shellQuote(file) + " # image-frame-watch";
    }

    function checkWatchFile() {
        executable.connectSource(watchCommand(watchFile));
    }

    function randomIndex(min, max) {
        return min + Math.floor(Math.random() * (max - min));
    }

    function get(successCallback, errorCallback) {
        var size = allFiles.length;

        if (size === 0) {
            if (typeof errorCallback === "function") {
                errorCallback("No files available");
            }
            return;
        }

        if (size === 1) {
            current = 0;
        } else if (random) {
            if (current === -1) {
                current = randomIndex(0, size);
            } else {
                // Do not show the same image twice in a row.
                var next = randomIndex(0, size - 1);
                current = next >= current ? next + 1 : next;
            }
        } else {
            if (current === -1 || ++current >= size) {
                current = 0;
            }
        }

        if (typeof successCallback === "function") {
            successCallback(allFiles[current]);
        }
    }

    function pushHistory(s) {
        var h = [s].concat(history);
        // Keep a sane history size.
        if (h.length > 50) {
            h.pop();
        }
        history = h;
    }

    function popHistory() {
        if (history.length === 0) {
            return "";
        }
        var h = history.slice();
        var item = h.shift();
        history = h;
        return item;
    }

    function pushFuture(s) {
        future = [s].concat(future);
    }

    function popFuture() {
        if (future.length === 0) {
            return "";
        }
        var f = future.slice();
        var item = f.shift();
        future = f;
        return item;
    }

    Timer {
        interval: frame.watchInterval
        repeat: true
        running: frame.watchFile !== ""
        onTriggered: frame.checkWatchFile()
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);

            if (sourceName.endsWith(" # image-frame-watch")) {
                var stamp = String(data.stdout).trim();
                // Ignore a result for a file that is no longer shown.
                if (frame.watchFile === "" || sourceName !== frame.watchCommand(frame.watchFile)
                        || stamp === "") {
                    return;
                }
                if (frame.watchStamp !== "" && stamp !== frame.watchStamp) {
                    frame.itemChanged(frame.toFileUrl(frame.watchFile));
                }
                frame.watchStamp = stamp;
                return;
            }

            for (var path in frame.pendingScans) {
                var scan = frame.pendingScans[path];
                if (scan.cmd !== sourceName) {
                    continue;
                }
                var pending = frame.pendingScans;
                delete pending[path];
                frame.pendingScans = pending;
                if (scan.generation !== frame.generation) {
                    return;
                }
                var files = String(data.stdout).split("\n").filter(function (line) {
                    return line.length > 0;
                }).map(frame.toFileUrl);
                frame.appendFiles(path, files);
                return;
            }
        }
    }
}
