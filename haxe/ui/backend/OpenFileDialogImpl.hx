package haxe.ui.backend;

import electron.main.Dialog;
import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;
import ceramic.Dialogs;

using StringTools;

class OpenFileDialogImpl extends OpenFileDialogBase {
    public override function show() {
			trace('not implemented');
			// Dialogs.openFile('Open file', [], (file) -> {
			// 	if (file != null) {
			// 		dialogConfirmed([{
			// 			fullPath: file
			// 		}]);
			// 	} else {
			// 		dialogCancelled();
			// 	}
			// });
    }
}