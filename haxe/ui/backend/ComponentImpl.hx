package haxe.ui.backend;

import haxe.ui.backend.ceramic.Base.BGType;
import haxe.ui.backend.ceramic.RoundedBorder;
import ceramic.Texture;
import haxe.ui.assets.ImageInfo;
import haxe.ui.loaders.image.ImageLoader;
import ceramic.Color;
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
import ceramic.Point;
import ceramic.Timer;
import ceramic.Filter;
import haxe.ui.backend.ceramic.CursorType;
import haxe.ui.backend.ceramic.Cursor;
import ceramic.TextureTile;

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
		#if filter_root
		Ceramic.forceRender();
		#end
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
		var x = Math.round(left);
		var y = Math.round(top);

		if (this.isClipped) {
			this.filter.x = x;
		} else {
			this.visual.x = x;
		}

		if (this.isClipped) {
			this.filter.y = y;
		} else {
			this.visual.y = y;
		}
	}

	private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		static var sizeChanged = false;

		if (visual == null) {
			return;
		}

		sizeChanged = false;

		var w = Math.round(width);
		var h = Math.round(height);

		if (h > 0 && h != visual.height) {
			sizeChanged = true;
		}

		if (w > 0 && w != visual.width) {
			sizeChanged = true;
		}

		if (sizeChanged) {
			visual.width = w;
			visual.height = h;

			if (style != null) {
				applyStyle(style);
			}

			this.updateRender();
		}
	}

	// private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
	// 	if (visual == null) {
	// 		return;
	// 	}
	// 	var w = Math.round(width);
	// 	var h = Math.round(height);
	// 	if (visual.width != w || visual.height != h) {
	// 		if (style != null) {
	// 			applyStyle(style);
	// 		}
	// 	}
	// 	if (h > 0 && h != visual.height) {
	// 		this.visual.height = h;
	// 	}
	// 	if (w > 0 && w != visual.width) {
	// 		this.visual.width = w;
	// 	}
	// 	this.updateRender();
	// }
	var v = false;

	override function handleClipRect(value:Rectangle):Void {
		// @TODO fix clipping with absolute/box
		if (this.parentComponent == null) {
			return;
		}

		var parent = this.parentComponent;

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

				filter.depth = visual.depth + 0.01;

				if (parent == null) {
					visual.parent.add(filter);
				} else if (parent.isClipped) {
					parent.filter.content.add(filter);
				} else {
					parent.visual.add(filter);
				}

				if (this.visual.getBorder() != null) {}

				this.isClipped = true;
				filter.content.add(this.visual);
			}

			var l = (left);
			var t = (top);
			var lr = (value.left);
			var tr = (value.top);
			var w = (value.width);
			var h = (value.height);

			this.visual.x = -lr;
			this.visual.y = -tr;
			this.filter.x = l;
			this.filter.y = t;
			this.filter.width = w;
			this.filter.height = h;
		}

		this.updateRender();
	}

	private override function handleVisibility(show:Bool):Void {
		super.handleVisibility(show);
		if (show != this.visual.visible) {
			this.visual.active = show;
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
			visual.add(_imageDisplay.visual);
		}

		return _imageDisplay;
	}

	public override function removeImageDisplay():Void {
		if (_imageDisplay != null) {
			_imageDisplay.visual.dispose();
			_imageDisplay = null;
		}
	}

	//***********************************************************************************************************
	// Display tree
	//***********************************************************************************************************

	inline function mapChildren() {
		// var components = this.childComponents.copy();
		// components.sort((a, b) -> Std.int(a.visual.depth - b.visual.depth));

		// for (i in 0...components.length) {
		// 	components[i].visual.depth = i + 2;
		// }

		// visual.sortChildrenByDepth();
	}

	var depth_counter = 0;

	private override function handleSetComponentIndex(child:Component, index:Int) {
		child.visual.depth = index + 2;
		mapChildren();
	}

	private override function handleAddComponent(child:Component):Component {
		child.visual.depth = depth_counter + 2;
		depth_counter++;
		this.addInternal(child.visual);
		mapChildren();
		return child;
	}

	private override function handleAddComponentAt(child:Component, index:Int):Component {
		child.visual.depth = index + 2;
		handleAddComponent(child);
		mapChildren();
		return child;
	}

	private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		depth_counter--;
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
		if (style == null)
			return;

		determineVisualType(style);

		applyBorderStyles(style);

		applyBackgroundStyles(style);

		if (style.backgroundImage != null) {
			if (visual.bgType == NINESLICE) {
				applyNineSliceBackground(style);
			} else {
				addBgImage(style);
			}
		}

		if (style.filter != null && style.filter.length > 0) {
			for (f in style.filter) {
				if (f is haxe.ui.filters.Tint) {
					var tint = cast(f, haxe.ui.filters.Tint);
					if (this._imageDisplay != null) {
						this._imageDisplay.visual.color = tint.color;
					} else if (visual.bgImage != null) {
						visual.bgImage.color = tint.color;
					}
				}
			}
		}

		this.updateRender();
	}

	private function applyBorderStyles(style:Style) {
		if (style.opacity != null) {
			visual.alpha = style.opacity;
		}

		if (visual.bgType == ROUNDED) {
			applyRoundedBorderStyles(style);
		} else if (visual.borderType == RECTANGLE && visual.border != null) {
			applyRectangleBorderStyles(style);
		}
	}

	private function determineRoundedBorderType(style:Style):StyleBorderType {
		var hasLeft = style.borderLeftSize != null && style.borderLeftSize > 0;
		var hasRight = style.borderRightSize != null && style.borderRightSize > 0;
		var hasTop = style.borderTopSize != null && style.borderTopSize > 0;
		var hasBottom = style.borderBottomSize != null && style.borderBottomSize > 0;

		var hasUniformBorder = style.borderSize != null && style.borderSize > 0;

		var hasAnySide = hasLeft || hasRight || hasTop || hasBottom;

		var allSameSize = hasLeft
			&& hasRight
			&& hasTop
			&& hasBottom
			&& style.borderLeftSize == style.borderRightSize
			&& style.borderLeftSize == style.borderTopSize
			&& style.borderLeftSize == style.borderBottomSize;

		var allSameColor = style.borderLeftColor == style.borderRightColor
			&& style.borderLeftColor == style.borderTopColor
			&& style.borderLeftColor == style.borderBottomColor;

		var hasSpecificRadii = style.borderRadiusTopLeft != null
			|| style.borderRadiusTopRight != null
			|| style.borderRadiusBottomLeft != null
			|| style.borderRadiusBottomRight != null;

		if (hasSpecificRadii) {
			var allRadiiSame = style.borderRadiusTopLeft != null
				&& style.borderRadiusTopRight != null
				&& style.borderRadiusBottomLeft != null
				&& style.borderRadiusBottomRight != null
				&& style.borderRadiusTopLeft == style.borderRadiusTopRight
				&& style.borderRadiusTopLeft == style.borderRadiusBottomLeft
				&& style.borderRadiusTopLeft == style.borderRadiusBottomRight;

			if (!allRadiiSame) {
				return StyleBorderType.Compound;
			}
		}

		if (hasUniformBorder || (allSameSize && allSameColor && !hasSpecificRadii)) {
			return StyleBorderType.Full;
		} else if (hasAnySide) {
			return StyleBorderType.Compound;
		} else {
			return StyleBorderType.None;
		}
	}

	private function applyRoundedBorderStyles(style:Style) {
		var bg = visual.rounded;
		var border = visual.roundedBorder;

		if (border == null) {
			return;
		}

		var isCircular = false;
		if (style.borderRadius != null) {
			var radiusPercent = style.borderRadius / Math.min(width, height);
			isCircular = radiusPercent >= 0.45; // Close to 50% just a guesstimate
		}


		var type = determineRoundedBorderType(style);
		switch (type) {
			case Full:
				border.radius = style.borderRadius;

				border.setAllBorders(style.borderRadius, style.borderSize, style.borderColor);
			case Compound:
				if (style.borderRadiusTopLeft != null && style.borderRadiusTopLeft > 0) {
					border.topLeft = style.borderRadiusTopLeft;
				}
				if (style.borderRadiusTopRight != null && style.borderRadiusTopRight > 0) {
					border.topRight = style.borderRadiusTopRight;
				}
				if (style.borderRadiusBottomLeft != null && style.borderRadiusBottomLeft > 0) {
					border.bottomLeft = style.borderRadiusBottomLeft;
				}
				if (style.borderRadiusBottomRight != null && style.borderRadiusBottomRight > 0) {
					border.bottomRight = style.borderRadiusBottomRight;
				}

				var hasTop = style.borderTopSize != null && style.borderTopSize > 0;
				var hasRight = style.borderRightSize != null && style.borderRightSize > 0;
				var hasBottom = style.borderBottomSize != null && style.borderBottomSize > 0;
				var hasLeft = style.borderLeftSize != null && style.borderLeftSize > 0;

				var circularBorderHandled = false;

				if (isCircular) {
					if ((hasLeft || hasRight) && !(hasTop || hasBottom)) {
						var thickness = hasLeft ? style.borderLeftSize : style.borderRightSize;
						var color = hasLeft ? style.borderLeftColor : style.borderRightColor;

						border.setAllBorders(style.borderRadius, thickness, color);

						border.setBorderSideVisible(BorderSide.TOP, false);
						border.setBorderSideVisible(BorderSide.BOTTOM, false);
						border.setBorderSideVisible(BorderSide.LEFT, hasLeft);
						border.setBorderSideVisible(BorderSide.RIGHT, hasRight);

						circularBorderHandled = true;
					} else if ((hasTop || hasBottom) && !(hasLeft || hasRight)) {
						var thickness = hasTop ? style.borderTopSize : style.borderBottomSize;
						var color = hasTop ? style.borderTopColor : style.borderBottomColor;

						border.setAllBorders(style.borderRadius, thickness, color);

						border.setBorderSideVisible(BorderSide.TOP, hasTop);
						border.setBorderSideVisible(BorderSide.BOTTOM, hasBottom);
						border.setBorderSideVisible(BorderSide.LEFT, false);
						border.setBorderSideVisible(BorderSide.RIGHT, false);

						circularBorderHandled = true;
					}
				}

				if (!circularBorderHandled) {
					border.setBorderSideVisible(BorderSide.TOP, hasTop);
					if (hasTop) {
						border.setBorderSideThickness(BorderSide.TOP, style.borderTopSize);
						if (style.borderTopColor != null) {
							border.setBorderSideColor(BorderSide.TOP, style.borderTopColor);
						}
					}

					border.setBorderSideVisible(BorderSide.RIGHT, hasRight);
					if (hasRight) {
						border.setBorderSideThickness(BorderSide.RIGHT, style.borderRightSize);
						if (style.borderRightColor != null) {
							border.setBorderSideColor(BorderSide.RIGHT, style.borderRightColor);
						}
					}

					border.setBorderSideVisible(BorderSide.BOTTOM, hasBottom);
					if (hasBottom) {
						border.setBorderSideThickness(BorderSide.BOTTOM, style.borderBottomSize);
						if (style.borderBottomColor != null) {
							border.setBorderSideColor(BorderSide.BOTTOM, style.borderBottomColor);
						}
					}

					border.setBorderSideVisible(BorderSide.LEFT, hasLeft);
					if (hasLeft) {
						border.setBorderSideThickness(BorderSide.LEFT, style.borderLeftSize);
						if (style.borderLeftColor != null) {
							border.setBorderSideColor(BorderSide.LEFT, style.borderLeftColor);
						}
					}
				}
			case None:
				border.setAllBorders(0, 0, Color.NONE);
		}

		if (bg != null) {
			if (style.borderRadius != null) {
				bg.color = style.backgroundColor;
				bg.radius = style.borderRadius;
			} else {
				if (style.borderRadiusTopLeft != null)
					bg.topLeft = style.borderRadiusTopLeft;
				if (style.borderRadiusTopRight != null)
					bg.topRight = style.borderRadiusTopRight;
				if (style.borderRadiusBottomLeft != null)
					bg.bottomLeft = style.borderRadiusBottomLeft;
				if (style.borderRadiusBottomRight != null)
					bg.bottomRight = style.borderRadiusBottomRight;
			}
		}

		if (style.borderOpacity != null) {
			bg.alpha = style.backgroundOpacity;
			border.alpha = style.borderOpacity;
		}

		border.rebuild();
	}

	private function applyBackgroundStyles(style:Style) {
		if (style.backgroundOpacity != null) {
			visual.bgAlpha = style.backgroundOpacity;
		} else {
			visual.bgAlpha = 1;
		}

		if (visual.bgType == NINESLICE)
			return;

		if (style.backgroundColor != null) {
			if (style.backgroundColorEnd != null) {
				applyGradient(style);
			} else if (visual.solid != null) {
				visual.solid.color = style.backgroundColor;
			} else if (visual.bgType == ROUNDED || visual.bgType == GRADIENT) {
				var bg = (visual.bgType == ROUNDED) ? visual.rounded : visual.gradient;
				bg.colorMapping = MESH;
				bg.color = style.backgroundColor;
			}
		} else {
			visual.bgAlpha = 0;
		}
	}

	private function applyNineSliceBackground(style:Style) {
		if (visual == null || visual.slice == null || !visual.active) {
			return;
		}

		var hasSlice = style.backgroundImageSliceTop != null
			|| style.backgroundImageSliceLeft != null
			|| style.backgroundImageSliceBottom != null
			|| style.backgroundImageSliceRight != null;

		var hasTile = style.backgroundImageClipTop != null
			&& style.backgroundImageClipLeft != null
			&& style.backgroundImageClipBottom != null
			&& style.backgroundImageClipRight != null;

		ImageLoader.instance.load(style.backgroundImage, function(image:ImageInfo) {
			if (visual == null || visual.slice == null || !visual.active) {
				return;
			}

			if (image == null) {
				trace(
					'[haxeui-ceramic] image ${style.backgroundImage} could not be loaded'
				);
				return;
			}

			try {
				var texture = image.data;

				if (hasTile) {
					var clipLeft = style.backgroundImageClipLeft;
					var clipTop = style.backgroundImageClipTop;
					var clipRight = style.backgroundImageClipRight;
					var clipBottom = style.backgroundImageClipBottom;

					var clipWidth = clipRight - clipLeft;
					var clipHeight = clipBottom - clipTop;

					var newTile = new TextureTile(texture, clipLeft, clipTop, clipWidth, clipHeight);
					visual.slice.tile = newTile;
				} else {
					visual.slice.texture = texture;
				}

				var top = style.backgroundImageSliceTop != null ? style.backgroundImageSliceTop : 0;
				var right = style.backgroundImageSliceRight != null ? style.backgroundImageSliceRight : 0;
				var bottom = style.backgroundImageSliceBottom != null ? style.backgroundImageSliceBottom : 0;
				var left = style.backgroundImageSliceLeft != null ? style.backgroundImageSliceLeft : 0;

				if (hasTile) {
					var clipWidth = style.backgroundImageClipRight - style.backgroundImageClipLeft;
					var clipHeight = style.backgroundImageClipBottom - style.backgroundImageClipTop;

					if (right > 0) {
						right = clipWidth - right;
					}
					if (bottom > 0) {
						bottom = clipHeight - bottom;
					}

					visual.slice.slice(top, right, bottom, left);
				} else {
					visual.slice.slice(top, right, bottom, left);
				}

				visual.slice.size(width, height);
			} catch (e:Dynamic ) {
				trace('[haxeui-ceramic] Error applying nine slice: ${e}');
			}
		});
	}

	private function applySolidBackground(style:Style) {
		if (visual == null || visual.solid == null) {
			trace("[ERROR] Visual or solid is null");
			return;
		}

		addBgImage(style);
	}

	function addBgImage(style:Style) {
		var quad = visual.bgImage;

		ImageLoader.instance.load(style.backgroundImage, function(image:ImageInfo) {
			if (image == null) {
				trace("Image failed to load: " + style.backgroundImage);
				return;
			}
			var vis = visual.getBg();
			if (visual == null || vis == null) {
				trace("Visual or bg is null");
				return;
			}

			if (quad == null) {
				quad = new Quad();
				quad.size(image.width, image.height);
				vis.add(quad);
			}

			try {
				imgCache.set(style.backgroundImage, image.data);
				quad.texture = image.data;
				vis.alpha = 1;
			} catch (e:Dynamic ) {
				trace("Error applying texture: " + e);
			}
		});
	}

	private function applyGradient(style:Style) {
		var alpha:Int = 0xFF000000;
		var start = (style.backgroundColor | alpha);
		var end = (style.backgroundColorEnd | alpha);
		var vertical = style.backgroundGradientStyle != "horizontal";

		if (visual.gradient != null) {
			visual.gradient.setGradient(start, end, vertical);
		} else if (visual.rounded != null) {
			visual.rounded.setGradient(start, end, vertical);
		}
	}

	private function applyRectangleBorderStyles(style:Style) {
		var border = visual.border;
		border.borderSize = -1;
		var scaleFactor = App.app.screen.nativeDensity;
		//		trace(style.borderSize, style.borderLeftSize, style.borderRightSize, style.borderTopSize, style.borderBottomSize);
		var hasBorder = style.borderSize != null && style.borderSize > 0;
		var hasCompound = style.borderTopSize != null || style.borderLeftSize != null || style.borderBottomSize != null
			|| style.borderRightSize != null;

		if (hasBorder) {
			border.borderSize = style.borderSize;
			border.borderColor = style.borderColor;
		}

		if (hasCompound) {
			border.borderLeftSize = 0;
			border.borderLeftColor = Color.NONE;
			if (style.borderLeftSize != null) {
				border.borderLeftSize = style.borderLeftSize;
				border.borderLeftColor = style.borderLeftColor;
			}

			border.borderRightSize = 0;
			border.borderRightColor = Color.NONE;
			if (style.borderRightSize != null) {
				border.borderRightSize = style.borderRightSize;
				border.borderRightColor = style.borderRightColor;
			}

			border.borderTopSize = 0;
			border.borderTopColor = Color.NONE;
			if (style.borderTopSize != null) {
				border.borderTopSize = style.borderTopSize;
				border.borderTopColor = style.borderTopColor;
			}

			border.borderBottomSize = 0;
			border.borderBottomColor = Color.NONE;
			if (style.borderBottomSize != null) {
				border.borderBottomSize = style.borderBottomSize;
				border.borderBottomColor = style.borderBottomColor;
			}
		}

		if (style.borderOpacity != null) {
			border.alpha = style.borderOpacity;
		}
	}

	private function determineVisualType(style:Style) {
		var hasRadius = style.borderRadius != null && style.borderRadius > 0;
		var hasSpecificRadius = style.borderRadiusTopLeft != null
			|| style.borderRadiusTopRight != null
			|| style.borderRadiusBottomLeft != null
			|| style.borderRadiusBottomRight != null;

		var hasClip = style.backgroundImageClipTop != null
			|| style.backgroundImageClipLeft != null
			|| style.backgroundImageClipBottom != null
			|| style.backgroundImageClipRight != null;

		var hasSlice = style.backgroundImageSliceTop != null
			|| style.backgroundImageSliceLeft != null
			|| style.backgroundImageSliceBottom != null
			|| style.backgroundImageSliceRight != null;

		var oldType = visual.bgType;
		var newType:BGType;

		if (hasClip || hasSlice) {
			newType = NINESLICE;
		} else if (hasRadius || hasSpecificRadius) {
			newType = ROUNDED;
		} else if (style.backgroundColorEnd != null) {
			newType = GRADIENT;
		} else {
			newType = SOLID;
		}

		if (oldType != newType) {
			if (oldType == NINESLICE && visual.slice != null) {
				if (visual.slice.tile != null) {
					visual.slice.tile = null;
				}
				visual.slice.texture = null;
			}

			visual.bgType = newType;
		}

		if (hasRadius || hasSpecificRadius) {
			visual.borderType = ROUNDED;
		} else {
			visual.borderType = RECTANGLE;
		}
	}

	function applySliceAndClip(framed:Bool) {
		var slice = visual.slice;

		var top = style.backgroundImageSliceTop;
		var left = style.backgroundImageSliceLeft;

		var right = (style.backgroundImageClipRight - style.backgroundImageClipLeft) - style.backgroundImageSliceRight;
		var bot = style.backgroundImageClipBottom - style.backgroundImageSliceBottom;

		if (framed) {
			var tile = visual.slice.tile;
			tile.frameX = style.backgroundImageClipLeft;
			tile.frameY = style.backgroundImageClipTop;
			tile.frameWidth = style.backgroundImageClipRight - style.backgroundImageClipLeft;
			tile.frameHeight = style.backgroundImageClipBottom;

			slice.slice(top, Math.abs(right), Math.abs(bot), left);
		} else {
			slice.slice(top, right, bot, left);
		}

		slice.size(width, height);
	}

	public function checkRedispatch(type:String, event:MouseEvent) {
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

	private function hasComponentOver(ref:Component, x:Float, y:Float):Bool {
		var array:Array<Component> = getComponentsAtPoint(x, y);
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

	public function inBounds(x:Float, y:Float):Bool {
		if (cast(this, Component).hidden) {
			return false;
		}

		if (!cast(this, Component).hitTest(x, y)) {
			return false;
		}

		if (this.isClipped) {
			var clipX = x - filter.x;
			var clipY = y - filter.y;
			if (clipX < 0 || clipY < 0 || clipX > filter.width || clipY > filter.height) {
				return false;
			}
		}

		return true;
	}

	private function findChildrenAtPoint(child:Component, x:Float, y:Float, array:Array<Component>) {
		if (child.hitTest(x, y) && child.visible) {
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
		// trace(hittest);
		if (hittest && !this.hasComponentOver(cast this, x, y)) {
			listener(event);
			over = true;
			if (style != null && style.cursor != null && (this is InteractiveComponent)) {
				Cursor.setTo(CursorType.fromString(style.cursor));
			}
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
		if (info.buttonId != MouseButton.LEFT && info.touchIndex < 0) {
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

	function onMouseRightClick(info:TouchInfo, ?long:Bool = false) {
		if (!long && info.buttonId != MouseButton.RIGHT) {
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

	public function dispatchMouseEvent(type:String, info:TouchInfo) {
		var event = new MouseEvent(type);
		event.screenX = info.x;
		event.screenY = info.y;

		var componentsAtPoint = getComponentsAtPoint(info.x, info.y, false);

		for (component in componentsAtPoint) {
			if (component.eventMap.exists(type)) {
				var listener = component.eventMap.get(type);
				listener(event);

				if (event.canceled) {
					break;
				}
			}
		}
	}

	private override function mapEvent(type:String, listener:UIEvent->Void) {
		var screen = App.app.screen;
		if (visual.destroyed) {
			return;
		}
		switch (type) {
			case MouseEvent.CLICK:
				if (!eventMap.exists(MouseEvent.CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, this.onMouseLeftClick);
				}
			case MouseEvent.RIGHT_CLICK:
				if (!eventMap.exists(MouseEvent.RIGHT_CLICK)) {
					this.eventMap.set(type, listener);
					screen.onPointerUp(visual, (info) -> onMouseRightClick(info));
					screen.component("longPress", new LongPress((info) -> onMouseRightClick(info, true)));
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
					screen.offPointerUp((info) -> onMouseRightClick(info));
					screen.removeComponent("longPress");
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
					// visual.offPointerOver(_onMouseOver);
					eventMap.remove(MouseEvent.MOUSE_OVER);
				}
			case MouseEvent.MOUSE_OUT:
				if (eventMap.exists(MouseEvent.MOUSE_OUT)) {
					screen.offPointerMove(_onMouseOut);
					// visual.offPointerOut(_onMouseOut);
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
			this.addInternal(_textDisplay.visual);
			// trace('${pad(this.id)}: create text diplay');
		}
		return _textDisplay;
	}

	public override function createTextInput(text:String = null):TextInput {
		if (_textInput == null) {
			super.createTextInput(text);
			this.addInternal(_textInput.visual);
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
