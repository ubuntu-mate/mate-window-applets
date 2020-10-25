using WindowWidgets;

namespace WindowMenuApplet{

	class WindowMenu {
		public WindowWidgets.WindowMenuButton button;
		public Gdk.Monitor monitor;
		private Wnck.Window *window;
		private Wnck.Window *active_window;
		private Gdk.Monitor active_window_monitor;

		public GLib.Settings gsettings = new GLib.Settings("org.mate.window-applets.window-menu");

		public WindowMenu(){
			button = new WindowMenuButton();
		}

		public void reload(){

			// Disconnect signals from old window
			if(window != null){
				window->icon_changed.disconnect(button.icon_set);
				window->actions_changed.disconnect(button.menu_set);
				window->state_changed.disconnect(reload);
			}

			if(active_window != null){
				active_window->state_changed.disconnect(reload);
				active_window->geometry_changed.disconnect(detect_monitor_change);
			}


			window = get_current_window();

			button.window = window;

			button.icon_set();
			button.menu_set();

			// Watch for changes to new controlled window
			if(window != null){
				window->icon_changed.connect(button.icon_set);
				window->actions_changed.connect(button.menu_set);
				window->state_changed.connect(reload);
			}

			active_window = Wnck.Screen.get_default().get_active_window();
			if(active_window != null){
				// When active window is not the controlled window (because it is unmaximized),
				// we need to watch its state as well
				if(active_window != window)
					active_window->state_changed.connect(reload);

				active_window->geometry_changed.connect(detect_monitor_change);
			}
		}

		public void change_orient(MatePanel.Applet applet){
			MatePanel.AppletOrient orient = applet.get_orient();
			switch(orient){
				case MatePanel.AppletOrient.UP:
					button.set_direction(Gtk.ArrowType.DOWN);
					break;
				case MatePanel.AppletOrient.DOWN:
					button.set_direction(Gtk.ArrowType.UP);
					break;
				case MatePanel.AppletOrient.LEFT:
					button.set_direction(Gtk.ArrowType.RIGHT);
					break;
				case MatePanel.AppletOrient.RIGHT:
					button.set_direction(Gtk.ArrowType.LEFT);
					break;
				default:
					break;
			}

		}

		public void change_behaviour(){
			string behaviour = gsettings.get_string("behaviour");

			Wnck.Screen.get_default().window_closed.disconnect( reload );

			if(behaviour == "topmost-maximized")
				Wnck.Screen.get_default().window_closed.connect( reload );
		}

		private Wnck.Window? get_current_window(){
			Wnck.WindowType window_type;
			string behaviour = gsettings.get_string("behaviour");
			Wnck.Workspace active_workspace = Wnck.Screen.get_default().get_active_workspace();

			List<weak Wnck.Window> windows = Wnck.Screen.get_default().get_windows_stacked().copy();
			windows.reverse();

			foreach(Wnck.Window* win in windows) {
				window_type = win->get_window_type();
				if(window_type == Wnck.WindowType.DESKTOP || window_type == Wnck.WindowType.DOCK)
					continue;

				if(win->is_minimized())
					continue;

				if(!win->is_on_workspace(active_workspace))
					continue;

				if(monitor != get_monitor_at_window(win))
					continue;

				switch(behaviour){
					case "active-always":
						return win;

					case "active-maximized":
						if(win->is_maximized())
							return win;
						else
							return null;

					case "topmost-maximized":
						if(win->is_maximized())
							return win;
					break;
				}
			}

			return null;
		}

		private Gdk.Monitor? get_monitor_at_window(Wnck.Window *win){
			int x, y, w, h;

			win->get_client_window_geometry(out x, out y, out w, out h);

			return Gdk.Display.get_default().get_monitor_at_point(x + w/2, y + h/2);
		}

		private void detect_monitor_change(){
			Gdk.Monitor mon = get_monitor_at_window(active_window);
			if(mon != active_window_monitor){
				active_window_monitor = mon;
				reload();
			}
		}
	}

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowMenuApplet")return false;

		var windowMenu = new WindowMenu();

		Gtk.Builder builder = new Gtk.Builder();

		#if LOCAL_PATH
			var dialog_path = "/usr/local/lib/mate-applets/mate-window-applets/window-menu/dialog.ui";
		#else
			var dialog_path = "/usr/lib/mate-applets/mate-window-applets/window-menu/dialog.ui";
		#endif

		try{
			builder.add_from_file(dialog_path);
		} catch (GLib.Error e){
			stdout.printf("Error: %s\n", e.message);
		}

		Gtk.Window settings = builder.get_object("Settings") as Gtk.Window;
		Gtk.Window about = builder.get_object("About") as Gtk.Window;

		Gtk.ActionGroup action_group = new Gtk.ActionGroup("action_group");

		Gtk.Action settings_action = new Gtk.Action("settings","Settings",null,Gtk.Stock.PREFERENCES);
		Gtk.Action about_action = new Gtk.Action("about","About",null,Gtk.Stock.ABOUT);

		action_group.add_action(settings_action);
		action_group.add_action(about_action);

		string menu = """<menuitem name="Settings" action="settings" />""";
		menu += """<menuitem name="About" action="about" />""";

		windowMenu.gsettings.bind("behaviour",builder.get_object("behaviour"),"active_id",SettingsBindFlags.DEFAULT);
		windowMenu.gsettings.changed["behaviour"].connect( () => { windowMenu.change_behaviour(); windowMenu.reload(); } );

		applet.add(windowMenu.button);
		applet.setup_menu(menu,action_group);

		settings.delete_event.connect( (event) => { settings.hide() ; return true ; } );
		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		settings_action.activate.connect( () => { settings.present() ; } );
		about_action.activate.connect( () => { about.present() ; } );

		applet.change_orient.connect( () => { windowMenu.change_orient(applet); windowMenu.reload(); } );

		applet.show_all();

		Wnck.Screen.get_default().active_window_changed.connect( windowMenu.reload );

		windowMenu.monitor = applet.get_parent_window().get_screen().get_display().get_monitor_at_window(applet.get_parent_window());

		windowMenu.change_orient(applet);
		windowMenu.change_behaviour();
		windowMenu.reload();

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowMenuAppletFactory", true, typeof (MatePanel.Applet), WindowMenuApplet.factory);

	return 0;
}
