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
		if (Resource.listNames().indexOf(resourceId) == -1) {
			callback(resourceId, null);
		} else {
			var bytes = Resource.getBytes(resourceId);
			imageFromBytes(bytes, callback.bind(resourceId));
		}
	}

	private override function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		this.imageFromFile(resourceId, callback);
		// var graphic:Texture = null;
		// //var frame:FlxFrame = null;
		// trace(Assets.all);

		// if (Assets.allByName.exists(resourceId)) {
		// 		graphic = Assets.allByName.get(resourceId);
		// 		frame = FlxImageFrame.fromGraphic(graphic).frame;
		// }

		// if (frame != null) {
		// 		frame.parent.persist = true;
		// 		frame.parent.destroyOnNoUse = false;
		// 		callback({
		// 				data : frame,
		// 				width : Std.int(frame.sourceSize.x),
		// 				height : Std.int(frame.sourceSize.y)
		// 		});
		// } else {
		// 		callback(null);
		// }
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
		// assets.load();
		// 	kha.Assets.loadImageFromPath(filename, false, function( img ) {
		// 			callback({
		// 					data: img,
		// 					width: img.width,
		// 					height: img.height,
		// 			});
		// 	}, function( err ) {
		// 			#if debug trace(err); #end
		// 			callback(null);
		// 	});
	}

	public override function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void) {
		callback(null);
		// #if kha_krom
		// var path = Krom.getFilesLocation()+"file."+extensionFromMagicBytes(bytes);
		// Krom.fileSaveBytes(path,bytes.getData());
		// kha.Assets.loadImageFromPath(path,false, function(image) {
		//     var imageInfo:ImageInfo = {
		//         width: image.realWidth,
		//         height: image.realHeight,
		//         data: image
		//     }
		//     callback(imageInfo);
		// });
		// #else

		// Image.fromEncodedBytes(bytes, extensionFromMagicBytes(bytes), function(image) {
		//     var imageInfo:ImageInfo = {
		//         width: image.realWidth,
		//         height: image.realHeight,
		//         data: image
		//     }
		//     callback(imageInfo);
		// }, function(error) {
		//     trace("Problem loading image: " + error);
		//     callback(null);
		// });
		// #end
	}
}
