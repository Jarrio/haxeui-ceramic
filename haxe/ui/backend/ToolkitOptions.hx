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
}

typedef ToolkitOptions = {
	/**
	 * A performance toggle that reduces UI resources
	 */
	@:optional var performance:PerformanceOptions;

	@:optional var root:#if no_filter_root Visual #else Filter #end;
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

function root():#if no_filter_root Visual #else Filter #end {
	var options = Toolkit.screen.options;

	if (options == null) {
		options = Toolkit.screen.options = {
			root: null,
			performance: PerformanceOptions.None
		}
	}

	if (!_init) {
		init();
		_init = true;
	}
	return options.root;
}

inline function rootAdd(visual:Visual) {
	#if no_filter_root
		root().add(visual);
	#else
	root().content.add(visual);
	#end
}

inline function rootRemove(visual:Visual) {
	#if no_filter_root
	root().remove(visual);
	#else
	root().content.remove(visual);
	#end
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

	App.app.screen.onResize(null, Ceramic.forceRender);

	App.app.onUpdate(null, function(_) {
		Ceramic.redraw();
	});
	

	if (options().root == null) {
		#if no_filter_root
		var parent = new Visual();
		#else
		var parent = new Filter();
		parent.autoRender = false;
		parent.explicitRender = true;
		#end

		parent.depth = 1000;
		options().root = parent;
		options().root.bindToNativeScreenSize();
	}
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
