package haxe.ui.backend;

import haxe.ui.core.Screen;
import haxe.ui.geom.Rectangle;
import ceramic.TouchInfo;
import haxe.ui.core.TextInput;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.Component;
import haxe.ui.core.TextDisplay;
import haxe.ui.events.UIEvent;
import haxe.ui.styles.Style;
import ceramic.App;
import haxe.ui.events.MouseEvent;
import ceramic.MouseButton;
import haxe.ui.backend.ToolkitOptions;

class ComponentImpl extends ComponentBase {
	private var eventMap:Map<String, UIEvent->Void>;
	private var addedRoot:Bool = false;

	public function new() {
		super();

		eventMap = new Map<String, UIEvent->Void>();
		// recursiveReady();
	}

	private function recursiveReady() {
		var component:Component = cast(this, Component);
		component.ready();

		for (child in component.childComponents) {
			child.recursiveReady();
		}
	}

	public var isClipped:Bool = false;

	private override function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
		if (left == null || top == null) {
			return;
		}

		if (this.visual.x != left) {
			this.visual.x = left;
			if (this.isClipped) {
				this.filter.x = left;
			}
		}

		if (this.visual.y != top) {
			this.visual.y = top;
			if (this.isClipped) {
				this.filter.y = top;
			}
		}

		// if (this.y != top)
		// 	this.y = this.top = top;

