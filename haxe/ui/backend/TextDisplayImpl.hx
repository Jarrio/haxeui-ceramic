package haxe.ui.backend;

import assets.Fonts;
import ceramic.Assets;
import haxe.ui.backend.ceramic.ItalicText;
import ceramic.Text;
import haxe.ui.core.Screen;
import ceramic.Visual;
import ceramic.App;
import haxe.ui.backend.AppImpl;
import haxe.ui.backend.ceramic.UnderlineText;

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
		// font = AppImpl.assets.font(Fonts.ROBOTO_REGULAR);

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

			if (_textStyle.fontUnderline != null && text_visual.hasComponent('underline') != _textStyle.fontUnderline) {
				if (_textStyle.fontUnderline) {
					text_visual.component('underline', new UnderlineText());
					measureTextRequired = true;
				} else {
					text_visual.removeComponent('underline');
				}
				measureTextRequired = true;
			}

			if (_textStyle.opacity != null) {
				text_visual.alpha = _textStyle.opacity;
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

			if (_textStyle.fontWeight != null) {
				var weights = Screen.instance.options.font_weights;
				var font = null;
				if (weights == null || !weights.exists(_textStyle.fontWeight)) {
					font = Screen.instance.options.default_text_font;
				} else {
					font = weights.get(_textStyle.fontWeight);
				}

				text_visual.font = font;
				measureTextRequired = true;
			}

			if (_textStyle.fontItalic != null) {
				var weight = _textStyle.fontWeight ?? 0;
				if (_textStyle.fontItalic) {
					var italics = Screen.instance.options.font_italics ?? [];
					if (weight != null && italics.exists(weight)) {
						text_visual.font = italics.get(weight);
					} else {
						text_visual.component('italic', new ItalicText());
						measureTextRequired = true;
					}
				} else {
					if (text_visual.hasComponent('italic')) {
						text_visual.removeComponent('italic');
					}
				}
				measureTextRequired = true;
			}

			var font_name = _textStyle.fontName;
			if (font_name != null) {
				var font = App.app.assets.font(font_name);
				if (font == null) {
					var assets = Screen.instance.options.assets;
					if (assets != null) {
						font = assets.font(font_name);
					}
				}

				if (font != null) {
					text_visual.font = font;
				} else {
					trace(
						'[Haxeui-Ceramic] - Font ${font_name} does not exist in the assets object'
					);
				}
				measureTextRequired = true;
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
				text_visual.x = (_left + (_width / 2) - (text_visual.width / 2));
			case RIGHT:
				text_visual.x = (_width - text_visual.width);
			case LEFT:
				text_visual.x = (_left);
		}

		visual.y = _top;

		if (text_visual.numLines == 1) {
			var offset = Screen.instance.options.text_offset;
			if (offset == null) {
				offset = Math.floor(text_visual.height - text_visual.pointSize);
			}
			visual.y = _top + offset;
		}
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

		var w = (text_visual.width);
		var h = (text_visual.pointSize);

		if (Screen.instance.options.text_offset != null) {
			h = text_visual.height;
		}

		if (text_visual.numLines > 1) {
			h = text_visual.height;
		}

		_textWidth = w;
		_textHeight = h;
	}
}