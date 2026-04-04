package haxe.ui.backend;

import ceramic.Filter;
import ceramic.Visual;
import haxe.ui.backend.ceramic.Base;

class ComponentSurface {
	public var visual:Base;
	public var filter:Filter;

	public function new() {
		this.visual = new Base();
		this.visual.inheritAlpha = true;
	}

	public inline function size(width:Float, height:Float) {
		this.visual.width = Std.int(width);
		this.visual.height = Std.int(height);
	}

	public function add(visual:Visual) {
		addInternal(visual);
	}

	@:noCompletion private function addInternal(visual:Visual) {
		visual.inheritAlpha = true;
		this.visual.add(visual);
	}

	public inline function remove(visual:Visual) {
		this.visual.remove(visual);
	}
}
