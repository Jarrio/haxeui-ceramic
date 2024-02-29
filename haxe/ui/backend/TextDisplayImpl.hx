package haxe.ui.backend;

import haxe.ui.backend.ceramic.ItalicText;
import ceramic.Text;

class TextDisplayImpl extends TextBase {
	public var visual:Text;

	public function new() {
		super();
		visual = new Text();
		visual.active = true;
		visual.visible = false;
		visual.inheritAlpha = true;
		Toolkit.callLater(function() {
			visual.visible = true;
		});
	}

	private override function validateData() {
		if (_text != null) {
			visual.content = _text;
		}
		// trace('${ComponentImpl.pad(parentComponent.id)}: validate text data -> ${_text}');
		// if (_text != null) {
		// 	if (_dataSource == null) {
		// 		visual.content = (_text);
		// 	}
		// }
	}

	private override function validateStyle():Bool {
		var measureTextRequired = false;
		if (_textStyle != null) {
			if (_textStyle.color != null) {
				visual.color = _textStyle.color;
			}

			if (_textStyle.fontItalic != null && visual.hasComponent('italic') != _textStyle.fontItalic) {
				if (_textStyle.fontItalic) {
					visual.component('italic', new ItalicText());
					measureTextRequired = true;
				} else {
					visual.removeComponent('italic');
				}
				measureTextRequired = true;
			}

			if (_textStyle.fontSize != null) {
				visual.preRenderedSize = Std.int(_textStyle.fontSize) + 4;
				visual.pointSize = Std.int(_textStyle.fontSize);
				measureTextRequired = true;
			}

			if (_fontInfo != null) {
				visual.font = _fontInfo.data;
				measureTextRequired = true;
			}

			if (_textStyle.textAlign != null) {
				visual.align = switch (_textStyle.textAlign) {
					case 'left': LEFT;
					case 'center': CENTER;
					case 'right': RIGHT;
					default: LEFT;
				}
				measureTextRequired = true;
			}
		}
		return measureTextRequired;
	}

	private override function validatePosition() {
		// if (parentComponent.id == 'intProp') {
		var left = Std.int(_left);
		if (left % 2 != 0) {
			left++;
		}

		var top = Std.int(_top);
		if (top % 2 != 0) {
			top++;
		}

		if (visual.align == CENTER) {
			visual.anchorX = 0.5;
			left = Std.int(_left + (_width / 2));
			if (left % 2 != 0) {
				left++;
			}
			visual.x = left;
		} else {
			visual.x = left;
		}

		visual.y = top;
	}

	private override function validateDisplay() {
		// if (visual.width != _width) {
		// if (_width == null) {
		// 	var parentWidth = @:privateAccess parentComponent._width;
		// 	visual.fitWidth = parentWidth;
		// }
		var w = Math.fround(_width);
		if (w % 2 != 0) {
			w++;
		}

		if (w > 0) {
			visual.fitWidth = w;
			// visual.width = _width;
		}
		// visual.width = _width;
		// }
		var h = Math.fround(_height);
		if (h % 2 != 0) {
			h++;
		}

		if (visual.height != h) {
			visual.height = h;
		}
	}

	private override function measureText() {
		visual.computeContent();
		var w = Math.fround(visual.width);
		if (w % 2 != 0) {
			w++;
		}

		var h = Math.fround(visual.height);
		if (h % 2 != 0) {
			h++;
		}
		_textWidth = w;
		_textHeight = h;
	}
}
