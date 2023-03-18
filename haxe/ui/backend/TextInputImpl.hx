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

	private override function validateStyle():Bool {
		var measureTextRequired:Bool = super.validateStyle();

		field.disabled = parentComponent.disabled;
		
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
}
