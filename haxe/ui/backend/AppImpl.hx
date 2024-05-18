package haxe.ui.backend;

import assets.Fonts;
import ceramic.App;
import ceramic.Assets;
import haxe.ui.core.Screen;
class AppImpl extends AppBase {
	var loaded:Bool = false;
	var responded:Bool = false;

	public function new() {}

	override function init(onReady:Void->Void, onEnd:Void->Void = null) {
		var assets = App.app.assets;
		// assets.add(Fonts.ROBOTO_REGULAR);
		// assets.add(Fonts.ROBOTO_BOLD);
		// assets.add(Fonts.ROBOTO_BOLD_ITALIC);
		assets.onComplete(null, (loaded) -> {
			if (!responded && loaded) {
				this.loaded = true;
				trace('loaded ${Date.now()}');
				
				responded = true;
				onReady();
			} else {
				trace('[Haxeui-Ceramic] Error: Failed to load fonts');
				onReady();
			}
		});
		assets.load();
	}
}
