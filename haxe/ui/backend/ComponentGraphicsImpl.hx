package haxe.ui.backend;
import haxe.ui.core.Component;
import ceramic.RenderTexture;
import ceramic.Quad;
import haxe.io.Bytes;
import ceramic.AlphaColor;
import ceramic.Pixels;
import ceramic.Texture;
import ceramic.UInt8Array;

class ComponentGraphicsImpl extends ComponentGraphicsBase {
	var render:RenderTexture;
	var texture:Texture;
	var visual:Quad;
	var hasSize = false;
	public function new(component:Component) {
		super(component);
		//component.styleable = false;
		render = new RenderTexture(100, 100);
	}

	public override function clear() {
		render.clear(function() {});
	}

	public override function setPixels(pixels:Bytes) {

		var w = Std.int(_component.width);
		var h = Std.int(_component.height);

		if (this.texture == null) {
			texture = Texture.fromPixels(w, h, UInt8Array.fromBytes(pixels));
		} else {
			if (texture.width != _component.width || texture.height != _component.height) {
				texture = Texture.fromPixels(w, h, UInt8Array.fromBytes(pixels));
			}
			texture.submitPixels(UInt8Array.fromBytes(pixels));
		}
		
		if (this.visual == null) {
			visual = new Quad();
			visual.texture = texture;
			visual.size(w, h);
			_component.visual.add(visual);
		}
	}
}
