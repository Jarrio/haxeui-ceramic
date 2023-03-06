package haxe.ui.backend.ceramic;

import ceramic.App;
import haxe.ui.events.MouseEvent;
import ceramic.TouchInfo;
import haxe.ui.events.UIEvent;
import ceramic.MouseButton;
import haxe.ui.core.Component;

class MouseHelper {
	static public final clickTimeMs:Float = 40;
	static public final clickMaxLatency:Float = 220;
	static var clickTime:Float = 0;
	static var mouseLeftUpTime:Float = 0;
	static var mouseLeftDownTime:Float = 0;
	static var mouseRightUpTime:Float = 0;
	static var mouseRightDownTime:Float = 0;

	static public function onClick(component:Component, type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		event.data = type;

		clickTime = Date.now().getTime();
		//component.checkRedispatch(type, event);
		if (component.parentComponent != null) {
			component.parentComponent.checkRedispatch(type, event);
		}
		
		listener(event);
	}

	static public function onDoubleClick(component:Component, type:String, listener:UIEvent->Void, info:TouchInfo) {
		var screen = App.app.screen;
		var now = Date.now().getTime();
		var diff = now - clickTime;
		if (diff > clickTimeMs && diff <= clickMaxLatency) {
			var event = new MouseEvent(type);
			event.screenX = screen.pointerX;
			event.screenY = screen.pointerY;
			event.data = MouseButton.LEFT;
			//component.checkRedispatch(type, event);
			if (component.parentComponent != null) {
				component.parentComponent.checkRedispatch(type, event);
			}
			listener(event);
			return;
		}
		clickTime = now;
	}

	static public function onMouseMove(component:Component, type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		if (component != null) {
			if (component.parentComponent != null) {
				component.parentComponent.checkRedispatch(type, event);
			}
		}
		listener(event);
	}

	static public function onMouseOver(component:Component, type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		
		if (component.parentComponent != null) {
			component.parentComponent.checkRedispatch(type, event);
		}

		listener(event);
	}

	static public function onMouseOut(component:Component, type:String, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		
		if (component.parentComponent != null) {
			component.parentComponent.checkRedispatch(type, event);
		}

		listener(event);
	}

	static public function onLeftMouseDown(component:Component, listener:UIEvent->Void, info:TouchInfo) {

		mouseLeftDownTime = Date.now().getTime();
		onMouseButton(component, MouseEvent.MOUSE_DOWN, MouseButton.LEFT, listener, info);
	}

	static public function onLeftMouseUp(component:Component, listener:UIEvent->Void, info:TouchInfo) {
		var now = Date.now().getTime();
		mouseLeftUpTime = now;
		onMouseButton(component, MouseEvent.MOUSE_UP, MouseButton.LEFT, listener, info);
	}

	static public function onRightMouseDown(component:Component, listener:UIEvent->Void, info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		mouseRightDownTime = Date.now().getTime();
		onMouseButton(component, MouseEvent.RIGHT_MOUSE_DOWN, MouseButton.RIGHT, listener, info);
	}

	static public function onRightMouseUp(component:Component, listener:UIEvent->Void, info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		var now = Date.now().getTime();
		mouseRightUpTime = now;
		onMouseButton(component, MouseEvent.RIGHT_MOUSE_UP, MouseButton.RIGHT, listener, info);
	}

	static function onMouseButton(component:Component, type:String, button:MouseButton, listener:UIEvent->Void, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		event.data = info.buttonId;
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_DOWN:
				event.buttonDown = true;
			default:
		}

		if (component != null) {
			//component.checkRedispatch(type, event);
			if (component.parentComponent != null) {
				component.parentComponent.checkRedispatch(type, event);
			}
		}

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