		// if (clipQuad != null) {
		// 	if (clipQuad.x != left) clipQuad.x = left;
		// 	if (clipQuad.y != top)  clipQuad.y = top;
		// }
		// trace('${pad(this.id)}: move -> ${left}x${top}');
	}

	private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		if (width == null || height == null || visual == null) {
			return;
		}

		// visual.size(w, h);
		if (visual.width != width || visual.height != height) {
			if (border.width != null) {
				border.width = width;
			}

			if (border.height != null) {
				border.height = height;
			}

			background.vertices = [
				    0,      0,
				width,      0,
				    0, height,
				width, height
			];

			background.indices = [
				0, 1, 3,
				0, 2, 3
			];

			visual.width = background.width = width;
			visual.height = background.height = height;
			if (style != null) {
				applyStyle(style);
			}
		}
	}

	var v = false;

	override function handleClipRect(value:Rectangle):Void {
		// @TODO fix clipping with absolute/box
		if (this.parentComponent == null)
			return;

		var parent = this.parentComponent;
		// return;
		if (value == null) {
			if (parent == null) {
				visual.parent.remove(filter);
			} else if (parent.isClipped) {
				parent.filter.content.remove(filter);
			} else {
				parent.visual.remove(filter);
			}

			filter.dispose();
			this.isClipped = false;
			this.filter = null;
		} else {
			if (this.filter == null) {
				this.filter = new ceramic.Filter();
				filter.textureFilter = NEAREST;
				filter.antialiasing = aliasing();
				if (parent == null) {
					visual.parent.add(filter);
					// filter.depthRange = 0;
					// trace('here');
				} else if (parent.isClipped) {
					parent.filter.content.add(filter);
				} else {
					parent.visual.add(filter);
				}
				this.isClipped = true;
				// this.parentComponent.visual.remove(this.visual);
				filter.content.add(this.visual);
			}
			// filter.color = Color.BLACK;
			this.visual.x = -value.left;
			this.visual.y = -value.top;
			this.filter.x = left;
			this.filter.y = top;
			this.filter.width = value.width;
			this.filter.height = value.height;
			// filter.size(value.width, value.height);
			// filter.pos(value.left, value.top + this.parentComponent.y);

			// filter.pos(value.left, value.top + this.parentComponent.y);
		}
	}

	private override function handleVisibility(show:Bool):Void {
		if (show != this.visual.visible) {
			this.visual.visible = show;
			this.visual.touchable = show;
		}
	}

	//***********************************************************************************************************
	// Image
	//***********************************************************************************************************
	public override function createImageDisplay():ImageDisplay {
		if (_imageDisplay == null) {
			super.createImageDisplay();
			this.visual.add(_imageDisplay.visual);
		}
		return _imageDisplay;
	}

	public override function removeImageDisplay():Void {
		if (_imageDisplay != null) {
			this.visual.remove(_imageDisplay.visual);
			_imageDisplay.visual.dispose();
			_imageDisplay = null;
		}
	}

	//***********************************************************************************************************
	// Display tree
	//***********************************************************************************************************

	function mapChildren() {
		for (k => c in this.childComponents) {
			c.visual.depth = k;
		}
	}

	private override function handleSetComponentIndex(child:Component, index:Int) {
		child.visual.depth = index;
		this.mapChildren();
	}

	private override function handleAddComponent(child:Component):Component {
		child.visual.active = true;
		this.visual.add(child.visual);
		this.mapChildren();
		return child;
	}

	private override function handleAddComponentAt(child:Component, index:Int):Component {
		child.visual.active = true;
		child.visual.depth = index;
		this.visual.add(child.visual);
		this.mapChildren();
		return child;
	}

	private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		// trace('${pad(this.id)}: remove component -> ${child.id}');
		child.visual.active = false;
		if (dispose) {
			child.visual.dispose();
		}
		this.visual.remove(child.visual);
		this.mapChildren();
		return child;
	}

	private override function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
		// trace('${pad(this.id)}: remove component at index -> ${index}');
		return this.handleRemoveComponent(this.childComponents[index], dispose);
	}

	//***********************************************************************************************************
	// Style
	//***********************************************************************************************************
	private override function applyStyle(style:Style) {
		if (style == null) {
			return;
		}
		// trace('${pad(this.id)}: apply style ->');
		if (style.opacity != null) {
			visual.alpha = style.opacity;
		}

		background.color = style.backgroundColor;
		if (style.backgroundColor == null) {
			background.alpha = 0;
		} else {
			background.alpha = 1;
		}

		// trace(Color.fromInt(style.backgroundColor).toHexString());
		if (style.backgroundColor != null) {
			background.alpha = 1;
			background.color = style.backgroundColor;
			var alpha:Int = 0xFF000000;

			if (style.backgroundColorEnd != null) {
				background.colorMapping = VERTICES;

				var start = (style.backgroundColor | alpha);
				var end = (style.backgroundColorEnd | alpha);
				var type = "vertical";
				if (style.backgroundGradientStyle != null) {
					type = style.backgroundGradientStyle;
				}

				switch (type) {
					case "horizontal":
						background.colors = [start, end, start, end];
					case "vertical" | _:
						background.colors = [start, start, end, end];
				}
			} else {
				background.colorMapping = MESH;
			}

			if (style.backgroundOpacity != null) {
				background.alpha = style.backgroundOpacity;
			}
		}

		if (style.borderColor != null) {
			border.borderColor = style.borderColor;
		}

		if (style.borderLeftSize != null) {
			if (style.borderOpacity != null) {
				// line.alpha = style.borderOpacity;
			}

			border.borderLeftColor = style.borderLeftColor;
			border.borderLeftSize = style.borderLeftSize;
		}

		if (style.borderRightSize != null) {
			if (style.borderOpacity != null) {
				//line.alpha = style.borderOpacity;
			}
			border.borderRightColor = style.borderRightColor;
			border.borderRightSize = style.borderRightSize;
		}

		if (style.borderTopSize != null) {
			if (style.borderOpacity != null) {
				//line.alpha = style.borderOpacity;
			}
			border.borderTopColor = style.borderTopColor;
			border.borderTopSize = style.borderTopSize;
		}

		if (style.borderBottomSize != null) {
			if (style.borderOpacity != null) {
				//line.alpha = style.borderOpacity;
			}
			border.borderBottomColor = style.borderBottomColor;
			border.borderBottomSize = style.borderBottomSize;
		}
	}

	public function checkRedispatch(type:String, event:MouseEvent) {
		// trace(type);
		if (this.hasEvent(type) && this.hitTest(event.screenX, event.screenY)) {
			this.eventMap[type](event);
		}

		if (parentComponent != null) {
			parentComponent.checkRedispatch(type, event);
		}
	}

	private function findClipComponent():Component {
		var c:Component = cast(this, Component);
		var clip:Component = null;
		while (c != null) {
			if (c.componentClipRect != null) {
				clip = c;
				break;
			}
			c = c.parentComponent;
		}

		return clip;
	}

	//***********************************************************************************************************
	// Events
	//***********************************************************************************************************

	private function hasComponentOver(ref:Component, x:Float, y:Float, reverse:Bool = false):Bool {
		var array:Array<Component> = getVisibleComponentsAtPoint(x, y, reverse);
		if (array.length == 0) {
			return false;
		}

		return !hasChildRecursive(cast ref, cast array[array.length - 1]);
	}

	private function getVisibleComponentsAtPoint(x:Float, y:Float, reverse:Bool) {
		return getComponentsAtPoint(x, y, reverse).filter(c -> c.hidden == false);
	}

	private function getComponentsAtPoint(x:Float, y:Float, reverse:Bool = false):Array<Component> {
		var array:Array<Component> = new Array<Component>();
		for (r in Screen.instance.rootComponents) {
			findChildrenAtPoint(r, x, y, array);
		}

		if (reverse == true) {
			array.reverse();
		}

		return array;
	}

	private function findChildrenAtPoint(child:Component, x:Float, y:Float, array:Array<Component>) {
		if (child.hitTest(x, y)) {
			array.push(child);
			for (c in child.childComponents) {
				findChildrenAtPoint(c, x, y, array);
			}
		}
	}

	public function hasChildRecursive(parent:Component, child:Component):Bool {
		if (parent == child) {
			return true;
		}
		var r = false;
		for (t in parent.childComponents) {
			if (t == child) {
				r = true;
				break;
			}

			r = hasChildRecursive(t, child);
			if (r == true) {
				break;
			}
		}

		return r;
	}

	function onMouseMove(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
			return;
		}
		var listener = eventMap.get(MouseEvent.MOUSE_MOVE);
		var hittest = this.hitTest(info.x, info.y);
		if (hittest) {
			var event = new MouseEvent(MouseEvent.MOUSE_MOVE);
			event.screenX = info.x;
			event.screenY = info.y;
			listener(event);
		}
	}

	var over = false;

	function _onMouseOut(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OUT;
		if (!this.eventMap.exists(type)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		var listener = this.eventMap[type];

		if (over) {
			listener(event);
			over = false;
		}
	}

	function _onMouseOver(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OVER;
		if (!this.eventMap.exists(type)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		var listener = this.eventMap[type];
		if (!over) {
			this.over = true;
			listener(event);
		}
	}

	function onMouseLeftUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		onMouseUp(MouseEvent.MOUSE_UP, info);
	}

	function onMouseRightUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onMouseUp(MouseEvent.RIGHT_MOUSE_UP, info);
	}

	function onMouseMiddleUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.MIDDLE) {
			return;
		}
		onMouseUp(MouseEvent.MIDDLE_MOUSE_UP, info);
	}

	function onMouseUp(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		if (this.hitTest(info.x, info.y) && !this.hasComponentOver(cast this, info.x, info.y)) {
			listener(event);
		}
	}

	function onMouseLeftDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		onMouseDown(MouseEvent.MOUSE_DOWN, info);
	}

	function onMouseRightDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onMouseDown(MouseEvent.RIGHT_MOUSE_DOWN, info);
	}

	function onMouseMiddleDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.MIDDLE) {
			return;
		}
		onMouseDown(MouseEvent.MIDDLE_MOUSE_DOWN, info);
	}

	function onMouseDown(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		if (this.hitTest(info.x, info.y) && !this.hasComponentOver(cast this, info.x, info.y)) {
			listener(event);
		}
	}

	public function onMouseWheel(x:Float, y:Float) {
		var type = MouseEvent.MOUSE_WHEEL;
		var screen = App.app.screen;
		if (!this.eventMap.exists(type)) {
			return;
		}

		if (this.hasComponentOver(cast this, screen.pointerX, screen.pointerY)) {
			return;
		}

		var event = new MouseEvent(type);
		event.delta = y * -1;
		this.eventMap[type](event);
	}

	var left_click_time:Float;

	function onDoubleClick(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		var now = Date.now().getTime();
		var diff = now - this.left_click_time;
		var type = MouseEvent.DBL_CLICK;
		click_increment++;
		if (diff < 250 && click_increment >= 2) {
			click_increment = 0;
			_onClick(type, info);
			return;
		}
		left_click_time = now;
	}

	var click_increment:Int = 0;

	function onMouseLeftClick(info:TouchInfo) {
		// trace('here');
		if (info.buttonId == -1) {
			if (info.touchIndex != 0) {
				return;
			}
		} else {
			if (info.buttonId != MouseButton.LEFT) {
				return;
			}
		}

		_onClick(MouseEvent.CLICK, info);
	}

	function onMouseRightClick(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		_onClick(MouseEvent.RIGHT_CLICK, info);
	}

	function onMouseMiddleClick(info:TouchInfo) {
		if (info.buttonId != MouseButton.MIDDLE) {
			return;
		}
		_onClick(MouseEvent.MIDDLE_CLICK, info);
	}

	function _onClick(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		if (this.hitTest(info.x, info.y) && !this.hasComponentOver(cast this, info.x, info.y)) {
			this.eventMap[type](event);
		}
	}

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;

		switch (type) {
			case MouseEvent.CLICK:
				if (!eventMap.exists(MouseEvent.CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseLeftClick);
				}
			case MouseEvent.RIGHT_CLICK:
				if (!eventMap.exists(MouseEvent.RIGHT_CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseRightClick);
				}
			case MouseEvent.DBL_CLICK:
				if (!eventMap.exists(MouseEvent.DBL_CLICK)) {
					// trace('registered');
					// trace(type);
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, onDoubleClick);
				}
			case MouseEvent.MOUSE_MOVE:
				if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					this.eventMap.set(type, listener);
					screen.onPointerMove(visual, this.onMouseMove);
				}
			case MouseEvent.MOUSE_OVER:
				if (!eventMap.exists(MouseEvent.MOUSE_OVER)) {
					this.eventMap.set(type, listener);
					visual.onPointerOver(visual, this._onMouseOver);
				}
			case MouseEvent.MOUSE_OUT:
				if (!eventMap.exists(MouseEvent.MOUSE_OUT)) {
					this.eventMap.set(MouseEvent.MOUSE_OUT, listener);
					visual.onPointerOut(visual, _onMouseOut);
				}
			case MouseEvent.MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseLeftUp);
				}
			case MouseEvent.MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					this.eventMap.set(type, listener);
					screen.onPointerDown(visual, this.onMouseLeftDown);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseRightUp);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					this.eventMap.set(type, listener);
					screen.onPointerDown(visual, this.onMouseRightDown);
				}
			case MouseEvent.MIDDLE_MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MIDDLE_MOUSE_UP)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseMiddleUp);
				}
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MIDDLE_MOUSE_DOWN)) {
					this.eventMap.set(type, listener);
					screen.onPointerDown(visual, this.onMouseMiddleDown);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (!eventMap.exists(MouseEvent.MOUSE_WHEEL)) {
					this.eventMap.set(type, listener);
					screen.onMouseWheel(visual, this.onMouseWheel);
				}
			default:
		}
		// Toolkit.callLater(function() {
		// 	trace(this.id, type, cast(this, Component).className);
		// });
		//		trace('${pad(this.id)}: map event -> ${type}');
	}

	private override function unmapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		switch (type) {
			case MouseEvent.CLICK:
				if (eventMap.exists(MouseEvent.CLICK)) {
					screen.offPointerUp(onMouseLeftClick);
					eventMap.remove(MouseEvent.CLICK);
				}
			case MouseEvent.DBL_CLICK:
				if (eventMap.exists(MouseEvent.DBL_CLICK)) {
					screen.offPointerUp(onDoubleClick);
					eventMap.remove(MouseEvent.DBL_CLICK);
				}
			case MouseEvent.MIDDLE_CLICK:
				if (eventMap.exists(MouseEvent.MIDDLE_CLICK)) {
					screen.offPointerUp(onMouseMiddleClick);
					eventMap.remove(MouseEvent.MIDDLE_CLICK);
				}
			case MouseEvent.RIGHT_CLICK:
				if (eventMap.exists(MouseEvent.RIGHT_CLICK)) {
					screen.offPointerUp(onMouseRightClick);
					eventMap.remove(MouseEvent.RIGHT_CLICK);
				}
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					screen.offPointerMove(onMouseMove);
					eventMap.remove(MouseEvent.MOUSE_MOVE);
				}
			case MouseEvent.MOUSE_OVER:
				if (eventMap.exists(MouseEvent.MOUSE_OVER)) {
					visual.offPointerOver(_onMouseOver);
					eventMap.remove(MouseEvent.MOUSE_OVER);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT)) {
					visual.offPointerOut(_onMouseOut);
					eventMap.remove(MouseEvent.MOUSE_OUT);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP)) {
					screen.offPointerUp(onMouseLeftUp);
					eventMap.remove(MouseEvent.MOUSE_UP);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					screen.offPointerUp(onMouseLeftDown);
					eventMap.remove(MouseEvent.MOUSE_DOWN);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					screen.offPointerUp(onMouseRightUp);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_UP);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					screen.offPointerUp(onMouseRightDown);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_DOWN);
				}
			case MouseEvent.MIDDLE_MOUSE_UP:
				if (eventMap.exists(MouseEvent.MIDDLE_MOUSE_UP)) {
					screen.offPointerUp(onMouseMiddleUp);
					eventMap.remove(MouseEvent.MIDDLE_MOUSE_UP);
				}
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MIDDLE_MOUSE_DOWN)) {
					screen.offPointerUp(onMouseMiddleDown);
					eventMap.remove(MouseEvent.MIDDLE_MOUSE_DOWN);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (eventMap.exists(MouseEvent.MOUSE_WHEEL)) {
					screen.offMouseWheel(onMouseWheel);
					eventMap.remove(MouseEvent.MOUSE_WHEEL);
				}
			default:
		}
		// trace('${pad(this.id)}: unmap event -> ${type}');
	}

	//***********************************************************************************************************
	// Text related
	//***********************************************************************************************************
	public override function createTextDisplay(text:String = null):TextDisplay {
		if (_textDisplay == null) {
			super.createTextDisplay(text);
			// _textDisplay.visual.touchable = false;
			this.visual.add(_textDisplay.visual);
			// trace('${pad(this.id)}: create text diplay');
		}
		return _textDisplay;
	}

	public override function createTextInput(text:String = null):TextInput {
		if (_textInput == null) {
			super.createTextInput(text);
			this.visual.add(_textInput.visual);
		}
		return _textInput;
	}

	//***********************************************************************************************************
	// Util
	//***********************************************************************************************************

	public static inline function pad(s:String, len:Int = 20):String {
		return StringTools.rpad(s, " ", len);
	}
}
