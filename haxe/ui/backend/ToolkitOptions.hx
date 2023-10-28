package haxe.ui.backend;

import ceramic.Visual;
import ceramic.Assets;
import haxe.ui.Toolkit;
import ceramic.App;
import ceramic.Scene;

typedef ToolkitOptions = {
	@:optional var root:Visual;
	@:optional var assets:Assets;
	/**
	 * custom aliasing value for the ui
	 * `default` = 0
	 */
	@:optional var antialiasing:Int;
	/**
	 * Which mode to run aliasing in
	 */
	@:optional var aliasmode:AliasMode;
}

function root() {
	var options = Toolkit.screen.options;
	if (options != null && options.root != null) {
		return options.root;
	}

	if (options == null) {
		options = Toolkit.screen.options = {
			root: null
		}
	}

	if (options.root == null) {
		var parent = new Visual();
		parent.depth = 1000;
		options.root = parent;
	}
	
	options.root.bindToNativeScreenSize();
	return options.root;
}

function aliasing() {
	var options = Toolkit.screen.options;
	if (options == null || options.aliasmode == null) {
		return 0;
	}

	return switch (Toolkit.screen.options.aliasmode) {
		case None: 0;
		case Project: App.app.settings.antialiasing;
		case Custom: Toolkit.screen.options.antialiasing;
		default: 0;
	}
}


enum abstract AliasMode(String) to String {
	/**
	 * Defaults to 0
	 */
	var None;
	/**
	 * Match ceramic project settings value
	 */
	var Project;
	/**
	 * Use the value provided to the `antialiasing` property
	 */
	var Custom;
}

