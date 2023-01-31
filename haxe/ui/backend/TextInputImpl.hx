package haxe.ui.backend;

import ceramic.Color;
import ceramic.Text;
import ceramic.EditText;

class TextInputImpl extends TextDisplayImpl {
	public var field:EditText;

	public function new() {
		super();

		field = new EditText(Color.BLUE, Color.BLACK);
		visual.component('edit_text', field);

		field.onUpdate(null, this.onTextChanged);
	}

	public override function focus() {
		field.focus();
	}

	function onTextChanged(text:String) {
		_text = text;
	}
}
