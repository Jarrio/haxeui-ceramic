package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.Quad;
import ceramic.Border;

class ComponentSurface {
	public var visual:Visual;
	public var filter:Filter;

	var visible(get, set):Bool;
	var clipX(get, set):Float;
	var clipY(get, set):Float;
	var clipQuad(get, set):Quad;
	var border:Border;

	var indices:Array<Int> = [];
	var vertices:Array<Float> = [];
	
	public function new() {
		this.indices = [
			0, 1, 3,
			0, 2, 3
		];

		this.visual = new Visual();
		visual.roundTranslation = 1;
		this.visual.inheritAlpha = true;
	}

	public inline function size(width:Float, height:Float) {
		width = Math.fround(width);
		height = Math.fround(height);
		//trace('here');
		
		this.vertices = [
			    0,      0,
			width,      0,
			    0, height,
			width, height
		];
		this.visual.size(width, height);

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
		this.visual.add(visual);
	}

	public inline function remove(visual:Visual) {
		this.visual.remove(visual);
	}

	@:isVar var background(get, set):Visual;

	function set_background(background:Visual) {
		if (this.background != null) {
			this.background.destroy();
		}
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

	inline function set_y(value:Float):Float {
		return this.visual.y = value;
	}

	inline function get_y():Float {
		return this.visual.y;
	}

	inline function set_clipX(value:Float):Float {
		return this.visual.clip.x = value;
	}

	inline function get_clipX():Float {
		return this.visual.clip.x;
	}

	inline function set_clipY(value:Float):Float {
		return this.visual.clip.y = value;
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
