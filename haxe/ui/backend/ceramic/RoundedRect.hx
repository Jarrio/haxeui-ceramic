package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Quad;
import ceramic.Arc;
import ceramic.Color;
import ceramic.Visual;

typedef Coords = {
	@:optional var x:Float;
	@:optional var y:Float;
	@:optional var w:Float;
	@:optional var h:Float;
}

class RoundedRect extends Mesh {
	var thickness:Int;
	var radius:Float;

	public var inside:Mesh;
	public var border:Mesh;
	public var background_color(get, set):Color;

	public function new(color:Color, x:Float, y:Float, radius:Float, w:Float, h:Float, border:Color = Color.NONE, thickness:Int = 1) {
		super();
		this.create(color, x, y, radius, w, h, border, thickness);
	}

	public function create(color:Color, x:Float, y:Float, radius:Float, w:Float, h:Float, border:Color = Color.NONE, thickness:Int = 1) {
		this.width = w;
		this.height = h;
		this.x = x;
		this.y = y;
		this.thickness = thickness;
		this.setInside(color, x, y, radius, w, h, thickness);
		if (border != Color.NONE) {
			this.setBorder(border, x, y, radius, w, h);
		}
	}

	public function setBorder(color:Color, x:Float, y:Float, radius:Float,  w:Float, h:Float) {
		border = this.makeRect(color, x, y, radius, w, h);
		border.depth = 1;
		this.add(border);
	}

	public function setInside(color:Color, x:Float, y:Float, radius:Float, w:Float, h:Float, thickness:Int) {
		var ir = Std.int(radius - thickness);
		var ix = x + thickness;
		var iy = y + thickness;
		var iw = w - (thickness * 2);
		var ih = h - (thickness * 2);

		inside = this.makeRect(color, ix, iy, ir, iw, ih);
		inside.colorMapping = VERTICES;
		var start = Color.CYAN;
		var end = Color.BLUE;

		inside.colors = [start, end, start, end];
		inside.depth = 2;
		this.add(inside);
	}

	private function makeRect(color:Color, x:Float, y:Float, radius:Float, width:Float, height:Float) {
		var quad = new Mesh();
		quad.color = color;
		quad.add(makePart(color, x + radius, y, width - 2 * radius, height));
		quad.add(makePart(color, x, y + radius, radius, height - 2 * radius));
		quad.add(makePart(color, x + width - radius, y + radius, radius, height - 2 * radius));

		quad.add(makeArc(color, radius, {x: x + radius, y: y + radius}, Math.PI, Math.PI * 1.5));
		quad.add(makeArc(color, radius, {x: x + width - radius, y: y + radius}, -Math.PI * 0.5, 0.0));
		quad.add(makeArc(color, radius, {x: x + width - radius, y: y + height - radius}, 0, Math.PI * 0.5));
		quad.add(makeArc(color, radius, {x: x + radius, y: y + height - radius}, Math.PI * 0.5, Math.PI));
		
		return quad;
	}

	private function makePart(color:Color, x:Float, y:Float, w:Float, h:Float) {
		var part = new Quad();
		part.color = color;
		part.pos(x, y);
		part.size(w, h);
		return part;
	}

	function makeArc(color:Color, radius:Float, pos:Coords, rotation:Float, angle:Float) {
		var arc = new Arc();
		arc.radius = radius;
		arc.borderPosition = INSIDE;
		arc.thickness = radius;
		arc.pos(pos.x, pos.y);
		arc.rotation = rotation;
		arc.angle = 360;
		arc.color = color;
		return arc;
	}

	function get_background_color() {
		return inside.color;
	}

	function set_background_color(color:Color) {
		for (part in inside.children) {
			if (part.asQuad != null) {
				part.asQuad.color = color;
			}

			if (part.asMesh != null) {
				part.asMesh.color = color;
			}
			
		}
		return inside.color = color;
	}

	function get_border_color() {
		if (border == null) {
			return Color.NONE;
		}
		return border.color;
	}

	function set_border_color(color:Color) {
		if (border == null) {
			return Color.NONE;
		}

		for (part in border.children) {
			if (part.asQuad != null) {
				part.asQuad.color = color;
			}

			if (part.asMesh != null) {
				part.asMesh.color = color;
			}
			
		}
		return border.color = color;
	}
}