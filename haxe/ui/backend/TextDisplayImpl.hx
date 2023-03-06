package haxe.ui.backend;

import haxe.ui.backend.ceramic.ItalicText;
import ceramic.Text;

class TextDisplayImpl extends TextBase {
	public var visual:Text;

	public function new() {
		super();
		visual = new Text();
		visual.active = true;
		visual.inheritAlpha = true;
	}

	private override function validateData() {
		// trace('${ComponentImpl.pad(parentComponent.id)}: validate text data -> ${_text}');
		if (_text != null) {
			if (_dataSource == null) {
				visual.content = (_text);
			}
		}
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
		// trace('${ComponentImpl.pad(parentComponent.id)}: validate text pos -> ${_left}, ${_top}');

		// visual.x = _left;
		if (visual.align == CENTER) {
			visual.x = _left + (_width / 2);
		} else {
			
		}
		var w = this._width;
		if (this._width == 0) {
			if (this.parentComponent != null) {
				w = this.parentComponent.width;
			}
		}
		
		switch (visual.align) {
			case LEFT:
				visual.anchorX = 0;
				visual.x = _left;
			case CENTER:
				visual.anchorX = 0.5;
				visual.x = (w / 2);
			case RIGHT:
				visual.anchorX = 1;
				visual.x = _left + w;
			// case 'right': RIGHT;
			default:
				visual.anchorX = 0;
				visual.x = _left;
		}
		visual.y = _top;
	}

	private override function validateDisplay() {
		if (visual.width != _width) {
			// if (_width == null) {
			// 	var parentWidth = @:privateAccess parentComponent._width;
			// 	visual.fitWidth = parentWidth;
			// }
			if (_width > 0) {
				visual.fitWidth = _width;
				visual.width = _width;
			}
			//visual.width = _width;
		}

		if (visual.height != _height) {
			visual.height = _height;
		}
	}

	private override function measureText() {
		visual.computeContent();
		_textWidth = visual.width;
		_textHeight = visual.height;
	}
}
