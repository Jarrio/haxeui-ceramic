package haxe.ui.backend;

import haxe.ui.backend.ToolkitOptions.root as internal_root;

class Ceramic {
	public static var root(get, never):#if no_filter_var ceramic.Visual #else ceramic.Filter #end;

	inline static function get_root() {
		return internal_root();
	}
#if !no_filter_var 
	public inline static function forceRender() {
		internal_root().render();
	}
#end
}
