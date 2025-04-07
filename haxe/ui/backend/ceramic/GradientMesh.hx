package haxe.ui.backend.ceramic;

import ceramic.AlphaColor;
import ceramic.Entity;
import ceramic.Component;
import ceramic.Visual;
import ceramic.Mesh;
import ceramic.Color;

class GradientMesh extends Mesh {
	
	@content public var segments:Int = 32;

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

	public function setGradient(start:AlphaColor, end:AlphaColor, vertical:Bool) {
		var colors = [];

		// Top-left corner
		for (i in 0...segments) {
			colors.push(vertical ? start : start);
		}

		// Top-right corner
		for (i in 0...segments) {
			colors.push(vertical ? start : end);
		}

		// Bottom-right corner
		for (i in 0...segments) {
			colors.push(vertical ? end : end);
		}

		// Bottom-left corner
		for (i in 0...segments) {
			colors.push(vertical ? end : start);
		}

		colorMapping = VERTICES;
		this.colors = colors;
	}
}