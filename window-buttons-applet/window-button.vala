namespace WindowWidgets{
	public class WindowButton : Gtk.EventBox {
		//Properties

		private Gtk.Image button_image = new Gtk.Image();

		private WindowButtonType _button_type;
		private int _icon_size = 18;
		private Wnck.Window _window;
		private IconAction _current_action;

		public WindowButtonsTheme theme;

		public WindowButtonType button_type{
			get{return _button_type;}
			set{_button_type = value;}
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

			this.enter_notify_event.connect( (object,event) => { this.event_set(event); return false; } );
			this.leave_notify_event.connect( (object,event) => { this.event_set(event); return false; } );
			this.button_press_event.connect( (object,event) => { this.event_set(event); return false; } );
			this.button_release_event.connect( (object,event) => { this.event_set(event); return false; } );
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

		public void update(bool theme_change = false){

			IconType type;
			if(_button_type == WindowButtonType.MINIMIZE)
				type = IconType.MINIMIZE;
			else if(_button_type == WindowButtonType.MAXIMIZE){
				if(_window != null && _window.is_maximized())
					type = IconType.UNMAXIMIZE;
				else
					type = IconType.MAXIMIZE;
			} else
				type = IconType.CLOSE;


			IconState state;
			if(_window != null && !_window.is_active())
				state = IconState.UNFOCUSED;
			else
				state = IconState.FOCUSED;


			Gdk.Pixbuf? icon = theme.get_icon(type, state, _current_action);

			// If this is a new theme, and it doesn't have an icon for the current state and action, then reset
			// everything, otherwise we would be showing the icons of the old theme
			if(theme_change && icon == null){
				state = IconState.FOCUSED;
				_current_action = IconAction.NORMAL;

				icon = theme.get_icon(type, state, _current_action);
			}

			if(icon != null){
				Cairo.Surface surface = Gdk.cairo_surface_create_from_pixbuf(icon, this.get_scale_factor(), null);
				button_image.set_from_surface(surface);
			}

		}

		private void event_set(Gdk.Event *event){
			if(event->get_event_type() == Gdk.EventType.ENTER_NOTIFY || event->get_event_type() == Gdk.EventType.BUTTON_RELEASE)
				_current_action = IconAction.HOVERED;
			else if(event->get_event_type() == Gdk.EventType.BUTTON_PRESS)
				_current_action = IconAction.PRESSED;
			else
				_current_action = IconAction.NORMAL;

			this.update();
		}

	}

	public enum WindowButtonType{
		CLOSE = 0,
		MINIMIZE = 1,
		MAXIMIZE = 2
	}

}
