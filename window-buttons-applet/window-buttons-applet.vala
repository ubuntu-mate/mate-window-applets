using WindowWidgets;

namespace WindowButtonsApplet{

	public class ButtonsApplet : Gtk.Box{

		// Struct to contain witch buttons are enabled.

		public struct EnabledButtons {
			bool close ;
			bool minimize ;
			bool maximize ;
		}

		public Gdk.Monitor monitor;
		private Wnck.Window* window = null;
		private Wnck.Window *active_window = null;
		private Gdk.Monitor active_window_monitor;

		public GLib.Settings gsettings = new GLib.Settings("org.mate.window-applets.window-buttons");
		public GLib.Settings marco_gsettings = new GLib.Settings("org.mate.Marco.general");

		protected WindowButton CLOSE = new WindowButton(WindowButtonType.CLOSE);
		protected WindowButton MINIMIZE = new WindowButton(WindowButtonType.MINIMIZE);
		protected WindowButton MAXIMIZE = new WindowButton(WindowButtonType.MAXIMIZE);

		protected EnabledButtons enabled_buttons = EnabledButtons();

		private Gtk.StyleContext* applet_style_context;

		// Constructor

		public ButtonsApplet(Gtk.Orientation orient, Gtk.StyleContext* applet_style_context){
			Object(orientation: orient);

			this.set_homogeneous(true);

			this.applet_style_context = applet_style_context;

			this.change_layout();
			this.change_theme();
			this.change_spacing();
			this.change_behaviour();

			this.marco_gsettings.changed["theme"].connect(this.change_theme);
			this.gsettings.changed["spacing"].connect(this.change_spacing);
			this.marco_gsettings.changed["button_layout"].connect(this.change_layout);

			Wnck.Screen.get_default().active_window_changed.connect(this.reload);

		}

		// Helpers

		private void reload_actions(){
			if( window == null ){
				CLOSE.set_visible(false);
				MINIMIZE.set_visible(false);
				MAXIMIZE.set_visible(false);
			} else {
				Wnck.WindowActions actions = window->get_actions();
				if(enabled_buttons.close == true){
					if((Wnck.WindowActions.CLOSE & actions)>0){
						CLOSE.set_visible(true);
						CLOSE.window = window;
						CLOSE.update();
					} else CLOSE.set_visible(false);
				}

				if(enabled_buttons.minimize == true){
					if((Wnck.WindowActions.MINIMIZE & actions)>0){
						MINIMIZE.set_visible(true);
						MINIMIZE.window = window;
						MINIMIZE.update();
					} else MINIMIZE.set_visible(false);
				}

				if(enabled_buttons.maximize == true){
					if((Wnck.WindowActions.MAXIMIZE & actions)>0){
						MAXIMIZE.set_visible(true);
						MAXIMIZE.window = window;
						MAXIMIZE.update();
					} else MAXIMIZE.set_visible(false);
				}
			}
		}

