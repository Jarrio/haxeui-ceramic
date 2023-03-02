package haxe.ui.backend.ceramic;

import ceramic.Visual;

class CMesh extends ceramic.Mesh {
	override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float, touchIndex:Int, buttonId:Int):Bool {
		return false;
	}

	override function interceptPointerOver(hittingVisual:Visual, x:Float, y:Float):Bool {
		return false;
	}
}