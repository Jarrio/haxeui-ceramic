package haxe.ui.backend;

import haxe.ui.backend.ceramic.ItalicText;
import ceramic.Text;
import haxe.ui.core.Screen;
import ceramic.Visual;
import ceramic.App;
import haxe.ui.backend.ceramic.UnderlineText;

class TextDisplayImpl extends TextBase {
	public var visual:Visual;
	public var text_visual:Text;

	var presize:Float = 1.5;

	public function new() {
		super();
		visual = new Visual();
		visual.active = true;
		visual.visible = false;
		visual.inheritAlpha = true;

		text_visual = new Text();
		var font = Screen.instance.options.default_text_font;

		if (font != null) {
			text_visual.font = font;
		}

		visual.add(text_visual);
		Toolkit.callLater(function() {
			var presize = Screen.instance.options.prerender_font_size;
			if (presize != null) {
				this.presize = presize;
			}

			visual.visible = true;
		});
	}

	private override function validateData() {
		if (_text != null && text_visual.content != _text) {
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
				} else {
					text_visual.removeComponent('underline');
				}
				measureTextRequired = true;
			}

			if (_textStyle.opacity != null) {
				text_visual.alpha = _textStyle.opacity;
			}

			if (_textStyle.fontSize != null) {
				text_visual.preRenderedSize = Std.int(_textStyle.fontSize * presize);
				text_visual.pointSize = _textStyle.fontSize;
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

				if (font != null) {
					text_visual.font = font;
					measureTextRequired = true;
				}
			}

			if (_textStyle.fontItalic != null) {
				var weight = _textStyle.fontWeight ?? 0;
				if (_textStyle.fontItalic) {
					var italics = Screen.instance.options.font_italics ?? [];
					if (weight != 0 && italics.exists(weight)) {
						text_visual.font = italics.get(weight);
					} else if (!text_visual.hasComponent('italic')) {
						text_visual.component('italic', new ItalicText());
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
					measureTextRequired = true;
				} else {
					trace(
						'[Haxeui-Ceramic] - Font ${font_name} does not exist in the assets object'
					);
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
		var alignX = _left;

		switch (text_visual.align) {
			case CENTER:
				alignX = Math.round(_left + (_width / 2) - (text_visual.width / 2));
			case RIGHT:
				alignX = Math.round(_left + _width - text_visual.width);
			case LEFT:
				alignX = Math.round(_left);
		}

		if (alignX != text_visual.x) {
			text_visual.x = alignX;
		}

		if (_top != visual.y) {
			visual.y = _top;
		}

		if (text_visual.numLines == 1) {
			var offset = Screen.instance.options.text_offset;
			if (offset == null) {
				offset = Math.floor(text_visual.height - text_visual.pointSize);
				if (offset < 0) {
					offset = 0;
				}
			}
			if (_top + offset != visual.y) {
				visual.y = _top + offset;
			}
		}
	}

	private var autoWidth(get, null):Bool;

	inline function get_autoWidth():Bool {
		return parentComponent.autoWidth;
	}

	private override function validateDisplay() {
		if (_width > 0) {
			if (visual.width != _width) {
				visual.width = _width;
			}

			if (!parentComponent.autoWidth) {
				text_visual.fitWidth = _width;
			}
		}

		if (_height > 0 && visual.height != _height) {
			visual.height = _height;
		}
	}

	private override function measureText() {
		if (text_visual.contentDirty) {
			text_visual.computeContent();
		}

		var w = text_visual.width;
		var h = text_visual.height;

		if (text_visual.numLines == 1) {
			h = text_visual.pointSize;

			if (Screen.instance.options.text_offset != null) {
				h = text_visual.height;
			}
		}

		_textWidth = Math.round(w);
		_textHeight = Math.round(h);
	}
}
