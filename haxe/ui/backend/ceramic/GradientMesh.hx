package haxe.ui.backend.ceramic;

import ceramic.Entity;
import ceramic.Component;
import ceramic.Visual;
import ceramic.Mesh;
import ceramic.Color;

class GradientMesh extends Mesh {
	public function new() {
		super();
		
		indices = [
			0, 1, 3,
			0, 2, 3
		];

		
	}

	override function set_width(value) {
		vertices = [
			    0,      0,
			value,      0,
			    0, height,
			value, height
		];
		return super.set_width(value);
	}

	override function set_height(value) {
		vertices = [
			    0,      0,
			width,      0,
			    0, value,
			width, value
		];
		return super.set_height(value);
	}

	public function setGradient(start:Color, end:Color, vertical:Bool = true) {
		colorMapping = VERTICES;
		colors = switch (vertical) {
			case true:  [start, start, end, end];
			case false: [start, end, start, end];
		}
	}
}