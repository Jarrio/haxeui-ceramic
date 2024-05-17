package haxe.ui.backend;

import assets.Fonts;
import ceramic.Assets;
import haxe.ui.backend.ceramic.ItalicText;
import ceramic.Text;
import haxe.ui.core.Screen;
import ceramic.Visual;
import ceramic.App;
import haxe.ui.backend.AppImpl;

class TextDisplayImpl extends TextBase {
	public var visual:Visual;
	public var text_visual:Text;

	public function new() {
		super();
		visual = new Visual();
		visual.active = true;
		visual.visible = false;
		visual.inheritAlpha = true;

		text_visual = new Text();
		
		var font = Screen.instance.options.default_text_font;
		//font = AppImpl.assets.font(Fonts.ROBOTO_REGULAR);
		
		if (font != null) {
			text_visual.font = font;
		}
		
		visual.add(text_visual);
		Toolkit.callLater(function() {
			visual.visible = true;
		});
	}

	private override function validateData() {
		if (_text != null) {
			text_visual.content = _text;
		}
	}

	private override function validateStyle():Bool {
		var measureTextRequired = false;
		if (_textStyle != null) {
			if (_textStyle.color != null) {
				text_visual.color = _textStyle.color;
			}

			if (_textStyle.fontItalic != null && text_visual.hasComponent('italic') != _textStyle.fontItalic) {
				if (_textStyle.fontItalic) {
					text_visual.component('italic', new ItalicText());
					measureTextRequired = true;
				} else {
					text_visual.removeComponent('italic');
				}
				measureTextRequired = true;
			}

			if (_textStyle.fontSize != null) {
				var presize = Screen.instance.options.prerender_font_size;
				text_visual.preRenderedSize = Std.int(_textStyle.fontSize * presize);
				text_visual.pointSize = Std.int(_textStyle.fontSize);
				measureTextRequired = true;
			}

			if (_fontInfo != null) {
				text_visual.font = _fontInfo.data;
				measureTextRequired = true;
			}

			if (_textStyle.fontName != null) {
				var font = App.app.assets.fontAsset(_textStyle.fontName);

				if (font != null && font.font != null) {
					text_visual.font = font.font;
				}
			}

			if (_textStyle.textAlign != null) {
				text_visual.align = switch (_textStyle.textAlign) {
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

		switch (text_visual.align) {
			case CENTER:
				text_visual.x = Std.int(_left + (_width / 2) - (text_visual.width / 2));
			case RIGHT:
				text_visual.x = Std.int(_width - text_visual.width);
			case LEFT:
				text_visual.x = Std.int(_left);
		}

		visual.y = _top;
	}

	private override function validateDisplay() {
		var w = _width;

		if (w > 0 && visual.width != w) {
			visual.width = w;
			text_visual.fitWidth = w;
		}

		var h = _height;

		if (h > 0 && visual.height != h) {
			visual.height = h;
		}
	}

	private override function measureText() {
		visual.computeContent();
		var w = Math.fround(text_visual.width);
		var h = Math.fround(text_visual.height);

		_textWidth = w;
		_textHeight = h;
	}
}
