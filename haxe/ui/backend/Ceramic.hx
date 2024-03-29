package haxe.ui.backend;

import haxe.ui.core.Screen;

@:keep
class Ceramic {
	public static var root(get, never):#if no_filter_root ceramic.Visual #else ceramic.Filter #end;

	static function get_root():#if no_filter_root ceramic.Visual #else ceramic.Filter #end {
		return Screen.instance.options.root;
	}

	public static var options(get, never):ToolkitOptions;

	static function get_options() {
		return Screen.instance.options;
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
			root.render();
		}
		#end
	}

	public static function forceRender() {
		#if !no_filter_root
		if (options == null || root == null) {
			return;
		}

		if (!draw) {
			root.render();
		}
		#end
	}
}
