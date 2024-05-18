package haxe.ui.backend.ceramic;

import ceramic.Color;
import ceramic.Quad;
import ceramic.Text;
import ceramic.Component;
import ceramic.Entity;

class UnderlineText extends Entity implements Component {
	@entity public var text:Text;

	var color:Color;
	var line:Quad = new Quad();

	var textHeight:Float = -1;
	var textWidth:Float = -1;

	var lastPointLineHeight:Float;

	public function new(thickness:Int = -1, color:Color = Color.NONE) {
		super();
		this.thickness = thickness;
		this.line.height = thickness;
		//this.color = color;
		line.roundTranslation = 1;
	}

	/// Lifecycle

	function bindAsComponent():Void {
		text.add(line);
		text.onGlyphQuadsChange(this, applyUnderline);
	}

	/// Internal

	function applyUnderline() {
		if (text.glyphQuads == null) {
			return;
		}

		line.color = text.color;
		line.alpha = text.alpha;

		if (this.lastPointLineHeight != text.pointSize) {
			lastPointLineHeight = text.pointSize;
			// text.lineHeight = this.lineHeight;
		}

		if (text.height != this.textHeight) {
			if (text.numLines == 1) {
				this.textHeight = text.height;
				this.line.height = this.thickness;
			} else { //multiline
	//			trace(text.maxLineDiff);
				var breaks = text.content.lastIndexOf('\n');
				var spacing = Math.floor(text.height / (text.numLines));
				
//				trace(breaks);
				// for (i in 0...text.numLines) {
				// 	var line = new Quad();
				// 	line.color = text.color;
				// 	line.height = 1;
				// 	var size = spacing;
				// 	line.pos(0, (size - (line.height)) * (i + 1));
				// 	line.width = text.width;
				// 	text.add(line);
				// }
			}
		}

		if (text.width != this.textWidth) {
			line.width = text.width;
		}

		// var minHeight = -1.;
		// var maxHeight = -1.;
		// for (g in text.glyphQuads) {
			
		// 	if (g.code == 32) {
		// 		continue;
		// 	}
		// 	if (minHeight == -1 || (g.height < minHeight)) {
		// 		minHeight = g.height;
		// 	}

		// 	if (maxHeight == -1 || g.height > maxHeight) {
		// 		maxHeight = g.glyph.height;
		// 	}
		// }
		
		line.y = Math.floor(text.height - (line.height / 4));
	}

	var lineHeight(get, never):Float;

	function get_lineHeight() {
		return text.lineHeight + (this.thickness / text.pointSize);
	}

	@:isVar var thickness(get, set):Int = -1;

	function get_thickness() {
		if (thickness == -1) {
			return Math.floor(Math.max(1, text.pointSize / 12));
		}
		return this.thickness;
	}

	function set_thickness(value:Int) {
		return this.thickness = value;
	}
}
