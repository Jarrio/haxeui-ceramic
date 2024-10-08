package haxe.ui.backend;

import ceramic.Texture;
import haxe.ui.assets.ImageInfo;
import haxe.ui.loaders.image.ImageLoader;
import haxe.ui.backend.ceramic.BorderQuad.Direction;
import ceramic.AlphaColor;
import ceramic.Color;
import ceramic.Border;
import ceramic.Mesh;
import ceramic.Quad;
import haxe.ui.core.Screen;
import haxe.ui.geom.Rectangle;
import ceramic.TouchInfo;
import haxe.ui.core.InteractiveComponent;
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
import ceramic.Point;
import ceramic.Timer;
import ceramic.Filter;
import haxe.ui.backend.ceramic.CursorType;
import haxe.ui.backend.ceramic.Cursor;
import haxe.ui.backend.ScreenImpl;
import ceramic.NineSlice;

class ComponentImpl extends ComponentBase {
	static var point = new Point(0, 0);

	private var eventMap:Map<String, UIEvent->Void>;
	private var addedRoot:Bool = false;

	public function new() {
		super();

		eventMap = new Map<String, UIEvent->Void>();
		// recursiveReady();
	}

	function updateRender() {
		if (Screen.instance.options.performance == FPS) {
			Screen.instance.last_fast_fps = Timer.now;
			App.app.settings.targetFps = 60;
		}
		Ceramic.forceRender();
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
		this.visual.x = left;
		if (this.isClipped) {
			this.filter.x = left;
		}

		this.visual.y = top;
		if (this.isClipped) {
			this.filter.y = top;
		}

	}

	private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		if (visual == null) {
			return;
		}

		if (visual.width != width || visual.height != height) {
			if (style != null) {
				applyStyle(style);
			}
		}

		if (height > 0) {
			this.visual.height = height;
		}

		if (width > 0) {
			this.visual.width = width;
		}
		
