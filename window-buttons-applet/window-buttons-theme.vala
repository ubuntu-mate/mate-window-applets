namespace WindowWidgets {
	public class WindowButtonsTheme {

		private string _theme_name;
		private int _icon_size;
		private int _scale_factor;
		private Gdk.Pixbuf[,,] _pixbufs;
		private string[] _extensions;
		private string[] _prefixes;
		private string[,] _type_names;
		private string[,] _state_names;
		private string[,] _action_names;

		public WindowButtonsTheme(string name, Gdk.RGBA fg_color, int icon_size, int scale_factor){
			_pixbufs = new Gdk.Pixbuf[
				IconType.TYPES,
				IconState.STATES,
				IconAction.ACTIONS
			];

			_theme_name = name;

			_icon_size = icon_size;
			_scale_factor = scale_factor;

			_extensions = {"svg", "png"};

			_prefixes = {null, "button", "icon"};

			_type_names = {
				{"close", null},
				{"minimize", null},
				{"maximize", null},
				{"unmaximize", "restore"}
			};

			_state_names = {
				{"focused", ""},
				{"unfocused", null}
			};

			_action_names = {
				{"normal", ""},
				{"prelight", null},
				{"pressed", null}
			};

			string[] paths = get_search_paths();

			load_icons(paths);

			if( _pixbufs[IconType.CLOSE, IconState.FOCUSED, IconAction.NORMAL] == null
				|| _pixbufs[IconType.MINIMIZE, IconState.FOCUSED, IconAction.NORMAL] == null
				|| _pixbufs[IconType.MAXIMIZE, IconState.FOCUSED, IconAction.NORMAL] == null ) {
				load_fallback_icons(fg_color);
			}
		}

		private string[] get_search_paths(){
			string[] paths = {
				Environment.get_home_dir() + "/.icons/mate-window-applets/" + _theme_name,
				Environment.get_home_dir() + "/.themes/" + _theme_name + "/metacity-1",
				Environment.get_home_dir() + "/.themes/" + _theme_name + "/unity",
				"/usr/local/share/themes/" + _theme_name + "/metacity-1",
				"/usr/local/share/themes/" + _theme_name + "/unity",
				"/usr/share/themes/" + _theme_name + "/metacity-1",
				"/usr/share/themes/" + _theme_name + "/unity"
			};
			string[] result = {};
			foreach(string path in paths){
				if( FileUtils.test(path, FileTest.IS_DIR) )
					result += path;
			}
			return result;
		}

		private void load_icons(string[] paths){

			for(int type = 0; type < IconType.TYPES; type++){
				for(int state = 0; state < IconState.STATES; state++){
					for(int action = 0; action < IconAction.ACTIONS; action++){

						var icon_names = get_icon_aliases(type, state, action);
						Gdk.Pixbuf icon = find_icon(paths, icon_names);

						if( icon != null ){
							_pixbufs[type, state, action] = icon;
						}

					}
				}
			}
		}

		private List<string> get_icon_aliases(int type, int state, int action){
			var aliases = new List<string> ();
			for(int i = 0; i < _type_names.length[1]; i++){
				if(_type_names[type,i] == null)
					break;

				for(int j = 0; j < _state_names.length[1]; j++){
					if(_state_names[state,j] == null)
						break;

					for(int k = 0; k < _action_names.length[1]; k++){
						if(_action_names[action,k] == null)
							break;

						string[] parts = {_type_names[type,i]};

						if(_state_names[state,j] != "")
							parts += _state_names[state,j];

						if(_action_names[action,k] != "")
							parts += _action_names[action,k];

						aliases.append( string.joinv("_", parts) );

					}
				}
			}
			return aliases;
		}

		private Gdk.Pixbuf? find_icon(string[] paths, List<string> icon_names){
			string file_path = find_icon_filepath(paths, icon_names);
			if( file_path != null ){
				try {
					return new Gdk.Pixbuf.from_file_at_size(file_path, this._icon_size * this._scale_factor, this._icon_size * this._scale_factor);
				} catch (GLib.Error e){
					stdout.printf("Error: %s\n", e.message);
				}
			}
			return null;
		}

		private string? find_icon_filepath(string[] paths, List<string> icon_names){
			foreach(string prefix in _prefixes){
				foreach(string ext in _extensions){
					foreach(string path in paths){
						string result = find_icon_filepath_with(path, ext, prefix, icon_names);
						if(result != null)
							return result;
					}
				}
			}
			return null;
		}

		private string? find_icon_filepath_with(string path, string extension, string? prefix, List<string> icon_names){
			foreach(string icon_name in icon_names){
				if(prefix != null)
					icon_name = prefix + "_" + icon_name;

				string file_path = path + "/" + icon_name + "." + extension;
				if( FileUtils.test(file_path, FileTest.EXISTS) )
					return file_path;
			}
			return null;
		}

		public Gdk.Pixbuf? get_icon(IconType type, IconState state, IconAction action){
			return _pixbufs[type, state, action];
		}

		private void load_fallback_icons(Gdk.RGBA fg_color){
			double lum = 0.299*fg_color.red + 0.587*fg_color.green + 0.114*fg_color.blue;
			string theme;
			if(lum > 0.5)
				theme = "White";
			else
				theme = "Black";

			#if LOCAL_PATH
				string[] paths = {"/usr/local/share/pixmaps/mate-window-applets/" + theme};
			#else
				string[] paths = {"/usr/share/pixmaps/mate-window-applets/" + theme};
			#endif

			load_icons(paths);
		}

	}

	public enum IconType {
		CLOSE = 0,
		MINIMIZE,
		MAXIMIZE,
		UNMAXIMIZE,

		TYPES
	}

	public enum IconState {
		FOCUSED = 0,
		UNFOCUSED,

		STATES
	}

	public enum IconAction {
		NORMAL = 0,
		HOVERED,
		PRESSED,

		ACTIONS
	}
}