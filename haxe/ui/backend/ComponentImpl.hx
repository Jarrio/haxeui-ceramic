package haxe.ui.backend;

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
			applyStyle(style);
		}
		// trace('${pad(this.id)}: size -> ${width}x${height}');
	}

	override function handleClipRect(value:Rectangle):Void {
		//return;
		if (value == null) {
			this.isClipped = false;
			this.filter = null;
		} else {
			if (this.filter == null) {
				this.filter = new ceramic.Filter();
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
		if (show != this.visible) {
			this.visible = show;
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
			// if (c.hasTextDisplay()) {
			// 	var l = c.visual.children.length;
			// 	c.visual.depth = l + 2;
			// }

			// if (c.hasImageDisplay()) {
			// 	var l = c.visual.children.length;
			// 	c.visual.depth = l + 1;
			// }
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
		trace('${pad(this.id)}: add component at index -> ${child.id}, ${index}');
		child.visual.active = true;
		child.visual.depth = index;
		//child.visual.depth = index
		//this.childComponents.

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
		//var child = this.visual.children[index];
		//this.mapChildren();
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

		if (style.backgroundColor != null) {
			MeshExtensions.createQuad(background, this.visual.width, this.visual.height);
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

			//this.visual.add(this.background);
		}

		if (style.borderLeftSize != null && style.borderLeftSize != 0) {
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
			//this.visual.add(line);
		}

		if (style.borderRightSize != null && style.borderRightSize != 0) {
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
			this.visual.add(line);
		}

		if (style.borderTopSize != null && style.borderTopSize != 0) {
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
			this.visual.add(line);
		}

		if (style.borderBottomSize != null && style.borderBottomSize != 0) {
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

			this.visual.add(line);
		}
	}

	public function checkRedispatch(type:String, event:MouseEvent) {
		if (this.hasEvent(type) && this.hitTest(event.screenX, event.screenY)) {
			dispatch(event);
		}

		if (parentComponent != null) {
			parentComponent.checkRedispatch(type, event);
		}
	}

	//***********************************************************************************************************
	// Events
	//***********************************************************************************************************
	var eventCallbacks:Map<String, Entity> = [];

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		var entity = new Entity();
		entity.id = type;
		this.eventCallbacks.set(type, entity);
		//this.eventMap.set(type, listener);

		switch (type) {
			case MouseEvent.CLICK:
				if (eventMap.exists(MouseEvent.CLICK) == false) {
					visual.onPointerUp(entity, MouseHelper.onClick.bind(cast this, type, listener));
					eventMap.set(MouseEvent.CLICK, listener);
				}
			case MouseEvent.DBL_CLICK:
				if (eventMap.exists(MouseEvent.DBL_CLICK) == false) {
					visual.onPointerUp(entity, MouseHelper.onDoubleClick.bind(cast this, type, listener));
					eventMap.set(MouseEvent.DBL_CLICK, listener);
				}
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE) == false) {
					screen.onPointerMove(entity, MouseHelper.onMouseMove.bind(cast this, type, listener));
					eventMap.set(MouseEvent.MOUSE_MOVE, listener);
				}
			case MouseEvent.MOUSE_OVER:
				if (eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
					visual.onPointerOver(entity, MouseHelper.onMouseOver.bind(cast this, type, listener));
					eventMap.set(MouseEvent.MOUSE_OVER, listener);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
					visual.onPointerOut(entity, MouseHelper.onMouseOut.bind(cast this, type, listener));
					eventMap.set(MouseEvent.MOUSE_OUT, listener);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP) == false) {
					visual.onPointerUp(entity, MouseHelper.onMouseUp.bind(cast this, MouseEvent.MOUSE_UP, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_UP, listener);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
					visual.onPointerDown(entity, MouseHelper.onMouseDown.bind(cast this, MouseEvent.MOUSE_DOWN, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_DOWN, listener);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP) == false) {
					visual.onPointerUp(entity, MouseHelper.onMouseUp.bind(cast this, type, RIGHT, listener));
					eventMap.set(MouseEvent.RIGHT_MOUSE_UP, listener);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN) == false) {
					visual.onPointerDown(entity, MouseHelper.onMouseDown.bind(cast this, type, RIGHT, listener));
					eventMap.set(MouseEvent.RIGHT_MOUSE_DOWN, listener);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (eventMap.exists(MouseEvent.MOUSE_WHEEL) == false) {
					screen.onMouseWheel(visual, MouseHelper.onMouseWheel.bind(cast this, type, listener));
					eventMap.set(MouseEvent.MOUSE_WHEEL, listener);
				}
			default:
		}
		Toolkit.callLater(function() {
			trace(this.id, type, cast(this, Component).className);
		});
//		trace('${pad(this.id)}: map event -> ${type}');
	}

	private override function unmapEvent(type:String, listener:UIEvent->Void) {
		switch (type) {
			case MouseEvent.CLICK:
				if (eventMap.exists(MouseEvent.CLICK)) {
					this.eventCallbacks.get(MouseEvent.CLICK).destroy();
					this.eventCallbacks.remove(MouseEvent.CLICK);
					eventMap.remove(MouseEvent.CLICK);
				}
			case MouseEvent.DBL_CLICK:
				if (eventMap.exists(MouseEvent.DBL_CLICK)) {
					this.eventCallbacks.get(MouseEvent.DBL_CLICK).destroy();
					this.eventCallbacks.remove(MouseEvent.DBL_CLICK);
					eventMap.remove(MouseEvent.DBL_CLICK);
				}
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_MOVE).destroy();
					this.eventCallbacks.remove(MouseEvent.MOUSE_MOVE);
					eventMap.remove(MouseEvent.MOUSE_MOVE);
				}
			case MouseEvent.MOUSE_OVER:
				if (eventMap.exists(MouseEvent.MOUSE_OVER)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_OVER).destroy();
					this.eventCallbacks.remove(MouseEvent.MOUSE_OVER);
					eventMap.remove(MouseEvent.MOUSE_OVER);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_OUT).destroy();
					this.eventCallbacks.remove(MouseEvent.MOUSE_OUT);
					eventMap.remove(MouseEvent.MOUSE_OUT);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_UP).destroy();
					this.eventCallbacks.remove(MouseEvent.MOUSE_UP);
					eventMap.remove(MouseEvent.MOUSE_UP);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN)) {
					this.eventCallbacks.get(MouseEvent.MOUSE_DOWN).destroy();
					this.eventCallbacks.remove(MouseEvent.MOUSE_DOWN);
					eventMap.remove(MouseEvent.MOUSE_DOWN);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP)) {
					this.eventCallbacks.get(MouseEvent.RIGHT_MOUSE_UP).destroy();
					this.eventCallbacks.remove(MouseEvent.RIGHT_MOUSE_UP);
					eventMap.remove(MouseEvent.RIGHT_MOUSE_UP);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN)) {
					this.eventCallbacks.get(MouseEvent.RIGHT_MOUSE_DOWN).destroy();
					this.eventCallbacks.remove(MouseEvent.RIGHT_MOUSE_DOWN);
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
			_textDisplay.visual.active = true;
			this.add(_textDisplay.visual);
			//trace('${pad(this.id)}: create text diplay');
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