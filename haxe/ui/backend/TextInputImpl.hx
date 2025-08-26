package haxe.ui.backend;

import haxe.ui.events.KeyboardEvent;
import ceramic.App;
import haxe.ui.events.UIEvent;
import ceramic.Color;
import ceramic.Text;
import ceramic.EditText;
import haxe.ui.core.Screen;
import haxe.ui.backend.TextBase;
import haxe.ui.backend.ceramic.PasswordText;
import haxe.ui.components.TextField;

class TextInputImpl extends TextBase {
	public var field:EditText;
	public var visual:Text;

	var padding_x:Int = 0;
	var padding_y:Int = 0;
	var focused:Bool = false;
	var text_align:String;
	var font_size:Float = 14;
	var font_name:String;
	var color:Int = -1;
	var background_color:Int = -1;
	var pw_comp:PasswordText;

	public var is_password(default, set):Bool = false;

	function set_is_password(value:Bool) {
		if (value != is_password) {
			if (value) {
				if (pw_comp == null) {
					pw_comp = new PasswordText();
				}

				field.component('password', pw_comp);
			} else {
				if (field.hasComponent('password')) {
					//					field.offUpdate(pw_comp.applyChange);
					field.removeComponent('password');
					pw_comp.destroy();
					pw_comp = null;
				}
			}
			return is_password = value;
		}
		return value;
	}

	public var content(get, never):String;

	function get_content() {
		if (pw_comp == null) {
			return '';
		}

		// trace(pw_comp.text);
		return pw_comp.content;
	}

	public function new() {
		super();

		visual = new Text();
		visual.active = true;
		visual.visible = false;
		visual.inheritAlpha = true;
		field = new EditText(Color.fromString('#B4D5FE'), Color.BLACK, 0, 0, 0.8);
		visual.component('edit_text', field);

		var font = Screen.instance.options.default_textfield_font;
		if (font != null) {
			visual.font = font;
		}

		field.onSubmit(visual, this.onSubmit);

		field.onUpdate(visual, this.onTextChanged);
		field.onStart(visual, this.onStart);
		field.onStop(visual, this.onStop);

		visual.clipText(0, 0, _width, _height);

		Toolkit.callLater(function() {
			parentComponent.registerEvent(UIEvent.RESIZE, this.onResize);
			visual.visible = true;
		});
	}

	function onStop() {
		Screen.instance.resumeEvent(KeyboardEvent.KEY_DOWN);
		Screen.instance.resumeEvent(KeyboardEvent.KEY_UP);
		Screen.instance.resumeEvent(KeyboardEvent.KEY_PRESS);
		unregisterEvents();
	}

	function onStart() {
		Screen.instance.pauseEvent(KeyboardEvent.KEY_DOWN);
		Screen.instance.pauseEvent(KeyboardEvent.KEY_UP);
		Screen.instance.pauseEvent(KeyboardEvent.KEY_PRESS);
		registerEvents();
	}

	function onResize(e) {
		trace(_width, _height);
	}

	public override function focus() {
		focused = true;
		Ceramic.startForceDraw();
		field.focus();
	}

	public override function blur() {
		focused = false;
		Ceramic.endForceDraw();
		field.stopInput();
	}

	private var _eventsRegistered:Bool = false;

	private function registerEvents() {
		if (_eventsRegistered) {
			return;
		}
		_eventsRegistered = true;
		parentComponent.registerEvent(UIEvent.HIDDEN, onParentHidden);
	}

	private function unregisterEvents() {
		parentComponent.unregisterEvent(UIEvent.HIDDEN, onParentHidden);
		_eventsRegistered = false;
	}

	private function onParentHidden(_) {
		blur();
	}

	private override function validateStyle():Bool {
		var measureTextRequired:Bool = super.validateStyle();

		if (_inputData.password != this.is_password) {
			is_password = true;
		}
		if (parentComponent.disabled != field.disabled) {
			field.disabled = parentComponent.disabled;
		}

		
		if (_textStyle == null) {
			return false;
		}

		if (_displayData.multiline != field.multiline) {
			field.multiline = _displayData.multiline;
		}

		if (field.multiline && _displayData.wordWrap && visual.fitWidth != this._width) {
			visual.fitWidth = this._width;
			trace('updated width $_width');
		}

		if (text_align != _textStyle.textAlign) {
			text_align = _textStyle.textAlign;
			visual.align = switch (text_align) {
				case 'left': LEFT;
				case 'right': RIGHT;
				case 'center': CENTER;
				default: LEFT;
			}
		}

		if (_textStyle.color != null && color != _textStyle.color) {
			color = _textStyle.color;
			visual.color = color;
		}

		if (_textStyle.fontSize != null && font_size != _textStyle.fontSize) {
			var presize = Screen.instance.options.prerender_font_size;
			font_size = _textStyle.fontSize;
			visual.preRenderedSize = Std.int(font_size * presize);
			visual.pointSize = font_size;
		}

		if (_textStyle.backgroundColor != null && background_color != _textStyle.backgroundColor) {
			background_color = _textStyle.color;
		}

		return measureTextRequired;
	}

	private override function validateData() {
		if (_text == null) {
			return;
		}
		// trace('Text updated: ', '"$_text"');
		if (_text != visual.content) {
			// trace('Text updated: ', _text);
			visual.content = _text;
		}
	}

	function onSubmit() {
		// trace('Text updated: ', '"$_text"');
		if (parentComponent != null) {
			parentComponent.dispatch(new UIEvent(UIEvent.SUBMIT));
		}
		field.startInput();
	}

	function onTextChanged(text:String) {
		var field:TextField = cast parentComponent;
		if (field == null || text == _text) {
			return;
		}
		if (focused && text == field.placeholder) {
			text = '';
		}
		// trace('Text updated: ', text);
		_text = text;
		visual.content = text;
		measureText();

		if (_inputData.onChangedCallback != null) {
			_inputData.onChangedCallback();
		}

		if (parentComponent != null) {
			parentComponent.dispatch(new UIEvent(UIEvent.CHANGE));
		}
	}

	private override function validatePosition() {
		// trace('Text updated: ', '"$_text"');
		var x = visual.x - padding_x;
		var y = visual.y - padding_y;
		if (_left != x) {
			visual.x = Math.round(_left + padding_x);
			// visual.clipTextX = _left;
		}

		if (_top != y) {
			visual.y = Math.round(_top + padding_y);
			// visual.clipTextY = _top;
		}
	}

	private override function validateDisplay() {
		// trace('Text updated: ', '"$_text"');
		//		trace(_width, _height, visual.height);
		if (_width != visual.clipTextWidth) {
			visual.clipTextWidth = _width;
		}

		if (_height != visual.clipTextHeight) {
			visual.clipTextHeight = _height;
		}
	}

	private override function measureText() {
		visual.computeContent();
		var w = Math.fround(visual.width);
		var h = Math.fround(visual.height);

		_textWidth = w;
		_textHeight = h;
	}

	override function dispose() {
		super.dispose();
	}
}
