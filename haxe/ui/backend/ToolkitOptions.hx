package haxe.ui.backend;

import haxe.ui.styles.Style.FontWeight;
import ceramic.BitmapFont;
import ceramic.Filter;
import ceramic.Visual;
import ceramic.Assets;
import ceramic.AssetId;

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
	 * specify the default font the backend uses for all text labels in the backend
	 */
	@:optional var default_text_font:BitmapFont;
	/**
	 * specify the default font the backend uses for all text inputsScreen.instance.options.default_text_font in the backend
	 */
	@:optional var default_textfield_font:BitmapFont;
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
	 * Text offset - If text appears to be incorrectly aligned, use this to add an offset 
	 * default is arbitrarily calculated. Set this to `0` to overwrite the default
	 */
	@:optional var text_offset:Float;

	/**
	 * The value to pre-render fonts at. The default is set to *1.5
	 */
	@:optional var prerender_font_size:Float;
	/**
	 * The value to pre-render fonts at. The default is set to *1.5
	 */
	@:optional var font_weights:Map<FontWeight, BitmapFont>;
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
