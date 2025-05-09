package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Color;
import ceramic.AlphaColor;

class RoundedBg extends Mesh {
	@content public var topLeft:Float = 1;
	@content public var topRight:Float = 1;
	@content public var bottomLeft:Float = 1;
	@content public var bottomRight:Float = 1;

	@content public var segments:Int = 32;

	public var radius(default, set):Float;

	function set_radius(value) {
		topLeft = value;
		topRight = value;
		bottomLeft = value;
		bottomRight = value;
		return value;
	}

	public function new() {
		super();
		color = Color.BLACK;
	}

	override function computeContent() {
		super.computeContent();
		createRoundedRect(topLeft, topRight, bottomRight, bottomLeft);
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

	public function createRoundedRect(topLeft:Float, topRight:Float, bottomRight:Float, bottomLeft:Float):Void {
		if (width <= 0 || height <= 0) {
			return;
		}

		this.topLeft = topLeft;
		this.topRight = topRight;
		this.bottomLeft = bottomLeft;
		this.bottomRight = bottomRight;

		this.vertices = generateVertices(0, 0, width, height);

		if (this.vertices.length >= 6) {
			this.indices = generateFillIndices(Std.int(this.vertices.length / 2));
		} else {
			this.indices = [];
		}
	}

	function generateVertices(x:Float, y:Float, width:Float, height:Float):Array<Float> {
		var vertices = [];

		var maxRadiusX = Math.min(width / 2, height / 2);

		var tlRadius = Math.min(topLeft, maxRadiusX);
		var trRadius = Math.min(topRight, maxRadiusX);
		var brRadius = Math.min(bottomRight, maxRadiusX);
		var blRadius = Math.min(bottomLeft, maxRadiusX);

		// Top-left corner
		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + tlRadius - Math.cos(angle) * tlRadius);
			vertices.push(y + tlRadius - Math.sin(angle) * tlRadius);
		}

		// Top-right corner
		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + width - trRadius + Math.sin(angle) * trRadius);
			vertices.push(y + trRadius - Math.cos(angle) * trRadius);
		}

		// Bottom-right corner
		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + width - brRadius + Math.cos(angle) * brRadius);
			vertices.push(y + height - brRadius + Math.sin(angle) * brRadius);
		}

		// Bottom-left corner
		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + blRadius - Math.sin(angle) * blRadius);
			vertices.push(y + height - blRadius + Math.cos(angle) * blRadius);
		}

		return vertices;
	}

	function generateFillIndices(vertexCount:Int):Array<Int> {
		var indices = [];

		for (i in 1...vertexCount - 1) {
			indices.push(0);
			indices.push(i);
			indices.push(i + 1);
		}

		indices.push(0);
		indices.push(vertexCount - 1);
		indices.push(1);

		return indices;
	}
}
