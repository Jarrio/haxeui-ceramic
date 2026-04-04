package haxe.ui.backend;

import ceramic.KeyCode;

class PlatformImpl extends PlatformBase {
	override function getKeyCode(keyId:String):Int {
		return switch (keyId) {
			case 'escape': KeyCode.ESCAPE;
			case 'enter': KeyCode.ENTER;
			case 'space': KeyCode.SPACE;
			case 'tab': KeyCode.TAB;
			case 'up': KeyCode.UP;
			case 'down': KeyCode.DOWN;
			case 'left': KeyCode.LEFT;
			case 'right': KeyCode.RIGHT;
			case _:
				keyId.charCodeAt(0);
		}
	}

	override function getSystemLocale():String {
		#if js
		return js.Browser.navigator.language;
		#elseif sys
		return Sys.getEnv("LANG");
		#else
		return null;
		#end
	}
}
