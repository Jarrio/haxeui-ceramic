package haxe.ui.backend;

import ceramic.App;
import haxe.ui.events.UIEvent;
import ceramic.Color;
import ceramic.Text;
import ceramic.EditText;

class TextInputImpl extends TextDisplayImpl {
	public var field:EditText;
	var padding_x:Int = 0;
	var padding_y:Int = 0;
	var focused:Bool = false;
	var text_align:String;
	var font_size:Float = 14;
	var font_name:String;
	var color:Int = -1;
	var background_color:Int = -1;
	
	public function new() {
		super();

		field = new EditText(Color.fromString('#B4D5FE'), Color.BLACK, 0, 0, 0.8);
		visual.component('edit_text', field);
		visual.clipText(0, 0, _width, _height);
		field.onUpdate(visual, this.onTextChanged);
		field.onStart(visual, this.onStart);
		field.onStop(visual, this.onStop);
		App.app.screen.onceResize(visual, Ceramic.forceRender);
		App.app.onUpdate(visual, this.renderEvent);
	}

	function renderEvent(_) {
		if (!focused) {
			return;
		}
		/**
		 * Re render UI when textbox is in focus
		 */
		Ceramic.forceRender();
	}

	function onStop() {
		unregisterEvents();
	}

	function onStart() {
		registerEvents();
	}

	public override function focus() {
		focused = true;
		field.focus();
	}

	public override function blur() {
		focused = false;
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

		field.disabled = parentComponent.disabled;
		if (_textStyle != null) {
			field.multiline = _displayData.multiline;
			

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
				visual.color = Color.fromInt(color);
			}

			if (_textStyle.fontSize != null && font_size != _textStyle.fontSize) {
				font_size = _textStyle.fontSize;
				visual.pointSize = font_size;
				visual.preRenderedSize = Math.round(font_size + 2);
			}

			if (_textStyle.backgroundColor != null && background_color != _textStyle.backgroundColor) {
				background_color = _textStyle.color;
				// if (visual.clipRect != null) {
				// 	visual.clipRect.color = Color.fromInt(color);
				// }
			}
		}
		return measureTextRequired;
	}


	function onTextChanged(text:String) {
		_text = text;
		measureText();

		if (_inputData.onChangedCallback != null) {
			_inputData.onChangedCallback();
		}

		if (parentComponent != null) {
			parentComponent.dispatch(new UIEvent(UIEvent.CHANGE));
		}
	}

		private override function validatePosition() {
			var x = visual.x - padding_x;
			var y = visual.y - padding_y;
			if (_left != x) {
				visual.x = Math.round(_left + padding_x);
				//visual.clipTextX = _left;
			}

			if (_top != y) {
				visual.y = Math.round(_top + padding_y);
				//visual.clipTextY = _top;
			}
		}

		private override function validateDisplay() {
			if (_width != visual.clipTextWidth) {
				visual.clipTextWidth = _width;
			}

			if (_height != visual.clipTextHeight) {
				visual.clipTextHeight = visual.height;
			}
		}

		override function dispose() {
				super.dispose();
		}
}
