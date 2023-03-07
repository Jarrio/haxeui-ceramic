package haxe.ui.backend;

import ceramic.TouchInfo;
import haxe.ui.core.Component;
import haxe.ui.backend.ceramic.MouseHelper;
import ceramic.Entity;
import ceramic.Key;
import haxe.ui.events.KeyboardEvent;
import ceramic.KeyCode;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import ceramic.App;

@:access(haxe.ui.backend.ComponentImpl)
class ScreenImpl extends ScreenBase {
	var eventCallbacks:Map<String, Entity> = [];
	private var eventMap:Map<String, UIEvent->Void>;

	public function new() {
		eventMap = new Map<String, UIEvent->Void>();
		App.app.screen.onResize(null, this.handleResize);
	}


	function mapComponents() {
		for (k => c in this.rootComponents) {
			c.visual.depth = k;
			if (c.visual.children != null) {
				c.visual.sortChildrenByDepth();
			}
		}
	}
	// TODO: shouldnt be neded
	public override function addComponent(component:haxe.ui.core.Component):haxe.ui.core.Component {
		@:privateAccess component.recursiveReady();
		var c = super.addComponent(component);
		resizeComponent(c);
		rootComponents.push(component);
		component.visual.active = true;
		App.app.scenes.main.add(c.visual);
		this.mapComponents();
		return c;
	}
	
	private override function handleSetComponentIndex(component:Component, index:Int) {
		component.visual.depth = index;
		resizeComponent(component);
		this.mapComponents();
	}

	public override function removeComponent(component:Component, dispose:Bool = true):Component {
		
		if (dispose) {
			component.visual.dispose();
		} else {
			component.visual.active = false;
			App.app.scenes.main.remove(component.visual);
		}
		rootComponents.remove(component);
		this.mapComponents();
		return component;
	}

	private function handleResize() {
		for (c in rootComponents) {
			if (c.percentWidth > 0) {
				c.width = (this.width * c.percentWidth) / 100;
			}
			if (c.percentHeight > 0) {
				c.height = (this.height * c.percentHeight) / 100;
			}
		}
	}

	private override function unmapEvent(type:String, listener:UIEvent->Void) {
		switch (type) {
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_MOVE).dispose();
					this.eventCallbacks.remove(MouseEvent.MOUSE_MOVE);
					eventMap.remove(MouseEvent.MOUSE_MOVE);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_UP).dispose();
					this.eventCallbacks.remove(MouseEvent.MOUSE_UP);
					eventMap.remove(MouseEvent.MOUSE_UP);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_DOWN).dispose();
					this.eventCallbacks.remove(MouseEvent.MOUSE_DOWN);
					eventMap.remove(MouseEvent.MOUSE_DOWN);
				}
			default:
		}
	}

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		var entity = new Entity();
		entity.id = type;
		switch (type) {
			case MouseEvent.MOUSE_MOVE:
				if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					this.eventCallbacks.set(type, entity);
					eventMap.set(type, listener);
					screen.onPointerMove(entity, onMouseMove.bind(type, listener));
				}
			case MouseEvent.MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
					this.eventCallbacks.set(type, entity);
					eventMap.set(type, listener);
					screen.onPointerUp(entity, onLeftMouseUp);
				}
			case MouseEvent.MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					this.eventCallbacks.set(type, entity);
					eventMap.set(type, listener);
					screen.onPointerDown(entity, onLeftMouseDown);
				}
			case KeyboardEvent.KEY_UP:
				if (!eventMap.exists(KeyboardEvent.KEY_UP)) {
					this.eventCallbacks.set(type, entity);
					eventMap.set(type, listener);
					App.app.input.onKeyUp(entity, onKey.bind(type, listener));
				}
			case KeyboardEvent.KEY_DOWN:
				if (!eventMap.exists(KeyboardEvent.KEY_DOWN)) {
					this.eventCallbacks.set(type, entity);
					eventMap.set(type, listener);
					App.app.input.onKeyDown(entity, onKey.bind(type, listener));
				}
			default:
		}
	}

	public function onMouseMove(type:String, listener:UIEvent->Void, info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
			return;
		}
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		listener(event);
	}

	public function onLeftMouseDown(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
			return;
		}
		onMouseButton(MouseEvent.MOUSE_DOWN, info);
	}

	public function onLeftMouseUp(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
			return;
		}
		onMouseButton(MouseEvent.MOUSE_UP, info);
	}

	function onMouseButton(type:String, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		event.data = info.buttonId;
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_DOWN:
				event.buttonDown = true;
			default:
		}
		this.eventMap[type](event);
	}

	function onKey(type:String, listener:KeyboardEvent->Void, key:Key) {
		var event = new KeyboardEvent(type);
		event.keyCode = key.keyCode;
		listener(event);
	}

	private override function supportsEvent(type:String):Bool {
		if (type == UIEvent.RESIZE) {
			return true;
		}
		return true;
	}

	private override function get_width():Float {
		return App.app.screen.width;
	}

	private override function get_height():Float {
		return App.app.screen.height;
	}

	private override function get_actualWidth():Float {
		return App.app.screen.actualWidth;
	}

	private override function get_actualHeight():Float {
		return App.app.screen.actualHeight;
	}
}
