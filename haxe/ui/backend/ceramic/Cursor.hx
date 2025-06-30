package haxe.ui.backend.ceramic;

class Cursor {
	public static var next(default, set):CursorType;

	static function set_next(value) {
		if (current == value || lock) {
			return value;
		}

		setTo(next);

		return next = value;
	}

	public static var current:CursorType = CursorType.DEFAULT;
	public static var lock:Bool = false;

	static public function setTo(cursor:CursorType) {
		#if (linc_sdl && cpp)
		var systemCursor = sdl.SDL.createSystemCursor(cast cursor.toSdl());
		sdl.SDL.setCursor(systemCursor);
		#end

		#if js
		js.Browser.document.body.style.cursor = cursor.toBrowser();
		#end

		current = cursor;
	}
}
