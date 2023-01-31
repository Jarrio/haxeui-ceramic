package haxe.ui.backend;

import ceramic.Quad;
import ceramic.AlphaColor;
import ceramic.Line;
import ceramic.Mesh;
import ceramic.Color;

class ComponentSurface {
	public var visual:Mesh;

	var x(get, set):Float;
	var y(get, set):Float;
	var visible(get, set):Bool;
	var clipX(get, set):Float;
	var clipY(get, set):Float;
	var clipQuad(get, set):Quad;
	var leftBorder(get, never):Line;
	var rightBorder(get, never):Line;
	var topBorder(get, never):Line;
	var bottomBorder(get, never):Line;

	public function new() {
		this.visual = new Mesh();
		this.visual.colors = [AlphaColor.TRANSPARENT];
	}

	inline function set_visible(value:Bool):Bool {
		return this.visual.visible = value;
	}

	inline function get_visible():Bool {
		return this.visual.visible;
	}

	inline function set_x(value:Float):Float {
		return this.visual.x = value;
	}

	inline function get_x():Float {
		return this.visual.x;
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

	inline function get_leftBorder():Line {
		var id = 'left_border';
		var line = this.visual.childWithId(id);
		if (line == null) {
			line = new Line();
			line.id = id;
		}
		return cast line;
	}

	inline function get_rightBorder():Line {
		var id = 'right_border';
		var line = this.visual.childWithId(id);
		if (line == null) {
			line = new Line();
			line.id = id;
		}
		return cast line;
	}

	inline function get_topBorder():Line {
		var id = 'top_border';
		var line = this.visual.childWithId(id);
		if (line == null) {
			line = new Line();
			line.id = id;
		}
		return cast line;
	}

	inline function get_bottomBorder():Line {
		var id = 'bottom_border';
		var line = this.visual.childWithId(id);
		if (line == null) {
			line = new Line();
			line.id = id;
		}
		return cast line;
	}
}
