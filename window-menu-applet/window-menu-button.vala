namespace WindowWidgets{
	public class WindowMenuButton : Gtk.MenuButton{
		//Properties

		private Gtk.Image button_image = new Gtk.Image();

		private Wnck.Window _window;
		private Gdk.Pixbuf _icon;
		private int _icon_size = 18;

		public Wnck.Window window {
			get{ return _window; }
			set{ _window = value; }
		}

		public Gdk.Pixbuf icon{
			get{ return _icon; }
			set{ _icon = value; }
		}

		public int icon_size{
			get{ return _icon_size; }
			set{ _icon_size = value; }
		}

		public WindowMenuButton(){
			Object();

			this.set_relief(Gtk.ReliefStyle.NONE);

			this.set_image(button_image);

			this.set_always_show_image(true);

			this.icon_set();
			this.menu_set();
		}

		public void	icon_set(){
			if(_window != null){
				_icon = _window.get_icon();
				_icon = _icon.scale_simple(_icon_size * this.get_scale_factor(),_icon_size * this.get_scale_factor(), Gdk.InterpType.HYPER);

				if(!_window.is_active()){
					_icon.saturate_and_pixelate(_icon, 0, false);
				}

				Cairo.Surface surface = Gdk.cairo_surface_create_from_pixbuf(_icon, this.get_scale_factor(), null);
				button_image.set_from_surface(surface);
			}
			else {
				button_image.clear();
			}
		}

		public void menu_set(){

			if(_window != null){
				this.set_popup(new Wnck.ActionMenu(_window));
				this.set_sensitive(true);
			}
			else{
				this.get_popup().detach();
				this.set_sensitive(false);
			}

		}

	}

}
