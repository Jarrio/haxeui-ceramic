package haxe.ui.backend;

import ceramic.App;

class CallLaterImpl {
	public function new(fn:Void->Void) {
		App.app.onceUpdate(null, (_) -> {
			fn();
		});
	}
}
