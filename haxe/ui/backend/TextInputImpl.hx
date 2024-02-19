package haxe.ui.backend;

import haxe.ui.events.UIEvent;
import ceramic.Color;
import ceramic.Text;
import ceramic.EditText;

class TextInputImpl extends TextDisplayImpl {
	public var field:EditText;

	public function new() {
		super();

		field = new EditText(Color.BLUE, Color.BLACK);
		visual.component('edit_text', field);
		field.onUpdate(visual, this.onTextChanged);
	}

	public override function focus() {
		field.focus();
	}

	public override function blur() {
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
		
		return measureTextRequired;
	}

	function onTextChanged(text:String) {
		if (text == _text) {
			return;
		}
		_text = text;
		measureText();
        
		if (_inputData.onChangedCallback != null) {
			_inputData.onChangedCallback();
		}
		
		if (parentComponent != null) {
			parentComponent.dispatch(new UIEvent(UIEvent.CHANGE));
		}
	}
}
