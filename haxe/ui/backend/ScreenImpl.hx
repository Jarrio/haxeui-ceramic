package haxe.ui.backend;

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
			c.visual.depth = k + 1;
		}
	}
	// TODO: shouldnt be neded
	public override function addComponent(component:haxe.ui.core.Component):haxe.ui.core.Component {
		@:privateAccess component.recursiveReady();
		var c = super.addComponent(component);
		resizeComponent(c);
		rootComponents.push(component);
		component.visual.active = true;
		//component.visual.depth = this.rootComponents.length;
		App.app.scenes.main.add(c.visual);

		this.mapComponents();
		return c;
	}
	
	public override function removeComponent(component:Component, dispose:Bool = true):Component {
		rootComponents.remove(component);
		if (dispose) {
			component.visual.dispose();
		} else {
			component.visual.active = false;
			App.app.scenes.main.remove(component.visual);
		}
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

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		switch (type) {
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE) == false) {
					screen.onPointerMove(null, MouseHelper.onMouseMove.bind(null, type, listener));
					eventMap.set(MouseEvent.MOUSE_MOVE, listener);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP) == false) {
					screen.onPointerUp(null, MouseHelper.onMouseButton.bind(null, type, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_UP, listener);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
					screen.onPointerUp(null, MouseHelper.onMouseButton.bind(null, type, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_DOWN, listener);
				}
			case KeyboardEvent.KEY_UP:
				if (eventMap.exists(KeyboardEvent.KEY_UP) == false) {
					var entity = new Entity();
					entity.id = KeyboardEvent.KEY_UP;
					this.eventCallbacks.set(KeyboardEvent.KEY_UP, entity);
					App.app.input.onKeyUp(entity, onKey.bind(type, listener));
				}
			case KeyboardEvent.KEY_DOWN:
				if (eventMap.exists(KeyboardEvent.KEY_DOWN) == false) {
					var entity = new Entity();
					entity.id = KeyboardEvent.KEY_DOWN;
					this.eventCallbacks.set(KeyboardEvent.KEY_DOWN, entity);
					App.app.input.onKeyDown(entity, onKey.bind(type, listener));
				}
			default:
		}
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
