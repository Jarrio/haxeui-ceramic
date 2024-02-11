package haxe.ui.backend;

import ceramic.App;

class CallLaterImpl {
	public function new(fn:Void->Void) {
		App.app.onceImmediate(() -> fn());
	}
}
