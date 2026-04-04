package haxe.ui.backend;

import ceramic.App;

class AppImpl extends AppBase {
	var loaded:Bool = false;
	var responded:Bool = false;

	public function new() {}

	private override function getToolkitInit():ToolkitOptions {
		return {};
	}

	override function init(onReady:Void->Void, onEnd:Void->Void = null) {
		var assets = App.app.assets;

		assets.onComplete(null, (loaded) -> {
			if (!responded && loaded) {
				this.loaded = true;
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
