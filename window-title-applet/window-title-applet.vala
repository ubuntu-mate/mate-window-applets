namespace WindowTitleApplet{
	public void reload(Gtk.Label label){
		Wnck.Screen.get_default().force_update();
		Wnck.Window *window = Wnck.Screen.get_default().get_active_window();

		if(window != null){
			label.set_label(window->get_name());

			window->name_changed.connect( (window) => { reload(label); });
		}
	}

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowTitleApplet")return false;

		Gtk.Label title = new Gtk.Label("");

		reload(title);

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

		Wnck.Screen.get_default().active_window_changed.connect( (window) => { reload(title); });

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowTitleAppletFactory", true, typeof (MatePanel.Applet), WindowTitleApplet.factory);

	return 0;
}
