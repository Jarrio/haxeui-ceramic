package haxe.ui.backend;

import haxe.ui.core.Screen;

@:keep
class Ceramic {
	public static var root(get, never):#if filter_root ceramic.Filter #else ceramic.Visual #end;

	static function get_root():#if filter_root ceramic.Filter #else ceramic.Visual #end {
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
	
	#if filter_root
	public static function redraw() {
		if (options == null || root == null) {
			return;
		}

		if (draw) {
			//trace('redrawing');
			root.render();
		}
	}
	
	
	public static function forceRender() {
		if (options == null || root == null) {
			return;
		}

		if (!draw) {
			root.render();
		}
	}
	#end
}
