package haxe.ui.backend;

//import ceramic.Dialogs;

class SaveFileDialogImpl extends SaveFileDialogBase {


	#if js
	private var _fileSaver:haxe.ui.util.html5.FileSaver = new haxe.ui.util.html5.FileSaver();

	public override function show() {
		if (fileInfo == null || (fileInfo.text == null && fileInfo.bytes == null)) {
			throw "Nothing to write";
		}

		if (fileInfo.text != null) {
			_fileSaver.saveText(fileInfo.name, fileInfo.text, onSaveResult);
		} else if (fileInfo.bytes != null) {
			_fileSaver.saveBinary(fileInfo.name, fileInfo.bytes, onSaveResult);
		}
	}

	private function onSaveResult(r:Bool) {
		if (r == true) {
			dialogConfirmed();
		} else {
			dialogCancelled();
		}
	}
	#else
	public override function show() {
		trace('not implemented on this target yet');2
		// Dialogs.saveFile('Open file', [], (file) -> {
		// 	if (file != null) {
		// 		dialogConfirmed();
		// 	} else {
		// 		dialogCancelled();
		// 	}
		// });
	}
	#end
}
