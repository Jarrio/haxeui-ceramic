package haxe.ui.backend.ceramic;

import ceramic.AlphaColor;
import ceramic.Mesh;
import ceramic.Texture;
import ceramic.Color;
import ceramic.Quad;
import ceramic.Visual;
import ceramic.Border;
import ceramic.NineSlice;

class BorderQuad extends Visual {
	public var isMesh:Bool =  false;
	public var isSlice:Bool = false;
	var border:Border;
	var background:Quad;
	var sliceBackground:NineSlice;
	var gbackground:Mesh; // used for gradients

	public function new() {
		super();
	}

	function activateBorder() {
		if (border == null) {
			border = new Border();
			border.inheritAlpha = true;
			border.size(width, height);
			border.depth = 2;
			border.borderSize = 0;
			this.add(border);
		}
		border.active = true;
	}

	function deactivateBorder() {
		if (border == null) {
			return;
		}
		this.remove(border);
		border.destroy();
		border = null;
		//border.active = false;
	}

	function activateSliceBackground() {
		this.deactivateBackground();
		this.deactivateGradientBackground();
		if (sliceBackground == null) {
			this.isMesh = false;
			sliceBackground = new NineSlice();
			sliceBackground.inheritAlpha = true;
			sliceBackground.size(width, height);
			sliceBackground.depth = 0;
			this.add(sliceBackground);
			this.isSlice = true;
		}

		sliceBackground.active = true;
	}

	function deactivateSliceBackground() {
		if (sliceBackground == null) {
			return;
		}
		this.remove(sliceBackground);
		sliceBackground.destroy();
		sliceBackground = null;
		this.isSlice = false;
	}

	function activateBackground() {
		this.deactivateSliceBackground();
		this.deactivateGradientBackground();
		if (background == null) {
			this.isMesh = false;
			background = new Quad();
			background.inheritAlpha = true;
			background.size(width, height);
			background.depth = 0;
			this.add(background);
		}

		background.active = true;
	}

	function deactivateBackground() {
		if (background == null) {
			return;
		}
		this.remove(background);
		background.destroy();
		background = null;
	}

	function activateGradientBackground() {
		this.deactivateBackground();
		this.deactivateSliceBackground();
		if (this.gbackground == null) {
			this.isMesh = true;
			gbackground = new Mesh();
			gbackground.colorMapping = VERTICES;
			gbackground.inheritAlpha = true;
			gbackground.indices = [
				0, 1, 3,
				0, 2, 3
			];
			gbackground.vertices = [
				0, 0,
				width, 0,
				0, height,
				width, height
			];
			gbackground.size(width, height);
			gbackground.depth = 0;
			this.add(gbackground);
		}

		gbackground.active = true;
	}

	function deactivateGradientBackground() {
		if (this.gbackground == null) {
			return;
		}
		this.isMesh = false;
		this.remove(gbackground);
		this.gbackground.destroy();
		gbackground = null;
	}

	public function setGradient(direction:Direction, start:Color, end:Color) {
		activateGradientBackground();
		switch (direction) {
			case horizontal:
				gbackground.colors = [start, end, start, end];
			case vertical:
				gbackground.colors = [start, start, end, end];
				
		}
	}

	public function setNineSlice(texture:Texture, top:Float, bot:Float, left:Float, right:Float) {

		activateSliceBackground();
		sliceBackground.texture = texture;
		setSlice(top, bot, left, right);
	}

	inline public function setSlice(top:Float, bot:Float, left:Float, right:Float) {
		if (sliceBackground == null) {
			return;
		}
		sliceBackground.slice(top, right, bot, left);
	}

	inline public function setSlicePos(x:Float, y:Float) {
		if (sliceBackground == null) {
			return;
		}
		sliceBackground.pos(x, y);
	}

	inline public function setSliceSize(width:Float, height:Float) {
		if (sliceBackground == null) {
			return;
		}
		sliceBackground.size(width, height);
	}

	override function set_width(value) {
		super.set_width(value);
		if (this.border != null) {
			this.border.width = value;
		}

		if (this.background != null) {
			this.background.width = value;
		}

		if (this.gbackground != null) {
			gbackground.vertices = [
				0, 0,
				width, 0,
				0, height,
				width, height
			];
			this.gbackground.width = value;
		}

		if (sliceBackground != null) {
			sliceBackground.width = value;
		}
		return value;
	}

	override function set_height(value) {
		super.set_height(value);
		if (this.border != null) {
			this.border.height = value;
		}

		if (this.background != null) {
			this.background.height = value;
		}

		if (this.gbackground != null) {
			gbackground.vertices = [
				0, 0,
				width, 0,
				0, height,
				width, height
			];
			this.gbackground.height = value;
		}

		if (sliceBackground != null) {
			sliceBackground.height = value;
		}
		return value;
	}

	public var texture(get, set):Texture;

