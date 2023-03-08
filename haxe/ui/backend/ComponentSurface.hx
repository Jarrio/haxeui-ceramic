package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import ceramic.MeshExtensions;
import ceramic.Quad;
import ceramic.AlphaColor;
import ceramic.Line;
import ceramic.Mesh;

class ComponentSurface {
	public var visual:Mesh;
	public var filter:Filter;

	var x(get, set):Float;
	var y(get, set):Float;
	var visible(get, set):Bool;
	var clipX(get, set):Float;
	var clipY(get, set):Float;
	var clipQuad(get, set):Quad;
	var rightBorder:Line;
	var topBorder:Line;
	var bottomBorder:Line;
	var leftBorder:Line;
	var background:Mesh;
	public function new() {

		this.visual = new Mesh();
		this.visual.active = true;
		this.visual.inheritAlpha = true;
		this.visual.colors = [AlphaColor.TRANSPARENT];

		leftBorder = new Line();
		leftBorder.inheritAlpha = true;
		leftBorder.id = ('leftBorder');
		rightBorder = new Line();
		rightBorder.inheritAlpha = true;
		rightBorder.id = ('rightBorder');
		topBorder = new Line();
		topBorder.inheritAlpha = true;
		topBorder.id = ('topBorder');
		bottomBorder = new Line();
		bottomBorder.inheritAlpha = true;
		bottomBorder.id = ('bottomBorder');

		background = new Mesh();
		background.id = ('background');
		background.inheritAlpha = true;

		
		leftBorder.depth = 1;
		rightBorder.depth = 1;
		topBorder.depth = 1;
		bottomBorder.depth = 1;
		background.depth = 0;
		
		this.visual.add(leftBorder);
		this.visual.add(rightBorder);
		this.visual.add(topBorder);
		this.visual.add(bottomBorder);
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
}
