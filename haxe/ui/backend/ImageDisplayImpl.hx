package haxe.ui.backend;

import ceramic.Color;
import ceramic.Quad;

class ImageDisplayImpl extends ImageBase {
	public var visual:Quad;
	
	public function new() {
		super();
		this.visual = new Quad();
		visual.depthRange = -1;
		visual.depth = -4;
		//this.visual.depth = 1000;
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

	private override function validateDisplay() {
		var scaleX:Float = _imageWidth / (_imageInfo.width / Toolkit.scaleX);
		var scaleY:Float = _imageHeight / (_imageInfo.height / Toolkit.scaleY);
		visual.scale(scaleX, scaleY);
	}

	override function dispose() {
		super.dispose();
		this.visual.dispose();
	}
}
