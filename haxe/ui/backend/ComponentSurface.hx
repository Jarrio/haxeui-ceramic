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
	var background:Mesh;

	public function new() {

		this.visual = new Visual();
		this.visual.active = true;
		this.visual.inheritAlpha = true;
		//this.visual.alpha = 0;
		// this.visual.colors = [AlphaColor.TRANSPARENT];

		background = new Mesh();
		background.id = ('background');
		background.inheritAlpha = true;
		background.colors = [AlphaColor.TRANSPARENT];
		background.depth = 0;

		border = new Border();
		border.depth = 1;
		
		this.visual.add(border);
		this.visual.add(background);
	}

	public inline function size(width:Float, height:Float) {
		this.visual.size(width, height);
	}

	public inline function add(visual:Visual) {
		this.visual.add(visual);
	}

	public inline function remove(visual:Visual) {
		this.visual.remove(visual);
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
