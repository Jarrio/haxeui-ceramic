package haxe.ui.backend;

import ceramic.Timer;
import ceramic.Visual;
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
import ceramic.Filter;

@:access(haxe.ui.backend.ComponentImpl)
class ScreenImpl extends ScreenBase {
	var depth_tracker = 1;
	var eventCallbacks:Map<String, Entity> = [];
	private var screenEntity:Entity;
	private var eventMap:Map<String, UIEvent->Void>;

	public function new() {
		screenEntity = new Entity();
		eventMap = new Map<String, UIEvent->Void>();
		App.app.screen.onResize(null, this.handleResize);
	}

	function mapComponents() {

	}
	// TODO: shouldnt be neded
	public override function addComponent(component:haxe.ui.core.Component):haxe.ui.core.Component {
		@:privateAccess component.recursiveReady();
		var c = super.addComponent(component);
		resizeComponent(c);
		rootComponents.push(component);
		component.visual.active = true;
		rootAdd(c.visual);
		this.mapComponents();
		return c;
	}
	
	private override function handleSetComponentIndex(component:Component, index:Int) {

		component.visual.depth = index;
		resizeComponent(component);
		this.mapComponents();
	}

	public override function removeComponent(component:Component, dispose:Bool = true, invalidate:Bool = true):Component {
		if (dispose) {
			component.visual.dispose();
		} else {
			component.visual.active = false;
			rootRemove(component.visual);
		}
		rootComponents.remove(component);
		this.mapComponents();
		return component;
	}

	private function handleResize() {
		if (options.root != null) {
			options.root.bindToNativeScreenSize();
		}

		for (c in rootComponents) {
			if (c.percentWidth > 0) {
				c.width = Std.int((this.width * c.percentWidth) / 100);
			}
			if (c.percentHeight > 0) {
				c.height = Std.int((this.height * c.percentHeight) / 100);
			}
		}
	}

	private override function unmapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		switch (type) {
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					screen.offPointerMove(onMouseMove);
					eventMap.remove(MouseEvent.MOUSE_MOVE);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP)) {
					screen.offPointerUp(onLeftMouseUp);
					eventMap.remove(MouseEvent.MOUSE_UP);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					screen.offPointerDown(onLeftMouseDown);
					eventMap.remove(MouseEvent.MOUSE_DOWN);
				}
			case KeyboardEvent.KEY_DOWN:
				if (eventMap.exists(KeyboardEvent.KEY_DOWN)) {
					App.app.input.offKeyDown(onKeyDown);
					eventMap.remove(KeyboardEvent.KEY_DOWN);
				}
			case KeyboardEvent.KEY_UP:
				if (eventMap.exists(KeyboardEvent.KEY_UP)) {
					App.app.input.offKeyUp(onKeyUp);
					eventMap.remove(KeyboardEvent.KEY_UP);
				}
			default:
		}
	}

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		switch (type) {
			case MouseEvent.MOUSE_MOVE:
				if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					eventMap.set(type, listener);
					screen.onPointerMove(screenEntity, onMouseMove);
				}
			case MouseEvent.MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
					eventMap.set(type, listener);
					screen.onPointerUp(screenEntity, onLeftMouseUp);
				}
			case MouseEvent.MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					eventMap.set(type, listener);
					screen.onPointerDown(screenEntity, onLeftMouseDown);
				}
			case KeyboardEvent.KEY_UP:
				if (!eventMap.exists(KeyboardEvent.KEY_UP)) {
					eventMap.set(type, listener);
					App.app.input.onKeyUp(screenEntity, onKeyUp);
				}
			case KeyboardEvent.KEY_DOWN:
				if (!eventMap.exists(KeyboardEvent.KEY_DOWN)) {
					eventMap.set(type, listener);
					App.app.input.onKeyDown(screenEntity, onKeyDown);
				}
			default:
		}
	}

	public function onMouseMove(info:TouchInfo) {
		var type = MouseEvent.MOUSE_MOVE;
		if (!eventMap.exists(type)) {
			return;
		}
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		this.eventMap[type](event);
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

	public function onKeyUp(key:Key) {
		if (!eventMap.exists(KeyboardEvent.KEY_UP)) {
			return;
		}
		onKey(KeyboardEvent.KEY_UP, key);
	}

	public function onKeyDown(key:Key) {
		if (!eventMap.exists(KeyboardEvent.KEY_DOWN)) {
			return;
		}
		onKey(KeyboardEvent.KEY_DOWN, key);
	}

function onKey(type:String, key:Key) {
	var listener = this.eventMap[type];
	if (listener == null) {
		return;
	}
	var event = new KeyboardEvent(type);
	event.keyCode = key.keyCode;

	if (key.keyCode == KeyCode.LALT || key.keyCode == KeyCode.RALT) {
		event.altKey = true;
	}

	if (key.keyCode == KeyCode.LCTRL || key.keyCode == KeyCode.RCTRL) {
		event.ctrlKey = true;
	}

	if (key.keyCode == KeyCode.LSHIFT || key.keyCode == KeyCode.RSHIFT) {
		event.shiftKey = true;
	}

	event.data = key;
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

	override function get_options() {
		if (_options == null) {
			options = {};
		}
		return super.get_options();
	}

	override function set_options(value:ToolkitOptions) {
		super.set_options(value);
		return init(value);
	}

	public var last_fast_fps:Float;
	function init(options:ToolkitOptions) {
		if (options.performance == null) {
			options.performance = None;
		}

		if (options.prerender_font_size == null) {
			options.prerender_font_size = 1.5;
		}

		if (options == null || options.aliasmode == null) {
			options.aliasmode = None;
		}

		if (options.performance == FPS) {
			App.app.screen.onPointerDown(options.root, onPointerDown);
			Timer.interval(options.root, 0.5, onInterval);
		}

		App.app.screen.onResize(null, Ceramic.forceRender);

		App.app.onUpdate(null, onUpdate);

		if (options.root == null) {
			#if no_filter_root
			var parent = new Visual();
			#else
			var parent = new Filter();
			parent.autoRender = false;
			parent.explicitRender = true;
			#end

			//parent.depth = 0;
			options.root = parent;
			options.root.bindToNativeScreenSize();
		}

		return options;
	}

	function onPointerDown(info) {
		last_fast_fps = Timer.now;
		App.app.settings.targetFps = 60;
		Ceramic.forceRender();
	}

	function onInterval() {
		if (Timer.now - last_fast_fps > 5.0) {
			App.app.settings.targetFps = 15;
		}
	}

	function onUpdate(_) {
		Ceramic.redraw();
	}

	inline function rootAdd(visual:Visual) {
		
		#if no_filter_root
		options.root.add(visual);
		#else
		options.root.content.add(visual);
		#end
	}

	inline function rootRemove(visual:Visual) {
		#if no_filter_root
		options.root.remove(visual);
		#else
		options.root.content.remove(visual);
		#end
	}
}
