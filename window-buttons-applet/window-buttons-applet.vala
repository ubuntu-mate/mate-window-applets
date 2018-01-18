using WindowWidgets;

namespace WindowButtonsApplet{

	public class ButtonsApplet : Gtk.Box{

		// Struct to contain witch buttons are enabled.

		public struct EnabledButtons {
			bool close ;
			bool minimize ;
			bool maximize ;
		}

		private Wnck.Window* prev_window = null;
		private Wnck.Window* window = null;

		public GLib.Settings gsettings = new GLib.Settings("org.mate.window-applets.window-buttons");
		public GLib.Settings marco_gsettings = new GLib.Settings("org.mate.Marco.general");

		protected WindowButton CLOSE = new WindowButton(WindowButtonType.CLOSE);
		protected WindowButton MINIMIZE = new WindowButton(WindowButtonType.MINIMIZE);
		protected WindowButton MAXIMIZE = new WindowButton(WindowButtonType.MAXIMIZE);

		protected EnabledButtons enabled_buttons = EnabledButtons();

		// Constructor

		public ButtonsApplet(Gtk.Orientation orient){
			Object(orientation: orient);

			enabled_buttons.close = false;
			enabled_buttons.minimize = false;
			enabled_buttons.maximize = false;

			this.add(CLOSE);
			this.add(MINIMIZE);
			this.add(MAXIMIZE);

			this.set_homogeneous(true);

			this.change_layout();
			this.change_theme();
			this.change_spacing();

			this.gsettings.changed["theme"].connect(this.change_theme);
			this.gsettings.changed["spacing"].connect(this.change_spacing);
			this.marco_gsettings.changed["button_layout"].connect(this.change_layout);

			Wnck.Screen.get_default().active_window_changed.connect(this.reload);

		}

		// Helpers

		private void reload_actions(Wnck.Window *window){
				Wnck.WindowActions actions = window->get_actions();
				if(enabled_buttons.close == true){
					if((Wnck.WindowActions.CLOSE & actions)>0){
						CLOSE.set_visible(true);
						CLOSE.window = window;
						CLOSE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
					} else CLOSE.set_visible(false);
				}

				if(enabled_buttons.minimize == true){
					if((Wnck.WindowActions.MINIMIZE & actions)>0){
						MINIMIZE.set_visible(true);
						MINIMIZE.window = window;
						MINIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
					} else MINIMIZE.set_visible(false);
				}

				if(enabled_buttons.maximize == true){
					if((Wnck.WindowActions.MAXIMIZE & actions)>0){
						MAXIMIZE.set_visible(true);
						MAXIMIZE.window = window;
						MAXIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
					} else MAXIMIZE.set_visible(false);
				}
		}

		public void reload(){
			bool control_maximized_window = gsettings.get_boolean("control-maximized-window");

			prev_window = window;

			prev_window->actions_changed.disconnect(reload);
			prev_window->state_changed.disconnect(reload);
			Wnck.Screen.get_default().force_update();
			window = Wnck.Screen.get_default().get_active_window();

			if(window != null){
				window->actions_changed.connect(reload);
				window->state_changed.connect(reload);

				if(control_maximized_window){
					if(window->is_maximized())reload_actions(window);
					else{
						CLOSE.set_visible(false);
						MINIMIZE.set_visible(false);
						MAXIMIZE.set_visible(false);
					}
				}
				else{
					reload_actions(window);
				}
			}
			else {
				CLOSE.set_visible(false);
				MINIMIZE.set_visible(false);
				MAXIMIZE.set_visible(false);
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
		}

		public void change_theme(){
			string theme = gsettings.get_string("theme");

			if(enabled_buttons.close){
				CLOSE.theme_set(theme);
				CLOSE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}

			if(enabled_buttons.minimize){
				MINIMIZE.theme_set(theme);
				MINIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}

			if(enabled_buttons.maximize){
				MAXIMIZE.theme_set(theme);
				MAXIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}
		}

		public void change_size(int size){
			int padding = gsettings.get_int("padding");
			size -= padding;

			if(this.enabled_buttons.close == true){
				CLOSE.icon_size = size;
				CLOSE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}
			if(this.enabled_buttons.minimize == true){
				MINIMIZE.icon_size = size;
				MINIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}
			if(this.enabled_buttons.close == true){
				MAXIMIZE.icon_size = size;
				MAXIMIZE.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));
			}
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

		var widget_container = new ButtonsApplet(Gtk.Orientation.HORIZONTAL);

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
		widget_container.gsettings.bind("theme",builder.get_object("theme"),"text",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("spacing",builder.get_object("spacing"),"value",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("padding",builder.get_object("padding"),"value",SettingsBindFlags.DEFAULT);
		widget_container.gsettings.bind("control-maximized-window",builder.get_object("control-maximized-window"),"state",SettingsBindFlags.DEFAULT);

		widget_container.gsettings.changed["use-marco-layout"].connect(widget_container.change_layout);
		widget_container.gsettings.changed["buttons-layout"].connect(widget_container.change_layout);
		widget_container.gsettings.changed["theme"].connect(widget_container.change_theme);
		widget_container.gsettings.changed["spacing"].connect( (key) => { widget_container.change_size(applet.get_size()); } );
		widget_container.gsettings.changed["padding"].connect( (key) => { widget_container.change_size(applet.get_size()); } );
		widget_container.gsettings.changed["control-maximized-window"].connect( (key) => { widget_container.reload(); } );
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
