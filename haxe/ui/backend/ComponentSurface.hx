package haxe.ui.backend;

import ceramic.Quad;
import ceramic.Border;
import ceramic.Filter;
import ceramic.Visual;
import ceramic.Entity;
import ceramic.Component;
import haxe.ui.backend.ceramic.Base;

class ComponentSurface {
	public var visual:Base;

	/**
	 * We add all components onto this
	 */
	public var filter:Filter;

	var depth_tracker = 2;
	var visible(get, set):Bool;
	var clipX(get, set):Float;
	var clipY(get, set):Float;
	var clipQuad(get, set):Quad;

	var indices:Array<Int> = [];
	var vertices:Array<Float> = [];

	public function new() {
		this.visual = new Base();
		// visual.depthRange = -1;
		this.visual.inheritAlpha = true;
	}

	public inline function size(width:Float, height:Float) {
		this.visual.width = Std.int(width);
		this.visual.height = Std.int(height);
	}

	public function add(visual:Visual) {
		if (this.visual.customVisuals == null) {
			this.visual.customVisuals = [];
		}
		this.visual.customVisuals.push(visual);
		addInternal(visual);
	}

	@:noCompletion private function addInternal(visual:Visual) {
		visual.inheritAlpha = true;

		if (visual.depth <= 0) {
			visual.depth = depth_tracker++;
		}

		// if (visual is Quad) {
		// 	trace(visual.asQuad.texture == null);
		// }
		this.visual.add(visual);

		// this.visual.sortChildrenByDepth();
	}

	public inline function remove(visual:Visual) {
		depth_tracker--;
		this.visual.remove(visual);
	}

	inline function set_visible(value:Bool):Bool {
		return this.visual.visible = value;
	}

	inline function get_visible():Bool {
		return this.visual.visible;
	}

	var x(get, set):Float;

	inline function set_x(value:Float):Float {
		return this.visual.x = Std.int(value);
	}

	inline function get_x():Float {
		return this.visual.x;
	}

	var y(get, set):Float;

	inline function set_y(value:Float):Float {
		return this.visual.y = Std.int(value);
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
