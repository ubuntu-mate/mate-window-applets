namespace WindowTitleApplet{

	Gtk.Label title;
	Wnck.Window *window;

	GLib.Settings gsettings;

	public void reload(){
		if(window != null){
			window->name_changed.disconnect(update);
		}

		window = get_current_window();

		update();

		if(window != null){
			window->name_changed.connect(update);
		}
	}

	public void update(){
		if(window != null){
			title.set_label(window->get_name());
			stdout.printf("set_label: %s\n", window->get_name());
		} else {
			title.set_label("");
			stdout.printf("set_label: ''\n");
		}
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
		if(iid != "WindowTitleApplet")return false;

		gsettings = new GLib.Settings("org.mate.window-applets.window-title");

		title = new Gtk.Label("");

		reload();

		//title.set_label(Wnck.Screen.get_default().get_active_window().get_name());

		Gtk.Builder builder = new Gtk.Builder();

		#if LOCAL_PATH
			var dialog_path = "/usr/local/lib/mate-applets/mate-window-applets/window-title/dialog.ui";
		#else
			var dialog_path = "/usr/lib/mate-applets/mate-window-applets/window-title/dialog.ui";
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

		applet.set_flags(MatePanel.AppletFlags.EXPAND_MAJOR);

		applet.add(title);
		applet.setup_menu(menu,action_group);

		settings.delete_event.connect( (event) => { settings.hide() ; return true ; } );
		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		settings_action.activate.connect( () => { settings.present() ; } );
		about_action.activate.connect( () => { about.present() ; } );

		//applet.change_size.connect();

		//--//applet.add(widget_container);
		applet.show_all();

		Wnck.Screen.get_default().active_window_changed.connect( reload );

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowTitleAppletFactory", true, typeof (MatePanel.Applet), WindowTitleApplet.factory);

	return 0;
}
