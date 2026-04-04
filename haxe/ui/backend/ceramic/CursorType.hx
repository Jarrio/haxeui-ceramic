package haxe.ui.backend.ceramic;

enum abstract CursorType(String) from String to String {
	var DEFAULT = 'default';
	var COL_RESIZE = 'col-resize';
	var ROW_RESIZE = 'row-resize';
	var NWSE_RESIZE = 'nwse-resize';
	var NESW_RESIZE = 'nesw-resize';
	var NS_RESIZE = 'ns-resize';
	var EW_RESIZE = 'ew-resize';
	var POINTER = 'pointer';
	var MOVE = 'move';
	var TEXT = 'text';
	var DISABLED = 'not-allowed';

	public static function fromString(cursor:String):CursorType {
		return switch (cursor) {
			case 'default': DEFAULT;
			case 'col-resize': COL_RESIZE;
			case 'row-resize': ROW_RESIZE;
			case 'nwse-resize': NWSE_RESIZE;
			case 'nesw-resize': NESW_RESIZE;
			case 'ns-resize': NS_RESIZE;
			case 'ew-resize': EW_RESIZE;
			case 'pointer': POINTER;
			case 'move': MOVE;
			case 'text': TEXT;
			case 'not-allowed': DISABLED;
			default: DEFAULT;
		}
	}

	public function toSdl() {
		return switch (this) {
			case DEFAULT: 0;
			case POINTER: 11;
			case ROW_RESIZE: 8;
			case COL_RESIZE: 7;
			case NWSE_RESIZE: 5;
			case NESW_RESIZE: 6;
			case EW_RESIZE: 7;
			case NS_RESIZE: 8;
			case MOVE: 9;
			case TEXT: 1;
			case DISABLED: 10;
			default: 0;
		}
	}

	public function toBrowser():String {
		return switch (this) {
			case ROW_RESIZE: 'ns-resize';
			case COL_RESIZE: 'ew-resize';
			default: this;
		}
	}
}
