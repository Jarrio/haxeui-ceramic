package haxe.ui.backend.ceramic;

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

class RoundedRect extends Visual {
	public function new(color:Color, x:Float, y:Float, radius:Int, w:Int, h:Int, border:Color = Color.NONE, thickness:Int = 1) {
		super();
		this.width = w;
		this.height = h;
		var ir = Std.int(radius - thickness);
		var ix = x + thickness;
		var iy = y + thickness;
		var iw = w - (thickness * 2);
		var ih = h - (thickness * 2);
		this.makeRect(color, ix, iy, ir, iw, ih);
		if (border != Color.NONE) {
			this.makeRect(border, x, y, radius, w, h);
		}
	}

	private function makeRect(color:Color, x:Float, y:Float, radius:Int, width:Float, height:Float) {
		var quad = new Quad();
		quad.add(makePart(color, x + radius, y, width - 2 * radius, height));
		quad.add(makePart(color, x, y + radius, radius, height - 2 * radius));
		quad.add(makePart(color, x + width - radius, y + radius, radius, height - 2 * radius));

		quad.add(makeArc(color, radius, {x: x + radius, y: y + radius}, Math.PI, Math.PI * 1.5));
		quad.add(makeArc(color, radius, {x: x + width - radius, y: y + radius}, -Math.PI * 0.5, 0.0));
		quad.add(makeArc(color, radius, {x: x + width - radius, y: y + height - radius}, 0, Math.PI * 0.5));
		quad.add(makeArc(color, radius, {x: x + radius, y: y + height - radius}, Math.PI * 0.5, Math.PI));

		this.add(quad);
	}

	private function makePart(color:Color, x:Float, y:Float, w:Float, h:Float) {
		var part = new Quad();
		part.color = color;
		part.pos(x, y);
		part.size(w, h);
		return part;
	}

	function makeArc(color:Color, radius:Int, pos:Coords, rotation:Float, angle:Float) {
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
}