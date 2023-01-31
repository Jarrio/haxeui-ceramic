package haxe.ui.backend;

import ceramic.Color;
import ceramic.Quad;

class ImageDisplayImpl extends ImageBase {
	public var visual:Quad;

	public function new() {
		super();
		this.visual = new Quad();
		this.visual.color = Color.NONE;
	}

	private override function validateData():Void {
		if (_imageInfo != null) {
			this.visual.texture = _imageInfo.data;

			aspectRatio = _imageInfo.width / _imageInfo.height;

			this.visual.width = Std.int(_imageInfo.width);
			this.visual.height = Std.int(_imageInfo.height);
		}
	}

	private override function validateDisplay() {
		var scaleX:Float = _imageWidth / (_imageInfo.width);
		var scaleY:Float = _imageHeight / (_imageInfo.height);

		visual.scale(scaleX, scaleY);
	}

	override function dispose() {
		super.dispose();
		this.visual.dispose();
	}
}
