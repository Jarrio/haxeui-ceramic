package haxe.ui.backend;

import ceramic.Assets;

typedef ToolkitOptions = {
	@:optional var assets:Assets;
	/**
	 * custom aliasing value for the ui
	 * `default` = 0
	 */
	@:optional var antialiasing:Int;
	/**
	 * default = 
	 * Which 
	 */
	@:optional var aliasmode:AliasMode;
}

enum abstract AliasMode(Int) {
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