package haxe.ui.backend.ceramic;

import ceramic.App;
import haxe.ui.events.MouseEvent;
import ceramic.TouchInfo;
import haxe.ui.events.UIEvent;
import ceramic.MouseButton;
import haxe.ui.core.Component;

class MouseHelper {
	static final clickTimeMs:Float = 40;
	static final clickMaxLatency:Float = 220;
	static var mouseClickTime:Float = 0;
	static var mouseDownTime:Float = 0;

	static public function onClick(type:String, listener:UIEvent->Void, info:TouchInfo) {
		var screen = App.app.screen;
		var now = Date.now().getTime();
		var diff = now - mouseDownTime;
		if (diff > clickTimeMs && diff <= clickMaxLatency) {
			var event = new MouseEvent(type);
			event.screenX = screen.pointerX;
			event.screenY = screen.pointerY;
			event.data = MouseButton.LEFT;
			mouseClickTime = now;
			listener(event);
		}
		mouseDownTime = 0;
	}

	static public function onDoubleClick(type:String, listener:UIEvent->Void, info:TouchInfo) {
		var screen = App.app.screen;
		var now = Date.now().getTime();
		var diff = now - mouseClickTime;
		if (diff > clickTimeMs && diff <= clickMaxLatency) {
			var event = new MouseEvent(type);
			event.screenX = screen.pointerX;
			event.screenY = screen.pointerY;
			event.data = MouseButton.LEFT;
			listener(event);
			return;
		}
		mouseClickTime = now;
	}

	static public function onMouseMove(type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		listener(event);
	}

	static public function onMouseOver(type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		listener(event);
	}

	static public function onMouseOut(type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		listener(event);
	}

	static public function onMouseButton(type:String, button:MouseButton, listener:UIEvent->Void, info:TouchInfo) {
		if (info.buttonId != button) {
			return;
		}
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		event.data = info.buttonId;
		var now = Date.now().getTime();
		mouseDownTime = now;
		listener(event);
	}

	static public function onMouseWheel(comp:Component, type:String, listener:UIEvent->Void, x:Float, y:Float) {
		if (!comp.hitTest(App.app.screen.pointerX, App.app.screen.pointerY)) {
    	return;
		}
		var event = new MouseEvent(type);
		event.delta = y * -1;
		listener(event);
	}
}
