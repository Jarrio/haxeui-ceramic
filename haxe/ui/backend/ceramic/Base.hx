package haxe.ui.backend.ceramic;

import ceramic.Visual;
import ceramic.Entity;
import ceramic.Border;
import ceramic.Color;
import ceramic.Quad;
import ceramic.Component;
import ceramic.Mesh;
import ceramic.RoundedRect;
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
	public var rounded:RoundedRect;
	public var gradient:GradientMesh;
	public var clipQuad:Quad;
	

	public var border:Border;
	

	public var bgType(default, set):BGType = NONE;

	function set_bgType(value:BGType) {
		
		
		if (value == bgType) {
			return bgType;
		}

		if (getBg() != null) {
			getBg().destroy();
		}

		var visual:Visual = switch (value) {
			case SOLID: solid = new Quad();
			case GRADIENT: gradient = new GradientMesh();
			case ROUNDED: rounded = new RoundedRect();
			case NINESLICE: slice = new NineSlice();
			default: null;
		}

		if (visual != null) {
			visual.depth = 0;
			visual.inheritAlpha = true;
			visual.size(width, height);
			add(visual);
		}

		return bgType = value;
	}

	public var borderType(default, set):BorderType = NONE;

	function set_borderType(value) {
		if (value == borderType) {
			return borderType;
		}

		if (getBorder() != null) {
			getBorder().destroy();
		}

		var visual = switch (value) {
			case RECTANGLE: border = new Border();
			default: null;
		}

		if (visual != null) {
			visual.depth = 1;
			visual.size(width, height);
			getBg().add(visual);
		}
		return borderType = value;
	}



	override function set_width(value) {
		getBg()?.width = value;
		getBorder()?.width = value;

		return super.set_width(value);
	}

	override function set_height(value) {
		getBg()?.height = value;
		getBorder()?.height = value;

		return super.set_height(value);
	}

	function getBg():Visual {
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
			default: null;
		}
	}

	public var bgAlpha(never, set):Float;

	function set_bgAlpha(value) {
		return getBg()?.alpha = value;
	}
}

private typedef TVisual = {
	var visual:Visual;
}
