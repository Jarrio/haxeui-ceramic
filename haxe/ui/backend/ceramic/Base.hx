package haxe.ui.backend.ceramic;

import ceramic.Visual;
import ceramic.Entity;
import ceramic.Border;
import ceramic.Color;
import ceramic.Quad;
import ceramic.Component;
import ceramic.Mesh;
import ceramic.RoundedRect;
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
	public var solid:Quad;
	public var slice:NineSlice;
	public var rounded:RoundedBg;
	public var gradient:GradientMesh;
	public var clipQuad:Quad;

	public var border:Border;
	public var roundedBorder:RoundedBorder;

	public var bgType(default, set):BGType = NONE;

	function set_bgType(value:BGType) {
		if (value == bgType) {
			return bgType;
		}

		var visual:Visual = null;

		if (getBg() != null) {
			getBg().destroy();
		}
		visual = switch (value) {
			case SOLID:
				solid = new Quad();
			case GRADIENT:
				gradient = new GradientMesh();
			case ROUNDED:
				rounded = new RoundedBg();
			case NINESLICE:
				slice = new NineSlice();
			default: null;
		}
		if (visual != null) {
			visual.depth = 0;
			// visual.depthRange = -1;
			visual.inheritAlpha = true;
			visual.size(width, height);
			add(visual);
		}

		if (this.getBg() != null) {
			this.getBg().depth = 0;
		}

		if (this.getBorder() != null) {
			this.getBorder().depth = 1;
		}

		return bgType = value;
	}

	public var borderType(default, set):BorderType = NONE;

	function set_borderType(value) {
		if (value == borderType) {
			return borderType;
		}

		var visual = null;

		if (getBorder() != null) {
			getBorder().active = false;
			visual = switch (value) {
				case RECTANGLE: border;
				case ROUNDED: roundedBorder;
				default: null;
			}
			visual.active = true;
		} else {
			visual = switch (value) {
				case RECTANGLE: border = new Border();
				case ROUNDED: roundedBorder = new RoundedBorder();
				default: null;
			}
		}

		if (visual != null) {
			visual.depth = 1;
			// visual.depthRange = -1;

			visual.size(width, height);
			visual.inheritAlpha = true;
			add(visual);
		}
		return borderType = value;
	}

	override function set_width(value) {
		if (solid != null)
			solid.width = value;
		if (gradient != null)
			gradient.width = value;
		if (rounded != null) {
			rounded.width = value;
			rounded.createRoundedRect(rounded.topLeft, rounded.topRight, rounded.bottomRight, rounded.bottomLeft);
		}
		if (slice != null)
			slice.width = value;

		if (border != null) {
			border.width = value;
		}

		if (roundedBorder != null) {
			roundedBorder.width = value;
		}

		return super.set_width(value);
	}

	override function set_height(value) {
		if (solid != null)
			solid.height = value;
		if (gradient != null)
			gradient.height = value;
		if (rounded != null)
			rounded.height = value;
		if (slice != null)
			slice.height = value;

		if (border != null) {
			border.height = value;
		}

		if (roundedBorder != null) {
			roundedBorder.height = value;
		}

		return super.set_height(value);
	}

	public function getBg():Visual {
		return switch (bgType) {
			case SOLID: solid;
			case GRADIENT: gradient;
			case ROUNDED: rounded;
			case NINESLICE: slice;
			default: null;
		}
	}

	function getBorder():Visual {
		return switch (borderType) {
			case RECTANGLE: border;
			case ROUNDED: roundedBorder;
			default: null;
		}
	}

	public var bgAlpha(default, set):Float;

	function set_bgAlpha(value) {
		if (solid != null)
			solid.alpha = value;
		if (gradient != null)
			gradient.alpha = value;
		if (rounded != null)
			rounded.alpha = value;
		if (slice != null)
			slice.alpha = value;
		return value;
	}
}

private typedef TVisual = {
	var visual:Visual;
}
