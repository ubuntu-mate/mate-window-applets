# mate-window-applets

Applets for `mate-panel` to show various window controls. The original author delete their GitHub repository, so this in an import from the source uploaded to Debian.

  * WindowButtons applet shows the close,minimize,actions in a panel.
  * WindowLabel applet shows the class,title,role,xid,pid of the active window.
  * WindowMenu applet shows you the window menu of the active window.

## Install

On [Ubuntu MATE](https://ubuntu-mate.org) 18.04 or newer:

```
sudo apt install mate-window-buttons-applet mate-window-menu-applet mate-window-title-applet
```

## Compile

### Requirements

  * meson
  * ninja
  * vala
  * Gtk3
  * Gdk3
  * libwnck3

### Build

```
meson --prefix=/usr build
cd build
ninja
sudo ninja install
sudo ./install-icons.sh install
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
```

#### Remove

```
sudo ninja uninstall
sudo ./install-icons.sh uninstall
```

### License

  * GPLv3

See the [LICENSE](LICENSE) file.
