package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.Quad;
import ceramic.Border;

class ComponentSurface {
	public var visual:Visual;
	public var filter:Filter;
	var depth_tracker = 2;
	var visible(get, set):Bool;
	var clipX(get, set):Float;
	var clipY(get, set):Float;
	var clipQuad(get, set):Quad;

	var indices:Array<Int> = [];
	var vertices:Array<Float> = [];
	
	public function new() {
		this.indices = [
			0, 1, 3,
			0, 2, 3
		];

		this.visual = new Visual();
		//visual.depthRange = 0;
		//visual.roundTranslation = 0;
		this.visual.inheritAlpha = true;
	}

	public inline function size(width:Float, height:Float) {

		//trace('here');
		
		if (isMesh) {
			this.vertices = [
				0, 0,
				width, 0,
				0, height,
				width, height
			];
		} else {
			this.visual.size(width, height);
		}

		if (this.isMesh || this.isQuad) {
			this.background.size(width, height);
			if (this.isMesh) {
				background.asMesh.vertices = this.vertices;
			}
		}

		if (this.border != null) {
			this.border.width = width;
			this.border.height = height;
		}
	}

	public inline function add(visual:Visual) {
		//visual.depth = depth_tracker++;
		//visual.depthRange = ;
		this.visual.add(visual);
	}

	public inline function remove(visual:Visual) {
		this.visual.remove(visual);
	}

	@:isVar var border(get, set):Border;

	function set_border(border:Border) {
		if (this.border != null) {
			this.border.destroy();
		}
		border.roundTranslation = 1;
		border.depth = 100;
		border.depthRange = -1;
		return this.border = border;
	}

	function get_border() {
		return this.border;
	}

	@:isVar var background(get, set):Visual;

	function set_background(background:Visual) {
		if (this.background != null) {
			this.background.destroy();
		}
		background.roundTranslation = 1;
		//background.depth = 0;
		background.depthRange = -1;
		return this.background = background;
	}

	function get_background() {
		return this.background;
	}

	public var isQuad(get, never):Bool;
	function get_isQuad() {
		if (this.background == null) {
			return false;
		}

		return this.background.asQuad != null;
	}

	public var isMesh(get, never):Bool;
	function get_isMesh() {
		if (this.background == null) {
			return false;
		}

		return this.background.asMesh != null;
	}
	inline function set_visible(value:Bool):Bool {
		return this.visual.visible = value;
	}

	inline function get_visible():Bool {
		return this.visual.visible;
	}

	var x(get, set):Float;
	inline function set_x(value:Float):Float {
		return this.visual.x = (value);
	}

	inline function get_x():Float {
		return this.visual.x;
	}
	var y(get, set):Float;
	inline function set_y(value:Float):Float {
		return this.visual.y = (value);
	}

	inline function get_y():Float {
		return this.visual.y;
	}

	inline function set_clipX(value:Float):Float {
		return this.visual.clip.x = (value);
	}

	inline function get_clipX():Float {
		return this.visual.clip.x;
	}

	inline function set_clipY(value:Float):Float {
		return this.visual.clip.y = (value);
	}

	inline function get_clipY():Float {
		return this.visual.clip.y;
	}

	inline function set_clipQuad(quad:Quad):Quad {
		return cast this.visual.clip = quad;
	}

	inline function get_clipQuad():Quad {
		if (this.visual.clip == null) {
			return null;
		}
		return this.visual.clip.asQuad;
	}
}
