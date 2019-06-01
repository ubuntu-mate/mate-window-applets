namespace WindowTitleApplet{

	Gtk.Label title;
	Wnck.Window *window;
	Wnck.Window *active_window;

	GLib.Settings gsettings;

	public void reload(){
		
		// Disconnect signals from old window
		if(window != null){
			window->name_changed.disconnect(update);
			window->state_changed.disconnect(reload);
		}

		if(active_window != null)
			active_window->state_changed.disconnect(reload);


		window = get_current_window();

		update();


		// Watch for changes to new controlled window
		if(window != null){
			window->name_changed.connect(update);
			window->state_changed.connect(reload);
		}

		// When active window is not the controlled window (because it is unmaximized),
		// we need to watch its state as well
		active_window = Wnck.Screen.get_default().get_active_window();
		if(active_window != null && active_window != window)
			active_window->state_changed.connect(reload);
	}

	public void update(){
		if(window != null){
			string title_text = GLib.Markup.escape_text(window->get_name());
			if(window->is_active())
				title.set_markup(title_text);
			else
				title.set_markup("<span color='#808080'>"+title_text+"</span>");
		} else {
			title.set_label("");
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
				if(win != null && !win->is_maximized())
					win = null;
			break;
			case "topmost-maximized":
				List<Wnck.Window*> windows = Wnck.Screen.get_default().get_windows_stacked().copy();
				windows.reverse();
				foreach(Wnck.Window* w in windows) {
					if(w->is_maximized() && !w->is_minimized()){
						win = w;
						break;
					}
				}
			break;
		}

		return win;
	}
		
	private void clicked(Gdk.EventButton *event){
		if(window != null){
			window->activate(Gtk.get_current_event_time());
			if(event->type == Gdk.EventType.2BUTTON_PRESS) {
				if(window->is_maximized())
					window->unmaximize();
				else
					window->maximize();
			}
		}
	}

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowTitleApplet")return false;

		gsettings = new GLib.Settings("org.mate.window-applets.window-title");

		title = new Gtk.Label("");
		title.ellipsize = Pango.EllipsizeMode.END;

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

		applet.set_flags(MatePanel.AppletFlags.EXPAND_MINOR | MatePanel.AppletFlags.EXPAND_MAJOR);

		applet.add(title);
		applet.setup_menu(menu,action_group);

		settings.delete_event.connect( (event) => { settings.hide() ; return true ; } );
		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		settings_action.activate.connect( () => { settings.present() ; } );
		about_action.activate.connect( () => { about.present() ; } );

		applet.button_press_event.connect( (widget,event) => { clicked(event); return false; } );

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
