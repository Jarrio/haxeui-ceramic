package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.Assets;

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

	/**
	 * The value to pre-render fonts at. The default is set to +4
	 */
	@:optional var prerender_font_size:Float;
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
