package haxe.ui.backend.ceramic;

import ceramic.AlphaColor;
import ceramic.Visual;
import ceramic.Color;
import ceramic.Border;
import haxe.ui.backend.ceramic.GradientQuad;

class BorderVisual extends Visual {
	public var border:Border;
	public var solid:SolidQuad;
	public var gradient:GradientQuad;

	public function new() {
		super();
	}

	public inline function setGradient(direction:Direction, start:Color, end:Color) {
		if (gradient == null) {
			return;
		}
		gradient.setGradient(direction, start, end);
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

	@:isVar public var isSolid(get, set):Bool;

	function get_isSolid():Bool {
		return isSolid;
	}

	function set_isSolid(value:Bool) {
		if (value) {
			if (gradient != null) {
				gradient.dispose();
				gradient = null;
			}
			solid = new SolidQuad();
			solid.inheritAlpha = true;
			solid.size(width, height);
			solid.depth = 0;
			add(solid);
		} else {
			if (solid != null) {
				solid.dispose();
				solid = null;
			}
			gradient = new GradientQuad();
			gradient.inheritAlpha = true;
			gradient.size(width, height);
			gradient.depth = 0;
			add(gradient);
		}
		return isSolid = value;
	}

	public var borderActive(get, set):Bool;

	function get_borderActive() {
		return border.active;
	}

	function set_borderActive(value:Bool) {
		if (value) {
			border = new Border();
			border.size(width, height);
			border.depth = 1;
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
		if (solid != null) {
			return solid.alpha;
		}
		return gradient.alpha;
	}

	function set_bgAlpha(alpha:Float) {
		if (solid != null) {
			return solid.alpha = alpha;
		}
		return gradient.alpha = alpha;
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
		if (solid == null) {
			return color;
		}
		return solid.color = color;
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
		if (size > 0 && border == null) {
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
		if (size > 0 && border == null) {
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
		if (size > 0 && border == null) {
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
		if (size > 0 && border == null) {
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
			return color;
		}
		trace(color.toHexString(), color);
		return border.borderLeftColor = color;
	}

	public var borderRightColor(get, set):Color;

	function get_borderRightColor():Color {
		return border.borderRightColor;
	}

	function set_borderRightColor(color:Color) {
		
		if (color == Color.NONE || border == null) {
			return color;
		}
		trace(color.toHexString(), color);
		return border.borderRightColor = color;
	}

	public var borderTopColor(get, set):Color;

	function get_borderTopColor():Color {
		return border.borderTopColor;
	}

	function set_borderTopColor(color:Color) {
		
		if (color == Color.NONE || border == null) {
			return color;
		}
		trace(color.toHexString(), color);
		return border.borderTopColor = color;
	}

	public var borderBottomColor(get, set):Color;

	function get_borderBottomColor():Color {
		return border.borderBottomColor;
	}

	function set_borderBottomColor(color:Color) {
		
		if (color == Color.NONE || border == null) {
			return color;
		}
		trace(color.toHexString(), color);
		// 0xD2D2D2
		return border.borderBottomColor = color;
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
