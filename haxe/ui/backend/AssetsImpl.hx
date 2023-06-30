package haxe.ui.backend;

import sys.io.File;
import ceramic.Files;
import ceramic.Texture;
import haxe.io.Bytes;
import haxe.ui.assets.ImageInfo;
import ceramic.App.app;

using StringTools;

class AssetsImpl extends AssetsBase {
	private override function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void):Void {
		if (Resource.listNames().indexOf(resourceId) == -1) {
			callback(resourceId, null);
		} else {
			var bytes = Resource.getBytes(resourceId);
			imageFromBytes(bytes, callback.bind(resourceId));
		}
	}

	private override function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		var asset = null;
		if (Toolkit.screen.options != null && Toolkit.screen.options.assets != null) {
			asset = Toolkit.screen.options.assets.imageAsset(resourceId);
		}

		//if asset still null check if it's in the scene
		if (asset == null) {
			asset = app.scenes.main.assets.imageAsset(resourceId);
		}

		//still missing? check in the global asset object
		if (asset == null) {
			asset = app.assets.imageAsset(resourceId);
		}

		//final check
		if (asset == null) {
			for (scene in app.scenes.rootScenes) {
				var img = scene.assets.imageAsset(resourceId);
				if (img != null) {
					asset = img;
					break;
				}
			}
		}

		if (asset == null) {
			//trace('ERROR - CANNOT FIND IMAGE RESOURCE $resourceId');
		}
		
		if (asset != null) {
			if (asset.texture != null) {
				callback({
					data: asset.texture,
					width: Std.int(asset.texture.width),
					height: Std.int(asset.texture.height)
				});
			} else {
				asset.owner.onceComplete(null, (suc) -> {
					if (suc) {
						callback({
							data: asset.texture,
							width: Std.int(asset.texture.width),
							height: Std.int(asset.texture.height)
						});
					} else {
						callback(null);
					}
				});
			}
		} else {
			callback(null);
		}
	}

	override function imageFromFile(filename:String, callback:ImageInfo->Void) {
		var bytes = Files.getBytes(filename);
		if (bytes == null) {
			#if (sys || nodejs)
			bytes = File.getBytes(filename);
			#end
		}

		Texture.fromBytes(bytes, (texture) -> {
			if (texture != null) {
				callback({
					data: texture,
					width: Std.int(texture.width),
					height: Std.int(texture.height)
				});
			} else {
				callback(null);
			}
		});
	}

	public override function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void) {
		Texture.fromBytes(bytes, (texture) -> {
			callback({
				data: texture,
				width: Std.int(texture.width),
				height: Std.int(texture.height)
			});
		});
	}
}
