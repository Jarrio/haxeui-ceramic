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
				/**
				 * Before creating text, we prerender the fonts larger than the expectd output
				 * You can set how much larger with the -D prerender_font_factor
				 * By default it is 2x
				 */
				visual.preRenderedSize = Std.int(_textStyle.fontSize) * ceramic.macros.DefinesMacro.getIntDefine("prerender_font_factor") ?? 2;
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
		//if (parentComponent.id == 'intProp') {
		if (visual.align == CENTER) {
			visual.anchorX = 0.5;
			visual.x = Std.int(_left + (_width / 2));
		} else {
			visual.x = Std.int(_left);
		}
		
		visual.y = Std.int(_top);
	}

	private override function validateDisplay() {
		//if (visual.width != _width) {
			// if (_width == null) {
			// 	var parentWidth = @:privateAccess parentComponent._width;
			// 	visual.fitWidth = parentWidth;
			// }

			if (_width > 0) {
				visual.fitWidth = Std.int(_width);
				//visual.width = _width;
			}
			//visual.width = _width;
		//}

		if (visual.height != _height) {
			visual.height = Std.int(_height);
		}
	}

	private override function measureText() {
		visual.computeContent();
		_textWidth = Std.int(visual.width);
		_textHeight = Std.int(visual.height);
	}
}