		public void reload(){

			// Disconnect signals from old window
			if(window != null){
				window->actions_changed.disconnect(reload);
				window->state_changed.disconnect(reload);
			}

			if(active_window != null){
				active_window->state_changed.disconnect(reload);
				active_window->geometry_changed.disconnect(detect_monitor_change);
			}

			window = get_current_window();

			reload_actions();

			// Watch for changes to new controlled window
			if(window != null){
				window->actions_changed.connect(reload);
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

		public void change_layout(){
			bool use_marco_layout = gsettings.get_boolean("use-marco-layout");

			string[] button_layout =  new string[10];
			if(use_marco_layout){
				string marco_layout =  marco_gsettings.get_string("button-layout");
				marco_layout = marco_layout.replace(":","");
				marco_layout = marco_layout.replace("menu","");
				button_layout = marco_layout.split(",");
			}
			else{
				button_layout = gsettings.get_string("buttons-layout").split(",");
			}

			enabled_buttons.close = false;
			enabled_buttons.minimize = false;
			enabled_buttons.maximize = false;

			this.remove(CLOSE);
			this.remove(MINIMIZE);
			this.remove(MAXIMIZE);

			foreach(string button in button_layout){
				if(button == "close"){
					this.add(CLOSE);
					enabled_buttons.close = true;
				}
				else if(button == "minimize"){
					this.add(MINIMIZE);
					enabled_buttons.minimize = true;
				}
				else if(button == "maximize"){
					this.add(MAXIMIZE);
					enabled_buttons.maximize = true;
				}
			}

			reload_actions();
		}

		public void change_theme(){
			string theme_name = marco_gsettings.get_string("theme");

			Gdk.RGBA fg_color = applet_style_context->get_color(Gtk.StateFlags.ACTIVE);

			WindowButtonsTheme theme = new WindowButtonsTheme(theme_name, fg_color);

			CLOSE.theme = theme;
			if(enabled_buttons.close)
				CLOSE.update(true);

			MINIMIZE.theme = theme;
			if(enabled_buttons.minimize)
				MINIMIZE.update(true);

			MAXIMIZE.theme = theme;
			if(enabled_buttons.maximize)
				MAXIMIZE.update(true);

		}

		public void change_size(int size){
			int padding = gsettings.get_int("padding");
			size -= padding;

			CLOSE.icon_size = size;
			if(this.enabled_buttons.close == true)
				CLOSE.update();

			MINIMIZE.icon_size = size;
			if(this.enabled_buttons.minimize == true)
				MINIMIZE.update();

			MAXIMIZE.icon_size = size;
			if(this.enabled_buttons.maximize == true)
				MAXIMIZE.update();

		}

		public void change_orient(int orient){
			if(orient == MatePanel.AppletOrient.UP || orient == MatePanel.AppletOrient.DOWN){
				this.orientation = Gtk.Orientation.HORIZONTAL;
			}
			else{
				this.orientation = Gtk.Orientation.VERTICAL;
			}
		}


		public void change_spacing(){
			int spacing = gsettings.get_int("spacing");

			this.set_spacing(spacing);
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

				if(!win->is_in_viewport(active_workspace))
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
		if(iid != "WindowButtonsApplet")return false;

		Gtk.Builder builder = new Gtk.Builder();

		#if LOCAL_PATH
			var dialog_path = "/usr/local/lib/mate-applets/mate-window-applets/window-buttons/dialog.ui";
		#else
			var dialog_path = "/usr/lib/mate-applets/mate-window-applets/window-buttons/dialog.ui";
		#endif

		try{
			builder.add_from_file(dialog_path);
		} catch (GLib.Error e){
			stdout.printf("Error: %s\n", e.message);
		}

		Gtk.Window settings = builder.get_object("Settings") as Gtk.Window;
		Gtk.Window about = builder.get_object("About") as Gtk.Window;

		var widget_container = new ButtonsApplet(Gtk.Orientation.HORIZONTAL, applet.get_style_context());

		widget_container.monitor = applet.get_parent_window().get_screen().get_display().get_monitor_at_window(applet.get_parent_window());

		widget_container.show();
		widget_container.change_orient(applet.get_orient());
		widget_container.change_size(applet.get_size());

		Gtk.ActionGroup action_group = new Gtk.ActionGroup("action_group");

		Gtk.Action settings_action = new Gtk.Action("settings","Settings",null,Gtk.Stock.PREFERENCES);
		Gtk.Action about_action = new Gtk.Action("about","About",null,Gtk.Stock.ABOUT);

		action_group.add_action(settings_action);
		action_group.add_action(about_action);

		string menu = """<menuitem name="Settings" action="settings" />""";
		menu += """<menuitem name="About" action="about" />""";

		widget_container.gsettings.bind("use-marco-layout",builder.get_object("use-marco-layout"),"state",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("buttons-layout",builder.get_object("layout"),"text",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("spacing",builder.get_object("spacing"),"value",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("padding",builder.get_object("padding"),"value",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("behaviour",builder.get_object("behaviour"),"active_id",SettingsBindFlags.DEFAULT);

		widget_container.gsettings.changed["use-marco-layout"].connect(widget_container.change_layout);
		widget_container.gsettings.changed["buttons-layout"].connect(widget_container.change_layout);
		widget_container.gsettings.changed["spacing"].connect( (key) => { widget_container.change_size(applet.get_size()); } );
		widget_container.gsettings.changed["padding"].connect( (key) => { widget_container.change_size(applet.get_size()); } );
		widget_container.gsettings.changed["behaviour"].connect( () => { widget_container.change_behaviour(); widget_container.reload(); } );
		applet.setup_menu(menu,action_group);

		settings.delete_event.connect( (event) => { settings.hide() ; return true ; } );
		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		settings_action.activate.connect( () => { settings.present() ; } );
		about_action.activate.connect( () => { about.present() ; } );

		applet.change_size.connect(widget_container.change_size);
		applet.change_orient.connect(widget_container.change_orient);

		applet.set_flags(MatePanel.AppletFlags.EXPAND_MINOR);
		applet.add(widget_container);
		applet.show();

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowButtonsAppletFactory", true, typeof (MatePanel.Applet), WindowButtonsApplet.factory);

	return 0;
}
