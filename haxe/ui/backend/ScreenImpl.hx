package haxe.ui.backend;

import ceramic.Timer;
import ceramic.Visual;
import ceramic.TouchInfo;
import haxe.ui.core.Component;
import ceramic.Entity;
import ceramic.Key;
import haxe.ui.events.KeyboardEvent;
import ceramic.KeyCode;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import ceramic.App;
import ceramic.Filter;
import ceramic.Point;

@:access(haxe.ui.backend.ComponentImpl)
class ScreenImpl extends ScreenBase {
	var eventCallbacks:Map<String, Entity> = [];
	private var screenEntity:Entity;
	private var eventMap:Map<String, UIEvent->Void>;
	private var _point:Point = new Point();

	inline function screenToRoot(inX:Float, inY:Float, point:Point) {
		if (options != null && options.root != null) {
			options.root.screenToVisual(inX, inY, point);
		} else {
			point.x = inX;
			point.y = inY;
		}
	}

	public function new() {
		screenEntity = new Entity();
		eventMap = new Map<String, UIEvent->Void>();
		App.app.screen.onResize(null, this.handleResize);
	}

	var depthLowDirty = true;
	var depthLow(get, null):Float = Math.POSITIVE_INFINITY;

	function get_depthLow() {
		var low = depthLow;
		if (options.root.children != null && depthLowDirty) {
			for (child in options.root.children) {
				if (child.depth < low) {
					low = child.depth;
				}
			}
			depthLowDirty = false;
		}

		if (low == Math.POSITIVE_INFINITY) {
			low = 0;
		}
		return depthLow = low;
	}

	var depthHighDirty = true;
	var depthHigh(get, null):Float = Math.NEGATIVE_INFINITY;

	function get_depthHigh() {
		var max = depthHigh;
		if (options.root.children != null && depthHighDirty) {
			for (child in options.root.children) {
				if (child.depth > max) {
					max = child.depth;
				}
			}
			depthHighDirty = false;
		}

		if (max == Math.NEGATIVE_INFINITY) {
			max = 0;
		}
		return depthHigh = max;
	}

	public override function addComponent(component:haxe.ui.core.Component):haxe.ui.core.Component {
		var depth = depthHigh + 1;
		component.visual.depth = depth;
		@:privateAccess component.recursiveReady();
		var c = super.addComponent(component);
		resizeComponent(c);
		rootComponents.push(component);
		component.visual.active = true;
		rootAdd(c.visual);
		depthLowDirty = depthHighDirty = true;
		return c;
	}

	public override function containsComponent(child:Component):Bool {
		return rootComponents.indexOf(child) != -1;
	}

	private override function handleSetComponentIndex(component:Component, index:Int) {
		var isTop = index == rootComponents.length - 1;
		var position = (isTop) ? depthHigh + 1 : depthLow - 1;
		component.visual.depth = position;
		resizeComponent(component);
		depthLowDirty = depthHighDirty = true;
	}

