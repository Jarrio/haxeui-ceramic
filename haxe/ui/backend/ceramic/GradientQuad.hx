package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Border;
import ceramic.Quad;
import ceramic.Color;

class GradientQuad extends Mesh {
	public function new() {
		super();
		
		indices = [
			0, 1, 3,
			0, 2, 3
		];

		colorMapping = VERTICES;
	}

	public function setGradient(direction:Direction, start:Color, end:Color) {
		switch (direction) {
			case horizontal:
				this.colors = [start, end, start, end];
			case vertical:
				this.colors = [start, start, end, end];
		}
	}

	override function set_height(height:Float):Float {
		this.vertices = [
			    0,      0,
			width,      0,
			    0, height,
			width, height
		];
		return super.set_height(height);
	}

	override function set_width(width:Float):Float {
		this.vertices = [
			    0,      0,
			width,      0,
			    0, height,
			width, height
		];
		return super.set_width(width);
	}
}

enum abstract Direction(String) from String {
	var vertical;
	var horizontal;
}
