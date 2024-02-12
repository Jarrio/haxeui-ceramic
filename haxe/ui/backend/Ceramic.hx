package haxe.ui.backend;

import haxe.ui.backend.ToolkitOptions.options as internal_options;
import haxe.ui.backend.ToolkitOptions.root as internal_root;

class Ceramic {
	public static var root(get, never):#if no_filter_root ceramic.Visual #else ceramic.Filter #end;

	inline static function get_root() {
		return internal_root();
	}

	public static var options(get, never):ToolkitOptions;

	inline static function get_options() {
		return internal_options();
	}
#if !no_filter_root
	public static function forceRender() {
		internal_root().render();
	}
#end
}
