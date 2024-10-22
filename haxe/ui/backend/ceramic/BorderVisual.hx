package haxe.ui.backend.ceramic;

import ceramic.MeshExtensions;
import ceramic.AlphaColor;
import ceramic.Visual;
import ceramic.Color;
import ceramic.Mesh;
import ceramic.Quad;
import ceramic.Border;
import ceramic.RoundedRect;

enum abstract VisualType(String) {
	var SOLID;
	var GRADIENT;
	var ROUNDED;
}

@:keep
class BorderVisual extends Visual {
	public var border:Border;
	public var solid:SolidQuad;
	public var gradient:GradientQuad;
	public var rounded:RoundedRect;

	var type:VisualType = SOLID;

	public function new() {
		super();
	}

	public inline function setGradient(direction:Direction, start:AlphaColor, end:AlphaColor) {
		if (gradient != null) {
			gradient.setGradient(direction, start, end);	
		}

		if (rounded != null) {
			rounded.colorMapping = VERTICES;
			switch (direction) {
				case horizontal:
					rounded.colors = [start, end, start, end];
				case vertical:
					rounded.colors = [start, start, end, end];
			}
		}
	}

	public function resetBorder() {
		if (border == null) {
			return;
		}
		borderLeftSize = 0;
		borderRightSize = 0;
		borderTopSize = 0;
		borderBottomSize = 0;
		borderSize = 0;
	}

	public function setType(value:VisualType) {
		this.type = value;

		clearGraphicsType(value);
		switch (value) {
			case SOLID:
				solid = new SolidQuad();
			case GRADIENT:
				gradient = new GradientQuad();
			case ROUNDED:
				rounded = new RoundedRect();
		}

		bgVisual.inheritAlpha = true;
		bgVisual.depth = -5;
		bgVisual.size(width, height);

		add(bgVisual);
	}

	public var bgVisual(get, never):Visual;
	function get_bgVisual() {
		return switch(this.type) {
			case SOLID: this.solid;
			case GRADIENT: this.gradient;
			case ROUNDED: this.rounded;
		}
	}

	function clearGraphicsType(current:VisualType) {
		if (current != SOLID) {
			if (solid != null) {
				solid.destroy();
				solid = null;
			}
		}

		if (current != GRADIENT) {
			if (gradient != null) {
				gradient.destroy();
				gradient = null;
			}
		}

		if (current != ROUNDED) {
			if (rounded != null) {
				rounded.destroy();
				rounded = null;
			}
		}
	}

	public var borderActive(get, set):Bool;

	function get_borderActive() {
		return border.active;
	}

	function set_borderActive(value:Bool) {
		if (border != null && value == border.active) {
			return value;
		}

		if (value) {
			border = new Border();
			border.size(width, height);
			border.depth = -4;
			add(border);
		} else {
			if (border != null) {
				border.dispose();
				border = null;
			}
		}

		if (border == null) {
			return value;
		}

		return border.active = value;
	}

	public var bgAlpha(get, set):Float;

	function get_bgAlpha():Float {
		return bgVisual.alpha;
	}

	function set_bgAlpha(alpha:Float) {
		return bgVisual.alpha = alpha;
	}

	public var borderAlpha(get, set):Float;

	function get_borderAlpha():Float {
		return border.alpha;
	}

	function set_borderAlpha(alpha:Float) {
		return border.alpha = alpha;
	}

	public var color(get, set):Color;

	function get_color():Color {
		if (solid == null) {
			return Color.NONE;
		}
		return solid.color;
	}

	function set_color(color:Color) {
		if (solid != null) {
			solid.color = color;
		}

		if (rounded != null) {
			rounded.colorMapping = MESH;
			rounded.color = color;
		}
		return color;
	}

	public var colors(get, set):Array<AlphaColor>;

	function get_colors():Array<AlphaColor> {
		if (gradient == null) {
			return [];
		}
		return gradient.colors;
	}

	function set_colors(colors:Array<AlphaColor>) {
		if (gradient == null) {
			return colors;
		}
		return gradient.colors = colors;
	}

	public var borderColor(get, set):Color;

	function get_borderColor():Color {
		return border.borderColor;
	}

	function set_borderColor(color:Color) {
		if (color == Color.NONE) {
			borderActive = false;
			return color;
		}

		borderActive = true;
		return border.borderColor = color;
	}

	public var borderSize(get, set):Float;

	function get_borderSize():Float {
		return border.borderSize;
	}

	function set_borderSize(size:Float) {
		this.borderActive = (size > 0);
		if (border == null) {
			return size;
		}
		return border.borderSize = size;
	}

	public var borderLeftSize(get, set):Float;

	function get_borderLeftSize():Float {
		return border.borderLeftSize;
	}

	function set_borderLeftSize(size:Float) {
		if (size > 0 || border == null) {
			borderActive = true;
		}

		if (border == null) {
			return size;
		}
		return border.borderLeftSize = size;
	}

	public var borderRightSize(get, set):Float;

