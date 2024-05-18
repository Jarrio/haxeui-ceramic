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
		this.color = color;
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

		if (this.color == Color.NONE) {
			if (line.color != text.color) {
				this.line.color = text.color;
			}
		} else {
			this.line.color = color;
		}

		if (this.lastPointLineHeight != text.pointSize) {
			lastPointLineHeight = text.pointSize;
			// text.lineHeight = this.lineHeight;
		}

		if (text.height != this.textHeight) {
			this.textHeight = text.height;
			this.line.height = this.thickness;
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

		// 	if (minHeight == -1 || (g.glyph.height < minHeight)) {
		// 		minHeight = g.glyph.height;
		// 	}

		// 	if (maxHeight == -1 || g.glyph.height > maxHeight) {
		// 		maxHeight = g.glyph.height;
		// 	}
		// }

		// trace('min: $minHeight | max: $maxHeight | ${textHeight}');
		line.y = text.height + 2;
	}

	var lineHeight(get, never):Float;

	function get_lineHeight() {
		return text.lineHeight + (this.thickness / text.pointSize);
	}

	@:isVar var thickness(get, set):Int = -1;

	function get_thickness() {
		if (thickness == -1) {
			return Math.floor(Math.max(1, text.pointSize / 10));
		}
		return this.thickness;
	}

	function set_thickness(value:Int) {
		return this.thickness = value;
	}
}
