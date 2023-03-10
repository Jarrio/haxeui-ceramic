package haxe.ui.backend;

import haxe.ui.core.Screen;
import ceramic.MeshExtensions;
import ceramic.AlphaColor;
import ceramic.Mesh;
import haxe.ui.backend.ceramic.MouseHelper;
import ceramic.Color;
import ceramic.Entity;
import haxe.ui.geom.Rectangle;
import ceramic.TouchInfo;
import haxe.ui.core.TextInput;
import haxe.ui.core.ImageDisplay;
import ceramic.Quad;
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
		//recursiveReady();
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

		if (this.x != left) {
			this.x = left;
			if (this.isClipped) {
				this.filter.x = left;
			}
		}

		if (this.y != top) {
			this.y = top;
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
			visual.vertices = [
				    0,      0,
				width,      0,
				    0, height,
				width, height
			];

			visual.indices = [
				0, 1, 3,
				0, 2, 3
			];
			visual.width = width;
			visual.height = height;

		}
		applyStyle(style);
		// trace('${pad(this.id)}: size -> ${width}x${height}');
	}

	override function handleClipRect(value:Rectangle):Void {
		//return;
		if (value == null) {
				if (this.parentComponent.isClipped) {
					this.parentComponent.filter.content.remove(filter);
				} else {
					this.parentComponent.visual.remove(filter);
				}
				filter.dispose();
				this.isClipped = false;
				this.filter = null;
		} else {
			if (this.filter == null) {
				this.filter = new ceramic.Filter();
				filter.antialiasing = aliasing();
				if (this.parentComponent.isClipped) {
					this.parentComponent.filter.content.add(filter);
				} else {
					this.parentComponent.visual.add(filter);
				}
				this.isClipped = true;
				//this.parentComponent.visual.remove(this.visual);
				filter.content.add(this.visual);
			}
			//filter.color = Color.BLACK;
			this.x = -value.left;
			this.y = -value.top;
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
		trace('${pad(this.id)}: remove component at index -> ${index}');
		return this.handleRemoveComponent(this.childComponents[index], dispose);
	}

	//***********************************************************************************************************
	// Style
	//***********************************************************************************************************
	private override function applyStyle(style:Style) {
		// trace('${pad(this.id)}: apply style ->');
		if (style.opacity != null) {
			visual.alpha = style.opacity;
		}

//		trace(style.backgroundColor);

		if (style.backgroundColor != null) {
			background.color = style.backgroundColor;
			MeshExtensions.createQuad(background, this.visual.width, this.visual.height);
			
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

		if (style.borderLeftSize != null) {
			var line = this.leftBorder;
			if (style.borderOpacity != null) {
				line.alpha = style.borderOpacity;
			}

			line.color = style.borderLeftColor;
			line.thickness = style.borderLeftSize;

			var x = (line.thickness / 2);
			line.points = [
				x, 0,
				x, visual.height
			];
		}

		if (style.borderRightSize != null) {
			var line = this.rightBorder;
			if (style.borderOpacity != null) {
				line.alpha = style.borderOpacity;
			}
			line.color = style.borderRightColor;
			line.thickness = style.borderRightSize;
			var x = (line.thickness / 2);
			line.points = [
				visual.width - x, 0,
				visual.width - x, visual.height
			];
		}

		if (style.borderTopSize != null) {
			var line = this.topBorder;
			if (style.borderOpacity != null) {
				line.alpha = style.borderOpacity;
			}
			line.color = style.borderTopColor;
			line.thickness = style.borderTopSize;

			var y = (line.thickness / 2);
			line.points = [
				line.thickness, y,
				visual.width - line.thickness, y
			];
		}

		if (style.borderBottomSize != null) {
			var line = this.bottomBorder;
			if (style.borderOpacity != null) {
				line.alpha = style.borderOpacity;
			}

			line.color = style.borderBottomColor;
			line.thickness = style.borderBottomSize;

			var y = (line.thickness / 2);
			line.points = [
				line.thickness, visual.height - y,
				visual.width - line.thickness, visual.height - y
			];
		}
	}

	public function checkRedispatch(type:String, event:MouseEvent) {
		//trace(type);
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
	var eventCallbacks:Map<String, Entity> = [];

	function onLeftMouseClick(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.CLICK)) {
			return;
		}
		this.onMouseClick(MouseEvent.CLICK, info);
	}

	function onRightMouseClick(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.RIGHT_CLICK)) {
			return;
		}
		this.onMouseClick(MouseEvent.RIGHT_CLICK, info);
	}

	function onMouseClick(type, info:TouchInfo) {
		var listener = this.eventMap[type];
		var type = MouseEvent.CLICK;
		var event = new MouseEvent(type);
		event.type = type;
		event.screenX = info.x;
		event.screenY = info.y;

		if (this.parentComponent != null) {
			this.parentComponent.checkRedispatch(type, event);
		}
		
		listener(event);
	}

	function onLeftMouseDown(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
			return;
		}
		onMouseButton(MouseEvent.MOUSE_DOWN, info);
	}

	function onLeftMouseUp(info:TouchInfo) {
		if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
			return;
		}	
		onMouseButton(MouseEvent.MOUSE_UP, info);
	}

	function onRightMouseDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onMouseButton(MouseEvent.RIGHT_MOUSE_DOWN, info);
	}

	function onRightMouseUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onMouseButton(MouseEvent.RIGHT_MOUSE_UP, info);
	}

	function onMouseButton(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type)) {
			return;
		}
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		event.data = info.buttonId;
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_DOWN:
				event.buttonDown = true;
			default:
		}

		if (this.parentComponent != null) {
			this.parentComponent.checkRedispatch(type, event);
		}
		
		this.eventMap[type](event);
	}

	    private function hasComponentOver(ref:Component, x:Float, y:Float):Bool {
        var array:Array<Component> = getComponentsAtPoint(x, y);
        if (array.length == 0) {
            return false;
        }

        return !hasChildRecursive(cast ref, cast array[array.length - 1]);
    }

    private function getComponentsAtPoint(x:Float, y:Float):Array<Component> {
        var array:Array<Component> = new Array<Component>();
        for (r in Screen.instance.rootComponents) {
            findChildrenAtPoint(r, x, y, array);
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
		/**
		 * mouse move
		 */
		
		var type = MouseEvent.MOUSE_MOVE;
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		if (eventMap.exists(type)) {
			//eventMap[type](event);	
		}
		
		/**
		 * mouse over
		 */
		var listener = null;
		if (this.hitTest(info.x, info.y) && !over) {
			if (this.hasComponentOver(cast this, info.x, info.y)) {
				return;
			}
			over = true;
			var event = new MouseEvent(MouseEvent.MOUSE_OVER);
			event.screenX = info.x;
			event.screenY = info.y;

			listener = eventMap.get(MouseEvent.MOUSE_OVER);
			if (listener != null) {
				listener(event);	
			}
		} else if (!this.hitTest(info.x, info.y) && over) {
			over = false;
			var event = new MouseEvent(MouseEvent.MOUSE_OUT);
			event.screenX = info.x;
			event.screenY = info.y;
			
			listener = eventMap.get(MouseEvent.MOUSE_OUT);
			if (listener != null) {
				listener(event);	
			}
		}
	}
	var over = false;
	function onCeramicOut(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OUT;
		if (!this.eventMap.exists(type)) {
			return;
		}
		
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		
		if (over && !this.hitTest(info.x, info.y)) {
			listener(event);
			over = false;
		}
	}

	function onCeramicOver(info:TouchInfo) {
		var type = MouseEvent.MOUSE_OVER;
		if (!this.eventMap.exists(type)) {
			return;
		}
		
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		if (this.hitTest(info.x, info.y)) {
			listener(event);
			this.over = true;
		}
	}

	function onCeramicLeftUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		onCeramicUp(MouseEvent.MOUSE_UP, info);
	}
	
	function onCeramicRightUp(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onCeramicUp(MouseEvent.RIGHT_MOUSE_UP, info);
	}

	function onCeramicUp(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type) || this.hasComponentOver(cast this, info.x, info.y)) {
			return;
		}
		
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		if (this.hitTest(info.x, info.y)) {
			listener(event);
		}
	}

	function onCeramicLeftDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		onCeramicDown(MouseEvent.MOUSE_DOWN, info);
	}

	function onCeramicRightDown(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onCeramicDown(MouseEvent.RIGHT_MOUSE_DOWN, info);
	}

	function onCeramicDown(type:String, info:TouchInfo) {
		if (!this.eventMap.exists(type) || this.hasComponentOver(cast this, info.x, info.y)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var listener = this.eventMap[type];
		if (this.hitTest(info.x, info.y)) {
			listener(event);
		}
	}

	function onCeramicLeftClick(info:TouchInfo) {
		if (info.buttonId != MouseButton.LEFT) {
			return;
		}
		onCeramicClick(MouseEvent.CLICK, info);
	}

	function onCeramicRightClick(info:TouchInfo) {
		if (info.buttonId != MouseButton.RIGHT) {
			return;
		}
		onCeramicClick(MouseEvent.RIGHT_CLICK, info);
	}

	function onCeramicClick(type:String, info:TouchInfo) {
		var type = MouseEvent.CLICK;
		if (!this.eventMap.exists(type) || this.hasComponentOver(cast this, info.x, info.y)) {
			return;
		}

		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;
		if (this.hitTest(info.x, info.y)) {
			this.eventMap[type](event);
		}
	}

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;

		switch (type) {
			case MouseEvent.CLICK:
				if (!eventMap.exists(MouseEvent.CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onCeramicLeftClick);
				}
			case MouseEvent.RIGHT_CLICK:
				if (!eventMap.exists(MouseEvent.RIGHT_CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onCeramicRightClick);
				}
			case MouseEvent.DBL_CLICK:
				if (!eventMap.exists(MouseEvent.DBL_CLICK)) {
					this.eventMap.set(type, listener);
					//visual.onPointerUp(visual, MouseHelper.onDoubleClick.bind(type, listener));
				}
			case MouseEvent.MOUSE_MOVE:
				if (!eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					this.eventMap.set(type, listener);
					screen.onPointerMove(visual, this.onMouseMove);
				}
			case MouseEvent.MOUSE_OVER:
				if (!eventMap.exists(MouseEvent.MOUSE_OVER)) {
					screen.onPointerMove(visual, this.onMouseMove);
					this.eventMap.set(type, listener);
				//	screen.onPointerMove(visual, this.onCeramicOver);
					//visual.onPointerOver(visual, this._onMouseOver);
				}
			case MouseEvent.MOUSE_OUT:
				if (!eventMap.exists(MouseEvent.MOUSE_OUT)) {
					this.eventMap.set(type, listener);
					//screen.onPointerMove(visual, this.onCeramicOut);
					//visual.onPointerOut(visual, this._onMouseOut);
				}
			case MouseEvent.MOUSE_UP:
				if (!eventMap.exists(MouseEvent.MOUSE_UP)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onCeramicLeftUp);
					//visual.onPointerUp(visual, this.onLeftMouseUp);
				}
			case MouseEvent.MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					this.eventMap.set(type, listener);
					screen.onPointerDown(visual, this.onCeramicLeftDown);
					//visual.onPointerDown(visual, this.onLeftMouseDown);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onCeramicRightUp);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (!eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					this.eventMap.set(type, listener);
					screen.onPointerDown(visual, this.onCeramicRightDown);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (!eventMap.exists(MouseEvent.MOUSE_WHEEL)) {
					this.eventMap.set(type, listener);
					//screen.onMouseWheel(visual, this.onMouseWheel);
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
					screen.offPointerUp(onCeramicLeftClick);
					eventMap.remove(MouseEvent.CLICK);
				}
			case MouseEvent.RIGHT_CLICK:
				if (eventMap.exists(MouseEvent.RIGHT_CLICK)) {
					screen.offPointerUp(onCeramicRightClick);
					eventMap.remove(MouseEvent.RIGHT_CLICK);
				}
			case MouseEvent.DBL_CLICK:
				if (eventMap.exists(MouseEvent.DBL_CLICK)) {
					eventMap.remove(MouseEvent.DBL_CLICK);
				}
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					screen.offPointerMove(onMouseMove);
					eventMap.remove(MouseEvent.MOUSE_MOVE);
				}
			case MouseEvent.MOUSE_OVER:
				if (eventMap.exists(MouseEvent.MOUSE_OVER)) {
					screen.offPointerMove(onMouseMove);
					eventMap.remove(MouseEvent.MOUSE_OVER);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT)) {
					//visual.offPointerOut(onCeramicOut);
					//screen.offPointerMove(onCeramicOut);
					eventMap.remove(MouseEvent.MOUSE_OUT);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP)) {
					screen.offPointerUp(onCeramicLeftUp);
					eventMap.remove(MouseEvent.MOUSE_UP);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					screen.offPointerUp(onCeramicLeftDown);
					eventMap.remove(MouseEvent.MOUSE_DOWN);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					screen.offPointerUp(onCeramicRightUp);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_UP);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					screen.offPointerUp(onCeramicRightDown);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_DOWN);
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
			//_textDisplay.visual.touchable = false;
			this.visual.add(_textDisplay.visual);
			//trace('${pad(this.id)}: create text diplay');
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