	function get_borderRightSize():Float {
		return border.borderRightSize;
	}

	function set_borderRightSize(size:Float) {
		if (size > 0 || border == null) {
			borderActive = true;
		}

		if (border == null) {
			return size;
		}
		return border.borderRightSize = size;
	}

	public var borderTopSize(get, set):Float;

	function get_borderTopSize():Float {
		return border.borderTopSize;
	}

	function set_borderTopSize(size:Float) {
		if (size > 0 || border == null) {
			borderActive = true;
		}

		if (border == null) {
			return size;
		}
		return border.borderTopSize = size;
	}

	public var borderBottomSize(get, set):Float;

	function get_borderBottomSize():Float {
		return border.borderBottomSize;
	}

	function set_borderBottomSize(size:Float) {
		if (size > 0 || border == null) {
			borderActive = true;
		}

		if (border == null) {
			return size;
		}
		return border.borderBottomSize = size;
	}

	public var borderLeftColor(get, set):Color;

	function get_borderLeftColor():Color {
		return border.borderLeftColor;
	}

	function set_borderLeftColor(color:Color) {
		if (color == Color.NONE || border == null) {
			borderLeftSize = 0;
			return color;
		}
		//trace(color.toHexString(), color);
		return border.borderLeftColor = color;
	}

	public var borderRightColor(get, set):Color;

	function get_borderRightColor():Color {
		return border.borderRightColor;
	}

	function set_borderRightColor(color:Color) {
		if (color == Color.NONE || border == null) {
			borderRightSize = 0;
			return color;
		}
		//trace(color.toHexString(), color);
		return border.borderRightColor = color;
	}

	public var borderTopColor(get, set):Color;

	function get_borderTopColor():Color {
		return border.borderTopColor;
	}

	function set_borderTopColor(color:Color) {
		if (color == Color.NONE || border == null) {
			borderTopSize = 0;
			return color;
		}
		//trace(color.toHexString(), color);
		return border.borderTopColor = color;
	}

	public var borderBottomColor(get, set):Color;

	function get_borderBottomColor():Color {
		return border.borderBottomColor;
	}

	function set_borderBottomColor(color:Color) {
		if (color == Color.NONE || border == null) {
			borderBottomSize = 0;
			return color;
		}
//		trace(color.toHexString(), color);
		// 0xD2D2D2
		return border.borderBottomColor = color;
	}

	public var radius(get, set):Float;
	function get_radius() {
		return rounded.radiusTopLeft;
	}

	function set_radius(value:Float) {
		rounded.radius(value);
		return value;
	}

	public var topLeftRadius(get, set):Float;
	function get_topLeftRadius() {
		return rounded.radiusTopLeft;
	}

	function set_topLeftRadius(value:Float) {
		return rounded.radiusTopLeft = value;
	}

	public var topRightRadius(get, set):Float;
	function get_topRightRadius() {
		return rounded.radiusTopRight;
	}

	function set_topRightRadius(value:Float) {
		return rounded.radiusTopRight = value;
	}

	public var bottomLeftRadius(get, set):Float;
	function get_bottomLeftRadius() {
		return rounded.radiusBottomLeft;
	}

	function set_bottomLeftRadius(value:Float) {
		return rounded.radiusBottomLeft = value;
	}

	public var bottomRightRadius(get, set):Float;
	function get_bottomRightRadius() {
		return rounded.radiusBottomRight;
	}

	function set_bottomRightRadius(value:Float) {
		return rounded.radiusBottomRight = value;
	}

	override function set_width(width:Float):Float {
		if (border != null) {
			border.width = width;
		}

		if (solid != null) {
			solid.width = width;
		}

		if (gradient != null) {
			gradient.width = width;
		}
		return super.set_width(width);
	}

	override function set_height(height:Float):Float {
		if (border != null) {
			border.height = height;
		}

		if (solid != null) {
			solid.height = height;
		}

		if (gradient != null) {
			gradient.height = height;
		}
		return super.set_height(height);
	}
}


class SolidQuad extends Quad {
	public function new() {
		super();
	}
}

class GradientQuad extends Mesh {
	public function new() {
		super();
		
		indices = [
			0, 1, 3,
			0, 2, 3
		];

		colorMapping = VERTICES;
	}

	public function setGradient(direction:Direction, start:AlphaColor, end:AlphaColor) {
		switch (direction) {
			case horizontal:
				this.colors = [start, end, start, end];
			case vertical:
				this.colors = [start, start, end, end];
		}
	}

	override function set_height(height:Float):Float {
		this.vertices = [
			    0,      0,
			width,      0,
			    0, height,
			width, height
		];
		contentDirty = true;
		return super.set_height(height);
	}

	override function set_width(width:Float):Float {
//		trace(width, height);
		this.vertices = [
			    0,      0,
			width,      0,
			    0, height,
			width, height
		];
		contentDirty = true;
		return super.set_width(width);
	}
}

enum abstract Direction(String) from String {
	var vertical;
	var horizontal;
}
