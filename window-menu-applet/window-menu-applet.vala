using WindowWidgets;

namespace WindowMenuApplet{
	public void reload(WindowWidgets.WindowMenuButton button){
		Wnck.Screen.get_default().force_update();
		Wnck.Window *window = Wnck.Screen.get_default().get_active_window();

		if(window != null){
			button.window = window;

			button.icon_set();
			button.menu_set();

			window->icon_changed.connect(button.icon_set);
			window->actions_changed.connect(button.menu_set);
		}
	}

	public void change_orient(WindowWidgets.WindowMenuButton button,MatePanel.Applet applet){
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

		reload(button);

	}

	private bool factory(MatePanel.Applet applet,string iid){
		if(iid != "WindowMenuApplet")return false;

		WindowMenuButton button = new WindowMenuButton();

		change_orient(button,applet);

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

		Gtk.Window about = builder.get_object("About") as Gtk.Window;

		Gtk.ActionGroup action_group = new Gtk.ActionGroup("action_group");

		Gtk.Action about_action = new Gtk.Action("about","About",null,Gtk.Stock.ABOUT);

		action_group.add_action(about_action);

		string menu = """<menuitem name="About" action="about" />""";

		applet.add(button);
		applet.setup_menu(menu,action_group);

		about.delete_event.connect( (event) => { about.hide() ; return true ; } );

		about_action.activate.connect( () => { about.present() ; } );

		applet.change_orient.connect( () => { change_orient(button,applet) ; } );

		applet.show_all();

		Wnck.Screen.get_default().active_window_changed.connect( (window) => { reload(button); });

		return true;
	}

}


static int main(string[] args){
	Gtk.init(ref args);

	MatePanel.Applet.factory_main("WindowMenuAppletFactory", true, typeof (MatePanel.Applet), WindowMenuApplet.factory);

	return 0;
}
