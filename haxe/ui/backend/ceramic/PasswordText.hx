package haxe.ui.backend.ceramic;

import ceramic.Text;
import ceramic.EditText;
import ceramic.Component;
import ceramic.Entity;

class PasswordText extends Entity implements Component {
	@entity public var visual:EditText;

	public var content:String = '';

	var stars:String = '';
	var length:Int = -1;

	function bindAsComponent():Void {
		length = text.length;
		if (length > 0) {
			for (i in 0...length) {
				stars += '*';
			}
			content = text;
			text = stars;
		}
		
		visual.entity.onGlyphQuadsChange(this, applyChange);
	}

	public function applyChange() {
		var sx = visual.selectText.selectionStart;
		var ex = visual.selectText.selectionEnd;

		if (text.length > this.length) {
			this.content += text.charAt(text.length - 1);
			stars += '*';
		} else if (text.length < this.length) {
			this.content = content.substr(0, -1);
			this.stars = stars.substr(0, -1);
		}

		if (length != text.length) {
			visual.updateText(stars);
			length = content.length;
		}
	}

	public var text(get, set):String;

	function get_text() {
		return visual.entity.content;
	}

	function set_text(value:String) {
		return visual.entity.content = value;
	}
}
