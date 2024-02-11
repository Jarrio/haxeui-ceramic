package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.Assets;
import haxe.ui.Toolkit;
import ceramic.App;
import ceramic.Scene;
import ceramic.Timer;

enum PerformanceOptions {
	/**
	 * default - no thottling
	 */
	None;

	/**
	 * Will thottle fps when it has been detirmined that the app is in an idle state
	 */
	FPS;
	/**
	 * Will render all UI to a texture
	 */
	Render;
}

typedef ToolkitOptions = {
	/**
	 * A performance toggle that reduces UI resources
	 */
	@:optional var performance:PerformanceOptions;

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

var _init:Bool = false;

function root() {
	var options = Toolkit.screen.options;

	if (options == null) {
		options = Toolkit.screen.options = {
			root: null,
			performance: None
		}
	}

	if (!_init) {
		init();
		_init = true;
	}
	return options.root;
}

inline function rootAdd(visual:Visual) {
	var root = root();
	if (options().performance == Render) {
		var p:Filter = cast root;
		p.content.add(visual);
	} else {
		root.add(visual);
	}
}

inline function rootRemove(visual:Visual) {
	if (options().performance == Render) {
		var p:Filter = cast root();
		p.content.remove(visual);
	} else {
		root().remove(visual);
	}
}

function options() {
	return Toolkit.screen.options;
}

var last_fast_fps:Float;

function init() {
	
	if (options().performance == null) {
		options().performance = None;
	}

	if (options().performance == FPS) {
		App.app.screen.onPointerDown(options().root, _ -> {
			last_fast_fps = Timer.now;
			App.app.settings.targetFps = 60;
		});

		Timer.interval(options().root, 0.5, () -> {
			if (Timer.now - last_fast_fps > 5.0) {
				App.app.settings.targetFps = 15;
			}
		});
	}

	var parent:Visual = options().root;
	if (parent == null) {
		if (options().performance == Render) {
			parent = new Filter();
			var p:Filter = cast parent;
			p.autoRender = false;
			p.explicitRender = true;
		} else {
			parent = new Visual();
		}
	}

	parent.depth = 1000;
	options().root = parent;
	options().root.bindToNativeScreenSize();
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
