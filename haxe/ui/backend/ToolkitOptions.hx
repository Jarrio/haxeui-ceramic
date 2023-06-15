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

	var scene = App.app.scenes.get('haxeui_backend');
	if (scene == null) {
		scene = new Scene();
		scene.depth = 10;
		App.app.scenes.set('haxeui_backend', scene);
	}
	
	return scene;
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

