package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.MeshExtensions;
import ceramic.Quad;
import ceramic.AlphaColor;
import ceramic.Line;
import ceramic.Mesh;
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
		this.visual.inheritAlpha = true;
		//this.visual.alpha = 0;
		// this.visual.colors = [AlphaColor.TRANSPARENT];
		
		//background = new Visual();
		//background.inheritAlpha = true;
		//background.colors = [AlphaColor.TRANSPARENT];
		//background.depth = 0;


		
		//this.visual.add(border);
		//this.visual.add(background);
	}

	public inline function size(width:Float, height:Float) {
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
			this.border.size(width, height);
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
			this.visual.remove(background);
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
