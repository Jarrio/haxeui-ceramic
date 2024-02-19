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
		field.onStart(visual, this.onStart);
		field.onStop(visual, this.onStop);
	}

	function onStop() {
		unregisterEvents();
		Ceramic.forceRender();
	}

	function onStart() {
		registerEvents();
		Ceramic.forceRender();
	}

	public override function focus() {
		field.focus();
		Ceramic.forceRender();
	}

	public override function blur() {
		field.stopInput();
		Ceramic.forceRender();
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
		Ceramic.forceRender();
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
		Ceramic.forceRender();
	}

    private override function validatePosition() {
			_left = Math.round(_left);
			_top = Math.round(_top);
    }
}
