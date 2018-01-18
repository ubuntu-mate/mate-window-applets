namespace WindowWidgets{
	public class WindowButton : Gtk.EventBox {
		//Properties

		private Gtk.Image button_image = new Gtk.Image();
		private Gtk.IconTheme icon_theme = new Gtk.IconTheme();

		private WindowButtonType _button_type;
		private string _theme = "Black";
		private Gdk.Pixbuf _icon;
		private int _icon_size = 18;
		private Wnck.Window _window;

		public WindowButtonType button_type{
			get{return _button_type;}
			set{_button_type = value;}
		}

		public string theme{
			get{return _theme;}
			set{_theme = value;}
		}

		public Gdk.Pixbuf icon{
			get{return _icon;}
			set{_icon = value;}
		}

		public int icon_size{
			get{return icon_size;}
			set{_icon_size = value;}
		}

		public Wnck.Window window{
			get{return _window;}
			set{_window = value;}
		}

		//Constructor

		public WindowButton(WindowButtonType btype){
			Object();

			this._button_type = btype;

			this.add(button_image);
			this.button_image.show();

			icon_theme.set_screen(this.get_screen());

			string[] global_path = { "/usr/share/icons/mate-window-applets/" , "/usr/local/share/icons/mate-window-applets/"};
			string local_path = Environment.get_home_dir() + "/.icons/mate-window-applets/" ;

			icon_theme.set_search_path(global_path);
			icon_theme.append_search_path(local_path);

			icon_theme.set_custom_theme(_theme);

			this.icon_set(new Gdk.Event(Gdk.EventType.NOTHING));

			// Time for connecting

			this.button_release_event.connect( (ev_button) => {
				if(ev_button.button == 1){
					if(_button_type == WindowButtonType.CLOSE){
						close_window(0);
					}
					else if(_button_type == WindowButtonType.MINIMIZE){
						minimize_window();
					}
					else if(_button_type == WindowButtonType.MAXIMIZE){
						maximize_window();
					}
				}

				return false;

			});

			this.enter_notify_event.connect( (object,event) => { this.icon_set(event); return false; } );
			this.leave_notify_event.connect( (object,event) => { this.icon_set(event); return false; } );
		}

		//Helpers

		public void close_window(uint32 timestamp){
			_window.close(timestamp);
		}

		public void minimize_window(){
			_window.minimize();
		}

		public void maximize_window(){
			if(_window.is_maximized()){
				_window.unmaximize();
			}
			else{
				_window.maximize();
			}
		}

		public void icon_set(Gdk.Event *event){
			if(event->get_event_type() == Gdk.EventType.NOTHING || event->get_event_type() == Gdk.EventType.LEAVE_NOTIFY){
				if(_button_type == WindowButtonType.CLOSE){
					if(icon_theme.has_icon("close")){
						try{
							_icon = icon_theme.load_icon("close",-1,Gtk.IconLookupFlags.FORCE_SIZE);
							_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
						} catch (GLib.Error e){
							stdout.printf("Error: %s\n", e.message);
						}
					}
				}
				else if(_button_type == WindowButtonType.MINIMIZE){
					if(icon_theme.has_icon("minimize")){
						try{
							_icon = icon_theme.load_icon("minimize",-1,Gtk.IconLookupFlags.FORCE_SIZE);
							_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
						} catch (GLib.Error e){
							stdout.printf("Error: %s\n", e.message);
						}
					}
				}
				else if(_button_type == WindowButtonType.MAXIMIZE){
					if(_window != null){
						if(_window.is_maximized()){
							if(icon_theme.has_icon("unmaximize")){
								try{
									_icon = icon_theme.load_icon("unmaximize",-1,Gtk.IconLookupFlags.FORCE_SIZE);
									_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
								} catch (GLib.Error e){
									stdout.printf("Error: %s\n", e.message);
								}
							}
						}
						else{
							if(icon_theme.has_icon("maximize")){
								try{
									_icon = icon_theme.load_icon("maximize",-1,Gtk.IconLookupFlags.FORCE_SIZE);
									_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
								} catch (GLib.Error e){
									stdout.printf("Error: %s\n", e.message);
								}
							}
						}
					}
					else{
						if(icon_theme.has_icon("maximize")){
							try{
								_icon = icon_theme.load_icon("maximize",-1,Gtk.IconLookupFlags.FORCE_SIZE);
								_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
							} catch (GLib.Error e){
								stdout.printf("Error: %s\n", e.message);
							}
						}
					}
				}
			}
			else if(event->get_event_type() == Gdk.EventType.ENTER_NOTIFY){
				if(_button_type == WindowButtonType.CLOSE){
					if(icon_theme.has_icon("close_hovered")){
						try{
							_icon = icon_theme.load_icon("close_hovered",-1,Gtk.IconLookupFlags.FORCE_SIZE);
							_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
						} catch (GLib.Error e){
							stdout.printf("Error: %s\n", e.message);
						}
					}
				}
				else if(_button_type == WindowButtonType.MINIMIZE){
					if(icon_theme.has_icon("minimize_hovered")){
						try{
							_icon = icon_theme.load_icon("minimize_hovered",-1,Gtk.IconLookupFlags.FORCE_SIZE);
							_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
						} catch (GLib.Error e){
							stdout.printf("Error: %s\n", e.message);
						}
					}
				}
				else if(_button_type == WindowButtonType.MAXIMIZE){
					if(_window != null){
						if(_window.is_maximized()){
							if(icon_theme.has_icon("unmaximize_hovered")){
								try{
									_icon = icon_theme.load_icon("unmaximize_hovered",-1,Gtk.IconLookupFlags.FORCE_SIZE);
									_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
								} catch (GLib.Error e){
									stdout.printf("Error: %s\n", e.message);
								}
							}
						}
						else{
							if(icon_theme.has_icon("maximize_hovered")){
								try{
									_icon = icon_theme.load_icon("maximize_hovered",-1,Gtk.IconLookupFlags.FORCE_SIZE);
									_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
								} catch (GLib.Error e){
									stdout.printf("Error: %s\n", e.message);
								}
							}
						}
					}
					else{
						if(icon_theme.has_icon("maximize_hovered")){
							try{
								_icon = icon_theme.load_icon("maximize_hovered",-1,Gtk.IconLookupFlags.FORCE_SIZE);
								_icon = _icon.scale_simple(_icon_size,_icon_size,Gdk.InterpType.HYPER);
							} catch (GLib.Error e){
								stdout.printf("Error: %s\n", e.message);
							}
						}
					}
				}
			}

			if(_icon != null){
				button_image.set_from_pixbuf(_icon);
			}
		}

		public void theme_set(string value){
			_theme = value;
			icon_theme.set_custom_theme(_theme);
		}

	}

	public enum WindowButtonType{
		CLOSE = 0,
		MINIMIZE = 1,
		MAXIMIZE = 2
	}

}
