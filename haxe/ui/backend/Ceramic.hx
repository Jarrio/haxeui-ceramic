package haxe.ui.backend;

import haxe.ui.backend.ToolkitOptions.options as internal_options;
import haxe.ui.backend.ToolkitOptions.root as internal_root;

@:keep
class Ceramic {
	public static var root(get, never):#if no_filter_root ceramic.Visual #else ceramic.Filter #end;

	static function get_root():#if no_filter_root ceramic.Visual #else ceramic.Filter #end {
		return options.root;
	}

	public static var options(get, never):ToolkitOptions;

	static function get_options() {
		return internal_options();
	}

	public static var draw:Bool = false;

	public static function startForceDraw() {
		draw = true;
	}

	public static function endForceDraw() {
		draw = false;
	}

	public static function redraw() {
		#if !no_filter_root
		if (options == null || root == null) {
			return;
		}

		if (draw) {
			//trace('redrawing');
			internal_options().root.render();
		}
		#end
	}

	public static function forceRender() {
		#if !no_filter_root
		if (options == null || root == null) {
			return;
		}

		internal_options().root.bindToNativeScreenSize();

		if (!draw) {
			internal_options().root.render();
		}
		#end
	}
}
