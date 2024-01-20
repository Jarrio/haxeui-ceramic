package haxe.ui.backend;

//import ceramic.Dialogs;
import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;

using StringTools;

class OpenFileDialogImpl extends OpenFileDialogBase {
	#if js
	private var _fileSelector:haxe.ui.util.html5.FileSelector = new haxe.ui.util.html5.FileSelector();

	public override function show() {
		var readMode = haxe.ui.util.html5.FileSelector.ReadMode.None;
		if (options.readContents == true) {
			if (options.readAsBinary == false) {
				readMode = haxe.ui.util.html5.FileSelector.ReadMode.Text;
			} else {
				readMode = haxe.ui.util.html5.FileSelector.ReadMode.Binary;
			}
		}
		_fileSelector.selectFile(onFileSelected, readMode, options.multiple, options.extensions);
	}

	private function onFileSelected(cancelled:Bool, files:Array<SelectedFileInfo>) {
		if (cancelled == false) {
			dialogConfirmed(files);
		} else {
			dialogCancelled();
		}
	}
	#else
	public override function show() {
		trace('not implemented on this target yet');
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