namespace WindowTitleApplet{

	Gtk.Label title;
	Wnck.Window *active_window;

	public void reload(){
		if(active_window != null){
			active_window->name_changed.disconnect(update);
		}

		Wnck.Screen.get_default().force_update();
		active_window = Wnck.Screen.get_default().get_active_window();

		if(active_window != null){
			update();

			active_window->name_changed.connect(update);
		}
	}

	public void update(){
		title.set_label(active_window->get_name());
		stdout.printf("set_label: %s\n", active_window->get_name());
	}
		

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowTitleApplet")return false;

		title = new Gtk.Label("");

		reload();

		title.set_label(Wnck.Screen.get_default().get_active_window().get_name());

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

		Gtk.Window about = builder.get_object("About") as Gtk.Window;

		Gtk.ActionGroup action_group = new Gtk.ActionGroup("action_group");

		Gtk.Action about_action = new Gtk.Action("about","About",null,Gtk.Stock.ABOUT);

		action_group.add_action(about_action);

		string menu = """<menuitem name="About" action="about" />""";


		applet.set_flags(MatePanel.AppletFlags.EXPAND_MAJOR);

		applet.add(title);
		applet.setup_menu(menu,action_group);

		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

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
