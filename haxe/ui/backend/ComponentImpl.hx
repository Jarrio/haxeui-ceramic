package haxe.ui.backend;

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

	private override function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
		// if (left != null) {
		// 	this.visual.x = this.left = left;
		// }
		if (left == null || top == null || left < 0 || top < 0) {
			return;
		}
		// if (top != null) {
		// 	this.visual.y = this.top = top;
		// }
		if (this.x != left)
			this.x = this.left = left;
		if (this.y != top)
			this.y = this.top = top;

		// if (clipQuad != null) {
		// 	if (clipQuad.x != left) clipQuad.x = left;
		// 	if (clipQuad.y != top)  clipQuad.y = top;
		// }
		// trace('${pad(this.id)}: move -> ${left}x${top}');
	}

	private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		if (visual == null) {
			return;
		}

		if (width == null || height == null || width < 0 || height < 0) {
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
		if (value == null) {
			this.clipQuad = null;
		} else {
			if (this.clipQuad == null) {
				this.clipQuad = new Quad();
				this.clipQuad.visible = false;
				if (this.parentComponent != null) {
					this.parentComponent.visual.add(clipQuad);
				} else {
					this.visual.add(clipQuad);
				}
			}

			// this.clipQuad.x = value.left + visual.x - parentComponent.visual.x;
			// this.clipQuad.y = value.top;
			this.x = -value.left;
			this.y = -value.top;
			this.clipQuad.x = left;
			this.clipQuad.y = top;
			this.clipQuad.width = value.width;
			this.clipQuad.height = value.height;
			// trace('x: $x | y: $y | cx: $clipX | cy: $clipY |w: ${value.width} |h:${value.height}');
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
			visual.remove(_imageDisplay.visual);
			_imageDisplay.visual.destroy();
			_imageDisplay = null;
		}
	}

	//***********************************************************************************************************
	// Display tree
	//***********************************************************************************************************

	function getDepthIndex(child:Component) {
		var depth = 0.;
		var children = child.visual.children;
		if (children != null && children.length > 0) {
			depth = children[children.length - 1].depth;
		}
		return depth;
	}

	private override function handleAddComponent(child:Component):Component {
		// trace('${pad(this.id)}: add component -> ${child.id}');
		child.visual.depth = getDepthIndex(cast this) + 1;
		this.visual.add(child.visual);
		if (this.parentComponent == null && !this.addedRoot) {
			App.app.scenes.main.add(this.visual);
			this.addedRoot = true;
		}

		return child;
	}

	private override function handleAddComponentAt(child:Component, index:Int):Component {
		// trace('${pad(this.id)}: add component at index -> ${child.id}, ${index}');
		if (child.visual.children != null) {
			child.visual.depth = index;
		}

		this.visual.add(child.visual);
		return child;
	}

	private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		// trace('${pad(this.id)}: remove component -> ${child.id}');
		this.visual.remove(child.visual);
		if (dispose == true) {
			child.visual.dispose();
		}
		return child;
	}

	private override function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
		// trace('${pad(this.id)}: remove component at index -> ${index}');
		var child = this.visual.children[index];
		if (child != null) {
			visual.remove(child);

			if (dispose == true) {
				child.dispose();
			}
		}
		return null;
	}

	//***********************************************************************************************************
	// Style
	//***********************************************************************************************************
	private override function applyStyle(style:Style) {
		// trace('${pad(this.id)}: apply style ->');

		if (style.backgroundColor != null) {
			var alpha:Int = 0xFF000000;
			var bgcolor = style.backgroundColor;
			visual.color = (bgcolor);
			if (style.backgroundColorEnd != null && style.backgroundColor != style.backgroundColorEnd) {
				visual.colorMapping = VERTICES;

				var hend = style.backgroundColorEnd;
				var start = (bgcolor | alpha);
				var end = (hend | alpha);
				var type = "vertical";
				if (style.backgroundGradientStyle != null) {
					type = style.backgroundGradientStyle;
				}
				switch (type) {
					case "horizontal":
						visual.colors = [start, end, start, end];
					case "vertical" | _:
						visual.colors = [start, start, end, end];
				}
			} else {
				visual.colorMapping = MESH;
				if (style.backgroundOpacity != null) {
					visual.alpha = style.backgroundOpacity;
				}
			}
		}

		if (style.borderLeftSize != null && style.borderLeftSize != 0) {
			var line = this.leftBorder;
			line.color = style.borderLeftColor;
			line.thickness = style.borderLeftSize;
			line.points = [
				0,           0,
				0, visual.height
			];
			this.visual.add(line);
		}

		if (style.borderRightSize != null && style.borderRightSize != 0) {
			var line = this.rightBorder;

			line.color = style.borderRightColor;
			line.thickness = style.borderRightSize;
			line.points = [
				visual.width,           0,
				visual.width, visual.height
			];
			this.visual.add(line);
		}

		if (style.borderTopSize != null && style.borderTopSize != 0) {
			var line = this.topBorder;
			line.color = style.borderTopColor;
			line.thickness = style.borderTopSize;
			line.points = [
				           0, 0,
				visual.width, 0
			];
			this.visual.add(line);
		}

		if (style.borderBottomSize != null && style.borderBottomSize != 0) {
			var line = this.bottomBorder;
			line.color = style.borderBottomColor;
			line.thickness = style.borderBottomSize;
			line.points = [
				           0, visual.height,
				visual.width, visual.height
			];
			this.visual.add(line);
		}
	}

	//***********************************************************************************************************
	// Events
	//***********************************************************************************************************
	var eventCallbacks:Map<String, Entity> = [];

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		switch (type) {
			case MouseEvent.CLICK:
				if (eventMap.exists(MouseEvent.CLICK) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.CLICK;
					this.eventCallbacks.set(MouseEvent.CLICK, entity);
					visual.onPointerUp(entity, MouseHelper.onClick.bind(type, listener));
					eventMap.set(MouseEvent.CLICK, listener);
				}
			case MouseEvent.DBL_CLICK:
				if (eventMap.exists(MouseEvent.DBL_CLICK) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.DBL_CLICK;
					this.eventCallbacks.set(MouseEvent.DBL_CLICK, entity);
					visual.onPointerUp(entity, MouseHelper.onDoubleClick.bind(type, listener));
					eventMap.set(MouseEvent.DBL_CLICK, listener);
				}
			case MouseEvent.MOUSE_MOVE:
				if (eventMap.exists(MouseEvent.MOUSE_MOVE) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_MOVE;
					this.eventCallbacks.set(MouseEvent.MOUSE_MOVE, entity);
					screen.onPointerMove(entity, MouseHelper.onMouseMove.bind(type, listener));
					eventMap.set(MouseEvent.MOUSE_MOVE, listener);
				}
			case MouseEvent.MOUSE_OVER:
				if (eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_OVER;
					this.eventCallbacks.set(MouseEvent.MOUSE_OVER, entity);
					visual.onPointerOver(entity, MouseHelper.onMouseOver.bind(type, listener));
					eventMap.set(MouseEvent.MOUSE_OVER, listener);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_OUT;
					this.eventCallbacks.set(MouseEvent.MOUSE_OUT, entity);
					visual.onPointerOut(entity, MouseHelper.onMouseOut.bind(type, listener));
					eventMap.set(MouseEvent.MOUSE_OUT, listener);
				}
			case MouseEvent.MOUSE_UP:
				if (eventMap.exists(MouseEvent.MOUSE_UP) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_UP;
					this.eventCallbacks.set(MouseEvent.MOUSE_UP, entity);
					visual.onPointerUp(entity, MouseHelper.onMouseButton.bind(type, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_UP, listener);
				}
			case MouseEvent.MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_DOWN;
					this.eventCallbacks.set(MouseEvent.MOUSE_DOWN, entity);
					visual.onPointerDown(entity, MouseHelper.onMouseButton.bind(type, LEFT, listener));
					eventMap.set(MouseEvent.MOUSE_DOWN, listener);
				}
			case MouseEvent.RIGHT_MOUSE_UP:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_UP) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.RIGHT_MOUSE_UP;
					this.eventCallbacks.set(MouseEvent.RIGHT_MOUSE_UP, entity);
					visual.onPointerUp(entity, MouseHelper.onMouseButton.bind(type, RIGHT, listener));
					eventMap.set(MouseEvent.RIGHT_MOUSE_UP, listener);
				}
			case MouseEvent.RIGHT_MOUSE_DOWN:
				if (eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.RIGHT_MOUSE_DOWN;
					this.eventCallbacks.set(MouseEvent.RIGHT_MOUSE_DOWN, entity);
					visual.onPointerDown(entity, MouseHelper.onMouseButton.bind(type, RIGHT, listener));
					eventMap.set(MouseEvent.RIGHT_MOUSE_DOWN, listener);
				}
			case MouseEvent.MOUSE_WHEEL:
				if (eventMap.exists(MouseEvent.MOUSE_WHEEL) == false) {
					var entity = new Entity();
					entity.id = MouseEvent.MOUSE_WHEEL;
					screen.onMouseWheel(visual, MouseHelper.onMouseWheel.bind(cast this, type, listener));
					this.eventCallbacks.set(MouseEvent.MOUSE_WHEEL, entity);
					eventMap.set(MouseEvent.MOUSE_WHEEL, listener);
				}
			default:
		}

		trace('${pad(this.id)}: map event -> ${type}');
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
			this.visual.add(_textDisplay.visual);
			trace('${pad(this.id)}: create text diplay');
		}
		return _textDisplay;
	}

	public override function createTextInput(text:String = null):TextInput {
		if (_textInput == null) {
			super.createTextInput(text);
			visual.add(_textInput.visual);
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
