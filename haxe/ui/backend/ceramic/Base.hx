package haxe.ui.backend.ceramic;

import ceramic.Visual;
import ceramic.Border;
import ceramic.Quad;
import haxe.ui.backend.ceramic.RoundedBg;
import haxe.ui.backend.ceramic.RoundedBorder;
import ceramic.NineSlice;

enum abstract BGType(String) to String {
	var NONE;
	var SOLID;
	var ROUNDED;
	var GRADIENT;
	var NINESLICE;
}

enum abstract BorderType(String) to String {
	var NONE;
	var ROUNDED;
	var RECTANGLE;
}

class Base extends Visual {
	public var bg:Visual;
	public var bgImage:Quad;
	public var borderVisual:Visual;
	public var customVisuals:Array<Visual>;

	public var bgType(default, set):BGType = NONE;

	function set_bgType(value:BGType) {
		if (value == bgType) {
			return bgType;
		}

		if (bg != null) {
			remove(bg);
			bg.destroy();
			bg = null;
		}

		bg = switch (value) {
			case SOLID: new Quad();
			case GRADIENT: new GradientMesh();
			case ROUNDED: new RoundedBg();
			case NINESLICE: new NineSlice();
			default: null;
		}

		if (bg != null) {
			bg.depth = 0;
			bg.size(width, height);
			bg.inheritAlpha = true;
			add(bg);
		}

		return bgType = value;
	}

	public var borderType(default, set):BorderType = NONE;

	function set_borderType(value) {
		if (value == borderType) {
			return borderType;
		}

		if (borderVisual != null) {
			remove(borderVisual);
			borderVisual.destroy();
			borderVisual = null;
		}

		borderVisual = switch (value) {
			case RECTANGLE: new Border();
			case ROUNDED: new RoundedBorder();
			default: null;
		}

		if (borderVisual != null) {
			borderVisual.depth = 2;
			borderVisual.size(width, height);
			borderVisual.inheritAlpha = true;
			add(borderVisual);
		}

		return borderType = value;
	}

	override function set_width(value) {
		if (value == width) {
			return value;
		}

		if (bg != null) {
			bg.width = value;
			if (bgType == ROUNDED) {
				var r = cast(bg, RoundedBg);
				r.createRoundedRect(r.topLeft, r.topRight, r.bottomRight, r.bottomLeft);
			}
		}

		if (borderVisual != null) {
			borderVisual.width = value;
			if (borderType == ROUNDED) {
				cast(borderVisual, RoundedBorder).computeContent();
			}
		}

		return super.set_width(value);
	}

	override function set_height(value) {
		if (value == height) {
			return value;
		}

		if (bg != null) {
			bg.height = value;
			if (bgType == ROUNDED) {
				var r = cast(bg, RoundedBg);
				r.createRoundedRect(r.topLeft, r.topRight, r.bottomRight, r.bottomLeft);
			}
		}

		if (borderVisual != null) {
			borderVisual.height = value;
			if (borderType == ROUNDED) {
				cast(borderVisual, RoundedBorder).computeContent();
			}
		}

		return super.set_height(value);
	}

	public var bgAlpha(default, set):Float;

	function set_bgAlpha(value) {
		if (bg != null) {
			bg.alpha = value;
		}
		return bgAlpha = value;
	}

	override function interceptPointerOver(hittingVisual:Visual, x:Float, y:Float) {
		if (hittingVisual.parent != null) {
			return false;
		}
		return true;
	}
}