	function set_texture(value) {
		activateBackground();
		return this.background.texture = value;
	}

	function get_texture() {
		return this.background.texture;
	}

	public var bg_color(get, set):Color;

	function get_bg_color() {
		return this.background.color;
	}

	function set_bg_color(color:Color) {
		if (color == Color.NONE) {
			this.deactivateBackground();
			return color;
		} else {
			this.activateBackground();
		}
		return this.background.color = color;
	}

	public var bg_alpha(get, set):Float;

	function get_bg_alpha() {
		return this.background.alpha;
	}

	function set_bg_alpha(value:Float) {
		if (value == 0) {
			if (gbackground != null) {
				this.deactivateGradientBackground();
			}

			if (background != null) {
				this.deactivateBackground();
			}
			return value;
		}

		if (this.background != null) {
			return this.background.alpha = value;
		}

		if (this.gbackground != null) {
			return this.gbackground.alpha = value;
		}

		return value;
	}

	public var border_alpha(get, set):Float;

	function get_border_alpha() {
		return this.border.alpha;
	}

	function set_border_alpha(value:Float) {
		if (value == 0) {
			this.deactivateBorder();
		} else {
			this.activateBorder();
		}
		return this.border.alpha = value;
	}

	public var border_color(get, set):Color;

	function get_border_color() {
		return this.border.borderColor;
	}

	function set_border_color(color:Color) {
		if (color == Color.NONE) {
			if (border != null) {
				border.borderSize = 0;
			}
		} else {
			this.activateBorder();
		}
		if (border == null) {
			return color;
		}
		return this.border.borderColor = color;
	}

	public var border_size(get, set):Float;

	function get_border_size() {
		return this.border.borderSize;
	}

	function set_border_size(size:Float) {
		if (size <= 0) {
			this.deactivateBorder();
		} else {
			this.activateBorder();
		}

		if (border == null) {
			return size;
		}

		return this.border.borderSize = size;
	}

	public var border_left_color(get, set):Color;

	function get_border_left_color() {
		return this.border.borderLeftColor;
	}

	function set_border_left_color(color:Color) {
		if (color == Color.NONE) {
			if (border != null) {
				this.border.borderLeftSize = -1;
			}
		} else {
			this.activateBorder();
		}

		if (border == null) {
			return color;
		}
		
		return this.border.borderLeftColor = color;
	}

	public var border_left_size(get, set):Float;

	function get_border_left_size() {
		return this.border.borderLeftSize;
	}

	function set_border_left_size(size:Float) {
		if (size > 0) {
			this.activateBorder();
		}
		if (border == null) {
			return size;
		}
		
		return this.border.borderLeftSize = size;
	}

	public var border_right_color(get, set):Color;

	function get_border_right_color() {
		return this.border.borderRightColor;
	}

	function set_border_right_color(color:Color) {
		if (color == Color.NONE) {
			if (border != null) {
				this.border.borderRightSize = -1;
			}
		} else {
			this.activateBorder();
		}

		if (border == null) {
			return color;
		}
		return this.border.borderRightColor = color;
	}

	public var border_right_size(get, set):Float;

	function get_border_right_size() {
		return this.border.borderRightSize;
	}

	function set_border_right_size(size:Float) {
		if (size > 0) {
			this.activateBorder();
		}
		if (border == null) {
			return size;
		}

		return this.border.borderRightSize = size;
	}

	public var border_top_color(get, set):Color;

	function get_border_top_color() {
		return this.border.borderTopColor;
	}

	function set_border_top_color(color:Color) {
		if (color == Color.NONE) {
			if (border != null) {
				this.border.borderTopSize = -1;
			}
		} else {
			this.activateBorder();
		}

		if (border == null) {
			return color;
		}
		return this.border.borderTopColor = color;
	}

	public var border_top_size(get, set):Float;

	function get_border_top_size() {
		return this.border.borderTopSize;
	}

	function set_border_top_size(size:Float) {
		if (size > 0) {
			this.activateBorder();
		}
		if (border == null) {
			return size;
		}

		return this.border.borderTopSize = size;
	}

	public var border_bottom_color(get, set):Color;

	function get_border_bottom_color() {
		return this.border.borderBottomColor;
	}

	function set_border_bottom_color(color:Color) {
		if (color == Color.NONE) {
			if (border != null) {
				this.border.borderBottomSize = -1;
			}
		} else {
			this.activateBorder();
		}
		return this.border.borderBottomColor = color;

		if (border == null) {
			return color;
		}
	}

	public var border_bottom_size(get, set):Float;

	function get_border_bottom_size() {
		return this.border.borderBottomSize;
	}

	function set_border_bottom_size(size:Float) {
		if (size > 0) {
			this.activateBorder();
		}
		if (border == null) {
			return size;
		}
		return this.border.borderBottomSize = size;
	}
}

enum abstract Direction(String) from String {
	var vertical;
	var horizontal;
}