	public override function removeComponent(component:Component, dispose:Bool = true, invalidate:Bool = true):Component {
		if (dispose) {
			component.visual.dispose();
		} else {
			component.visual.active = false;
			rootRemove(component.visual);
		}
		rootComponents.remove(component);
		depthLowDirty = depthHighDirty = true;
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

		if (eventMap.exists(UIEvent.RESIZE)) {
			eventMap.get(UIEvent.RESIZE)(new UIEvent(UIEvent.RESIZE));
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
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					eventMap.set(type, listener);
					screen.onPointerDown(screenEntity, onRightMouseDown);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					eventMap.set(type, listener);
					screen.onPointerUp(screenEntity, onRightMouseUp);
				}
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MIDDLE_MOUSE_DOWN)) {
					eventMap.set(type, listener);
					screen.onPointerDown(screenEntity, onMiddleMouseDown);
				}
			case MouseEvent.MIDDLE_MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MIDDLE_MOUSE_UP)) {
					eventMap.set(type, listener);
					screen.onPointerUp(screenEntity, onMiddleMouseUp);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (!eventMap.exists(MouseEvent.MOUSE_WHEEL)) {
					eventMap.set(type, listener);
					screen.onMouseWheel(screenEntity, onMouseWheel);
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
			case UIEvent.RESIZE:
				eventMap.set(type, listener);
			default:
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
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					screen.offPointerDown(onRightMouseDown);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_DOWN);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					screen.offPointerUp(onRightMouseUp);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_UP);
				}
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MIDDLE_MOUSE_DOWN)) {
					screen.offPointerDown(onMiddleMouseDown);
					eventMap.remove(MouseEvent.MIDDLE_MOUSE_DOWN);
				}
			case MouseEvent.MIDDLE_MOUSE_UP:
				if (eventMap.exists(MouseEvent.MIDDLE_MOUSE_UP)) {
					screen.offPointerUp(onMiddleMouseUp);
					eventMap.remove(MouseEvent.MIDDLE_MOUSE_UP);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (eventMap.exists(MouseEvent.MOUSE_WHEEL)) {
					screen.offMouseWheel(onMouseWheel);
					eventMap.remove(MouseEvent.MOUSE_WHEEL);
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
			case UIEvent.RESIZE:
				eventMap.remove(UIEvent.RESIZE);
			default:
		}
	}

	public function onMouseMove(info:TouchInfo) {
		var type = MouseEvent.MOUSE_MOVE;
		if (!eventMap.exists(type)) {
			return;
		}
		screenToRoot(info.x, info.y, _point);
		var event = new MouseEvent(type);
		event.screenX = _point.x;
		event.screenY = _point.y;
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

	public function onRightMouseDown(info:TouchInfo) {
		if (info.buttonId != ceramic.MouseButton.RIGHT) {
			return;
		}
		onMouseButton(MouseEvent.RIGHT_MOUSE_DOWN, info);
	}

	public function onRightMouseUp(info:TouchInfo) {
		if (info.buttonId != ceramic.MouseButton.RIGHT) {
			return;
		}
		onMouseButton(MouseEvent.RIGHT_MOUSE_UP, info);
	}

	public function onMiddleMouseDown(info:TouchInfo) {
		if (info.buttonId != ceramic.MouseButton.MIDDLE) {
			return;
		}
		onMouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, info);
	}

	public function onMiddleMouseUp(info:TouchInfo) {
		if (info.buttonId != ceramic.MouseButton.MIDDLE) {
			return;
		}
		onMouseButton(MouseEvent.MIDDLE_MOUSE_UP, info);
	}

	public function onMouseWheel(x:Float, y:Float) {
		var type = MouseEvent.MOUSE_WHEEL;
		if (!eventMap.exists(type)) {
			return;
		}
		var event = new MouseEvent(type);
		event.delta = y * -1;
		this.eventMap[type](event);
	}

	function onMouseButton(type:String, info:TouchInfo) {
		screenToRoot(info.x, info.y, _point);
		var event = new MouseEvent(type);
		event.screenX = _point.x;
		event.screenY = _point.y;
		event.data = info.buttonId;
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_DOWN | MouseEvent.MIDDLE_MOUSE_DOWN:
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

	private override function get_dpi():Float {
		return App.app.screen.nativeDensity * 96;
	}

	private override function get_isRetina():Bool {
		return App.app.screen.nativeDensity > 1;
	}

	private override function supportsEvent(type:String):Bool {
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

		#if filter_root
		App.app.screen.onResize(null, Ceramic.forceRender);
		App.app.onUpdate(null, onUpdate);
		#end

		if (options.root == null) {
			#if no_filter_root
			var parent = new Visual();
			#else
			var parent = new Filter();
			parent.autoRender = false;
			parent.explicitRender = true;
			#end

			parent.depth = 1000;
			options.root = parent;
			options.root.bindToNativeScreenSize();
		}

		return options;
	}

	function onPointerDown(info) {
		last_fast_fps = Timer.now;
		App.app.settings.targetFps = 60;
		#if filter_root
		Ceramic.forceRender();
		#end
	}

	function onInterval() {
		if (Timer.now - last_fast_fps > 5.0) {
			App.app.settings.targetFps = 15;
		}
	}

	function onUpdate(_) {
		#if filter_root
		Ceramic.redraw();
		#end
	}

	inline function rootAdd(visual:Visual) {
		#if filter_root
		options.root.content.add(visual);
		#else
		options.root.add(visual);
		#end
	}

	inline function rootRemove(visual:Visual) {
		#if filter_root
		options.root.content.remove(visual);
		#else
		options.root.remove(visual);
		#end
	}
}
