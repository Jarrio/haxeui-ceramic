package haxe.ui.backend;

import ceramic.Color;
import ceramic.Quad;

class ImageDisplayImpl extends ImageBase {
	public var visual:Quad;

	public function new() {
		super();
		this.visual = new Quad();
		//this.visual.color = Color.NONE;
	}

	private override function validateData():Void {
		if (_imageInfo != null) {
			this.visual.texture = _imageInfo.data;

			this.visual.width = Std.int(_imageInfo.width);
			this.visual.height = Std.int(_imageInfo.height);
		}
	}

	private override function validatePosition() {
		if (visual.x != _left) {
				visual.x = _left;
		}

		if (visual.y != _top) {
				visual.y = _top;
		}
	}

	override function dispose() {
		super.dispose();
		this.visual.dispose();
	}
}
