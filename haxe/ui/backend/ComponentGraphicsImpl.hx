package haxe.ui.backend;

import ceramic.App;
import haxe.ui.util.Color;
import ceramic.Line;
import ceramic.Point;
import haxe.ui.core.Component;
import ceramic.RenderTexture;
import ceramic.Quad;
import haxe.io.Bytes;
import ceramic.Texture;
import ceramic.UInt8Array;
import ceramic.Arc;

class ComponentGraphicsImpl extends ComponentGraphicsBase {
	var render:RenderTexture;
	var texture:Texture;
	var visual:Quad;
	var hasSize = false;

	var current_position:Point = new Point();

	var color:ceramic.Color;
	var thickness:Float;
	var alpha:Float = 1;

	var size:Bool = false;

	// var line = new Line();
	// var quad:Quad = new Quad();
	// var arcs:Arc = new Arc();

	public function new(component:Component) {
		super(component);
		// line.color = ceramic.Color.BLACK;
		// App.app.onBeginDraw(visual, draw);
	}

	public override function clear() {
		if (!size) {
			return super.clear();
		}
		// render.clear(() -> {});
	}

	// function draw() {
	// 	for (key => command in _drawCommands) {
	// 		switch (command) {
	// 			case Clear:
	// 			case MoveTo(x, y):
	// 				this.current_position.x = x;
	// 				this.current_position.y = y;
	// 			case LineTo(x, y):
	// 				// var line = new Line();
	// 				// line.color = this.color;
	// 				// line.thickness = this.thickness;
	// 				// line.points = [current_position.x, current_position.y, x, y];
	// 				// render.stamp(line, () -> {
	// 				// 	line.destroy();
	// 				// });
	// 			case StrokeStyle(color, thickness, alpha):
	// 				this.color = ceramic.Color.BLACK;
	// 				this.thickness = thickness;
	// 				this.alpha = alpha;
	// 			default:
	// 		}
	// 	}
	// }

	override function strokeStyle(color:Null<Color>, thickness:Null<Float> = 1, alpha:Null<Float> = 1) {
		if (!size) {
			return super.strokeStyle(color, thickness, alpha);
		}
		if (color == null) {
			trace(color);
		}
		this.color = ceramic.Color.fromInt(color);
		this.thickness = thickness;
		this.alpha = alpha;
	}

	override function moveTo(x:Float, y:Float) {
		if (!size) {
			return super.moveTo(x, y);
		}
		current_position.x = x;
		current_position.y = y;
	}

	override function lineTo(x:Float, y:Float) {
		if (!size) {
			return super.lineTo(x, y);
		}

		var line = new Line();
		line.color = this.color;
		line.thickness = this.thickness;
		line.points = [current_position.x, current_position.y, x, y];
		render.stamp(line, () -> {
			line.destroy();
		});
	}

	override function rectangle(x:Float, y:Float, width:Float, height:Float) {
		if (!size) {
			return super.rectangle(x, y, width, height);
		}
		var quad = new Quad();
		quad.color = this.color;
		quad.alpha = this.alpha;
		quad.x = x;
		quad.y = y;
		quad.width = width;
		quad.height = height;
		render.stamp(quad, () -> {
			quad.destroy();
		});
	}

	override function circle(x:Float, y:Float, radius:Float) {
		if (!size) {
			return super.circle(x, y, radius);
		}

		var arc = new Arc();
		arc.borderPosition = MIDDLE;
		arc.radius = radius;
		arc.angle = 360;
		arc.color = this.color;
		arc.alpha = this.alpha;

		arc.thickness = this.thickness;
		arc.x = x;
		arc.y = y;
		render.stamp(arc, () -> {
			arc.destroy();
		});
	}

	public override function setPixels(pixels:Bytes) {
		if (!size) {
			return super.setPixels(pixels);
		}

		var w = Std.int(_component.width);
		var h = Std.int(_component.height);
		var pixel_length = w * h * 4;

		if (pixels.length != pixel_length) {
			trace('Error: $pixel_length');
			return;
		}

		if (pixels == null || pixels.length == 0) {
			trace('Error: Pixel data is null or empty');
			return;
		}

		var uint8Array = UInt8Array.fromBytes(pixels);

		if (this.texture == null || this.texture.width != w || this.texture.height != h) {
			texture = Texture.fromPixels(w, h, uint8Array);
		} else {
			texture.submitPixels(uint8Array);
		}
		
		if (this.visual == null) {
			visual = new Quad();
			visual.size(w, h);
			_component.visual.add(visual);
		}
		if (this.visual.texture != texture) {
			visual.texture = texture;
		}
	}

	public override function resize(width:Null<Float>, height:Null<Float>) {
		if (width > 0 && height > 0) {
			if (!size) {
				size = true;

				visual = new Quad();
				render = new RenderTexture(width, height);

				render.autoRender = false;
				visual.texture = render;
				_component.visual.add(visual);
				visual.size(width, height);
				replayDrawCommands();
			}
		}
	}
}
