using WindowWidgets;

namespace WindowMenuApplet{

	WindowWidgets.WindowMenuButton button;
	Wnck.Window *window;

	GLib.Settings gsettings;

	public void reload(){
		if(window != null){
			window->icon_changed.disconnect(button.icon_set);
			window->actions_changed.disconnect(button.menu_set);
		}

		window = get_current_window();

		button.window = window;

		button.icon_set();
		button.menu_set();

		if(window != null){
			window->icon_changed.connect(button.icon_set);
			window->actions_changed.connect(button.menu_set);
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

		reload();

	}
		
	private Wnck.Window get_current_window(){
		Wnck.Window* win = null;
		string behaviour = gsettings.get_string("behaviour");

		Wnck.Screen.get_default().force_update();

		switch(behaviour){
			case "active-always":
				win = Wnck.Screen.get_default().get_active_window();
			break;
			case "active-maximized":
				win = Wnck.Screen.get_default().get_active_window();
				if(!win->is_maximized())
					win = null;
			break;
			case "topmost-maximized":
				List<Wnck.Window*> windows = Wnck.Screen.get_default().get_windows_stacked().copy();
				windows.reverse();
				foreach(Wnck.Window* w in windows) {
					if(w->is_maximized()){
						win = w;
						break;
					}
				}
			break;
		}

		return win;
	}

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowMenuApplet")return false;

		gsettings = new GLib.Settings("org.mate.window-applets.window-menu");

		button = new WindowMenuButton();

		change_orient(applet);

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

		gsettings.bind("behaviour",builder.get_object("behaviour"),"active_id",SettingsBindFlags.DEFAULT);
		gsettings.changed["behaviour"].connect( (key) => { reload(); } );
		
		applet.add(button);
		applet.setup_menu(menu,action_group);

		settings.delete_event.connect( (event) => { settings.hide() ; return true ; } );
		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		settings_action.activate.connect( () => { settings.present() ; } );
		about_action.activate.connect( () => { about.present() ; } );

		applet.change_orient.connect( () => { change_orient(applet) ; } );

		applet.show_all();

		Wnck.Screen.get_default().active_window_changed.connect( reload );

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowMenuAppletFactory", true, typeof (MatePanel.Applet), WindowMenuApplet.factory);

	return 0;
}