		this.updateRender();
	}

	var v = false;

	override function handleClipRect(value:Rectangle):Void {
		// @TODO fix clipping with absolute/box
		if (this.parentComponent == null) {
			return;
		}

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
				filter.density = App.app.screen.nativeDensity;
				filter.antialiasing = Screen.instance.options.antialiasing;
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
			// this.visual.x = -value.left;
			// this.visual.y = -value.top;
			// this.filter.x = left;
			// this.filter.y = top;
			// this.filter.width = value.width;
			// this.filter.height = value.height;
			var l = (left);
			if (l % 2 != 0) {
				// l++;
			}
			var t = (top);
			if (t % 2 != 0) {
				// t++;
			}
			var lr = (value.left);
			if (lr % 2 != 0) {
				// lr++;
			}
			var tr = (value.top);
			if (tr % 2 != 0) {
				// tr++;
			}
			var w = (value.width);
			if (w % 2 != 0) {
				// w++;
			}
			var h = (value.height);
			if (h % 2 != 0) {
				// h++;
			}

			this.visual.x = -lr;
			this.visual.y = -tr;
			this.filter.x = l;
			this.filter.y = t;
			this.filter.width = w;
			this.filter.height = h;
			// filter.size(value.width, value.height);
			// filter.pos(value.left, value.top + this.parentComponent.y);

			// filter.pos(value.left, value.top + this.parentComponent.y);
		}
		this.updateRender();
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
			this.add(_imageDisplay.visual);
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
		//visual.normalizeChildrenDepth();
	}

	var depth_counter = 0;

	private override function handleSetComponentIndex(child:Component, index:Int) {
		child.visual.depth = index + 2;
		mapChildren();
	}

	private override function handleAddComponent(child:Component):Component {
		// child.visual.depth = child.depth;
		trace(this.depth);
		var v = this.depth + 2;
		if (v < 2) {
			v = 2;
		}
		child.visual.depth = this.depth + 2;
		this.add(child.visual);
		return child;
	}

	private override function handleAddComponentAt(child:Component, index:Int):Component {
		child.visual.depth = index + 2;
		this.add(child.visual);
		mapChildren();
		return child;
	}

	private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		// trace('${pad(this.id)}: remove component -> ${child.id}');
		child.visual.active = false;
		if (dispose) {
			child.visual.destroy();
		} else {
			this.visual.remove(child.visual);
		}
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
	var imgCache:Map<String, Texture> = [];

	private override function applyStyle(style:Style) {
		// if (style == null) {
		// 	return;
		// }

		// background
		var alpha:Int = 0xFF000000;
		if (style.opacity != null) {
			visual.alpha = style.opacity;
		}

		if (style.backgroundOpacity != null) {
			visual.bg_alpha = style.backgroundOpacity;
		}

		var alpha:Int = 0xFF000000;

		if (style.backgroundColor != null) {
			if (style.backgroundOpacity != null) {
				visual.bg_alpha = style.backgroundOpacity;
			}

			if (style.backgroundColorEnd != null) {
				var start = (style.backgroundColor | alpha);
				var end = (style.backgroundColorEnd | alpha);
				var type = "vertical";
				if (style.backgroundGradientStyle != null) {
					type = style.backgroundGradientStyle;
				}

				visual.setGradient(type, start, end);
			} else {
				visual.bg_color = style.backgroundColor;
			}
		} else {
			visual.bg_alpha = 0;
		}

		//if (this.text == 'Haxe' || this.text == "Java") {
			//trace(this.text, style.borderType, style.borderLeftSize, style.borderRightSize, style.borderTopSize, style.borderBottomSize);
			//trace(Color.fromInt(style.borderTopColor).toHexString(), Color.fromInt(style.borderBottomColor).toHexString());
		//}
		// 0x83AAD4, 0xFFFFFF 0xD2D2D2
		// borders
		var type = style.borderType;
		switch (type) {
			case None:
				visual.border_size = 0;
				visual.border_color = Color.NONE;
			case Full:
				visual.border_size = 0;
				visual.border_color = Color.NONE;
				//trace(style.borderSize, style.borderLeftSize, style.borderRightSize, style.borderTopSize, style.borderBottomSize);
				
				if (style.borderSize != null) {
					visual.border_size = style.borderSize;
					if (style.borderSize > 0) {
						visual.border_color = style.borderColor;
					}
				}
			case Compound:
				if (style.borderLeftSize != null) {
					visual.border_left_size = style.borderLeftSize;
					if (style.borderLeftSize > 0) {
						visual.border_left_color = (style.borderLeftColor);
					}
				}

				if (style.borderRightSize != null) {
					visual.border_right_size = style.borderRightSize;
					if (style.borderRightSize > 0) {
						visual.border_right_color = (style.borderRightColor);
					}
				}

				if (style.borderTopSize != null) {
					visual.border_top_size = style.borderTopSize;
					if (style.borderTopSize > 0) {
						visual.border_top_color = (style.borderTopColor);
					}
				}

				if (style.borderBottomSize != null) {
					visual.border_bottom_size = style.borderBottomSize;
					if (style.borderBottomSize > 0) {
						trace(style.borderBottomColor);
						visual.border_bottom_color = (style.borderBottomColor);
					}
				}
			default:
				trace(type, this._id, this.id, this.visual.id);
		}

		if (style.borderOpacity != null) {
			visual.border_alpha = style.borderOpacity;
		}

		var sliceTop = style.backgroundImageSliceTop != null;
		var sliceLeft = style.backgroundImageSliceLeft != null;
		var sliceBottom = style.backgroundImageSliceBottom != null;
		var sliceRight = style.backgroundImageSliceRight != null;

		if (style.backgroundImage != null && (sliceTop || sliceLeft || sliceBottom || sliceRight)) {
			var topSlice = style.backgroundImageSliceTop;
			var botSlice = style.backgroundImageSliceBottom;
			var leftSlice = style.backgroundImageSliceLeft;
			var rightSlice = style.backgroundImageSliceRight;

			// var obj:NineSlice;
			if (!visual.isSlice) {
				var texture = null;
				if (imgCache.exists(style.backgroundImage)) {
					texture = imgCache.get(style.backgroundImage);
					visual.setNineSlice(texture, topSlice, botSlice, leftSlice, rightSlice);
				} else {
					ImageLoader.instance.load(style.backgroundImage, function(image:ImageInfo) {
						if (image == null) {
							trace(
								'[haxeui-ceramic] image ${style.backgroundImage} could not be loaded'
							);
							return;
						}
						texture = image.data;
						visual.setNineSlice(texture, topSlice, botSlice, leftSlice, rightSlice);
						imgCache.set(style.backgroundImage, image.data);

						trace('saved image');
					});
				}
			}

			if (sliceTop && sliceLeft && sliceBottom && sliceRight) {
				visual.setSlice(topSlice, botSlice, leftSlice, rightSlice);
				// visual.setSlicePos(leftSlice, topSlice);
				// visual.setSliceSize(rightSlice, botSlice);
				trace(topSlice, botSlice, leftSlice, rightSlice);
			} else {
				trace(topSlice, botSlice, leftSlice, rightSlice);
			}
		}

		this.updateRender();
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

	inline function root() {
		return Screen.instance.options.root;
	}

	function onMouseMove(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
			return;
		}

		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;

		var listener = eventMap.get(MouseEvent.MOUSE_MOVE);
		var hittest = this.hitTest(x, y);
		if (hittest) {
			var event = new MouseEvent(MouseEvent.MOUSE_MOVE);
			event.screenX = x;
			event.screenY = y;
			listener(event);
		}
	}

	var over = false;

	function _onMouseOut(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OUT;
		if (!this.eventMap.exists(type)) {
			return;
		}

		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;
		var event = new MouseEvent(type);
		event.screenX = x;
		event.screenY = y;
		var listener = this.eventMap[type];
		var hittest = this.hitTest(x, y);
		if (!hittest && over) {
			listener(event);
			over = false;
			if (!Cursor.lock && (this is InteractiveComponent)) {
				Cursor.setTo(CursorType.DEFAULT);
			}
		}

		// if (over) {
		// 	listener(event);
		// 	over = false;
		// }
	}

	function _onMouseOver(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OVER;
		if (!this.eventMap.exists(type)) {
			return;
		}

		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;

		var event = new MouseEvent(type);
		event.screenX = x;
		event.screenY = y;

		var listener = this.eventMap[type];
		var hittest = this.hitTest(x, y);
		if (hittest) {
			listener(event);
			over = true;
			if (style != null && style.cursor != null && (this is InteractiveComponent)) {
				Cursor.setTo(CursorType.fromString(style.cursor));
			}
		}
		// if (!over) {
		// 	this.over = true;
		// 	listener(event);
		// }
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

		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;

		var event = new MouseEvent(type);
		event.screenX = x;
		event.screenY = y;
		if (Cursor.lock) {
			Cursor.lock = false;
			if (!over) {
				Cursor.setTo(CursorType.DEFAULT);
			}
		}

		var listener = this.eventMap[type];
		if (this.hitTest(x, y) && !this.hasComponentOver(cast this, x, y)) {
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
		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;

		var event = new MouseEvent(type);
		event.screenX = x;
		event.screenY = y;

		var listener = this.eventMap[type];
		if (this.hitTest(x, y) && !this.hasComponentOver(cast this, x, y)) {
			Cursor.lock = true;
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
		root().screenToVisual(info.x, info.y, point);
		var x = point.x;
		var y = point.y;

		var event = new MouseEvent(type);
		event.screenX = x;
		event.screenY = y;
		event.shiftKey = App.app.input.keyPressed(LSHIFT) || App.app.input.keyPressed(RSHIFT);
		if (this.hitTest(x, y) && !this.hasComponentOver(cast this, x, y)) {
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
					// visual.onPointerOver(visual, this._onMouseOver);
					screen.onPointerMove(visual, this._onMouseOver);
				}
			case MouseEvent.MOUSE_OUT:
				if (!eventMap.exists(MouseEvent.MOUSE_OUT)) {
					this.eventMap.set(MouseEvent.MOUSE_OUT, listener);
					// visual.onPointerOut(visual, _onMouseOut);
					screen.onPointerMove(visual, _onMouseOut);
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
					screen.offPointerMove(_onMouseOver);
					eventMap.remove(MouseEvent.MOUSE_OVER);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT)) {
					screen.offPointerMove(_onMouseOut);
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
			this.add(_textDisplay.visual);
			// trace('${pad(this.id)}: create text diplay');
		}
		return _textDisplay;
	}

	public override function createTextInput(text:String = null):TextInput {
		if (_textInput == null) {
			super.createTextInput(text);
			this.add(_textInput.visual);
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
