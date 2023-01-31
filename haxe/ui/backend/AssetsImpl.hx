package haxe.ui.backend;

import ceramic.Entity;
import assets.Images;
import ceramic.Texture;
import ceramic.Quad;
import haxe.io.Bytes;
import ceramic.Assets;
import haxe.ui.assets.ImageInfo;

using StringTools;

class AssetsImpl extends AssetsBase {
	private override function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void):Void {
		throw haxe.exceptions.NotImplementException;
		// if (Resource.listNames().indexOf(resourceId) == -1) {
		// 	callback(resourceId, null);
		// } else {
		// 	var bytes = Resource.getBytes(resourceId);
		// 	imageFromBytes(bytes, callback.bind(resourceId));
		// }
	}

	private override function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		throw haxe.exceptions.NotImplementException;
	}

	var assets:Assets;

	override function imageFromFile(filename:String, callback:ImageInfo->Void) {
		var assets = ceramic.App.app.assets;
		var dir = Sys.getCwd() + '/assets';
		if (filename.startsWith('haxeui-core')) {
			var split = filename.split('/');
			var file = split[split.length - 1];
			filename = '/haxeui-core/$file';
		}
		var path = dir + filename;
		assets.addImage(path);
		assets.onceComplete(new Entity(), success -> {
			if (success) {
				trace('success');
				var texture = assets.texture(path);
				if (texture != null) {
					callback({
						data: texture,
						width: Std.int(texture.width),
						height: Std.int(texture.height),
					});
				} else {
					trace('Failed to load image $path...');
					callback(null);
				}
			} else {
				trace('Failed to load image $path...');
				callback(null);
			}
		});
		assets.load();
	}

	public override function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void) {
		throw haxe.exceptions.NotImplementException;
	}
}
