package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Color;

class RoundedBorder extends Mesh {
	@content public var topLeft:Float = 1;
	@content public var topRight:Float = 1;
	@content public var botLeft:Float = 1;
	@content public var botRight:Float = 1;
	@content public var thickness:Float = 1;

	public var radius(never, set):Float;

	function set_radius(value) {
		topLeft = value;
		topRight = value;
		botLeft = value;
		botRight = value;
		return value;
	}

	override function computeContent() {
		super.computeContent();
		createBorder(topLeft, topRight, botRight, botLeft);
	}

	public function new(thickness:Float = 1, color:Color = Color.BLACK) {
		super();
		this.thickness = thickness;
		this.color = color;
	}

	public function createBorder(topLeft:Float, topRight:Float, botRight:Float, botLeft:Float):Void {
		this.topLeft = topLeft;
		this.topRight = topRight;
		this.botLeft = botLeft;
		this.botRight = botRight;

		var outerVertices = generateRoundedRectVertices(0, 0, width, height);
		var innerVertices = generateRoundedRectVertices(thickness, thickness, width - 2 * thickness, height - 2 * thickness);

		this.vertices = outerVertices.concat(innerVertices);

		this.indices = generateBorderIndices(Std.int(outerVertices.length / 2), Std.int(innerVertices.length / 2), Std.int(outerVertices.length / 2));
	}

	function generateRoundedRectVertices(x:Float, y:Float, width:Float, height:Float):Array<Float> {
		var vertices = [];
		var segments = 16;

		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + this.topLeft - Math.cos(angle) * this.topLeft);
			vertices.push(y + this.topLeft - Math.sin(angle) * this.topLeft);
		}

		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + width - this.topRight + Math.sin(angle) * this.topRight);
			vertices.push(y + this.topRight - Math.cos(angle) * this.topRight);
		}

		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + width - this.botRight + Math.cos(angle) * this.botRight);
			vertices.push(y + height - this.botRight + Math.sin(angle) * this.botRight);
		}

		for (i in 0...segments) {
			var angle = Math.PI / 2 * (i / segments);
			vertices.push(x + this.botLeft - Math.sin(angle) * this.botLeft);
			vertices.push(y + height - this.botLeft + Math.cos(angle) * this.botLeft);
		}

		return vertices;
	}

	function generateBorderIndices(outerCount:Int, innerCount:Int, totalOuterVertices:Int):Array<Int> {
		var indices = [];

		for (i in 0...outerCount) {
			var nextOuter = (i + 1) % outerCount;
			var nextInner = (i + 1) % innerCount;

			indices.push(i);
			indices.push(nextOuter);
			indices.push(totalOuterVertices + i);

			indices.push(nextOuter);
			indices.push(totalOuterVertices + nextInner);
			indices.push(totalOuterVertices + i);
		}

		return indices;
	}
}
