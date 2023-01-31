package haxe.ui.backend.ceramic;

import ceramic.Line;
import ceramic.Quad;
import ceramic.Visual;
import ceramic.Texture;
import haxe.ui.Toolkit;
import haxe.ui.assets.ImageInfo;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Slice9;
import haxe.ui.styles.Style;

class StyleHelper {
	public static function apply(c:ComponentImpl, style:Style, w:Float, h:Float):Void {
		if (w <= 0 || h <= 0) {
			return;
		}

		var container = c._surface.children[0]; // first child is always the style-objects container
		if (container == null) {
			return; // fix crash resizing the window; container doesn't exist yet
		}

		var borderSize:Rectangle = new Rectangle();
		var backgroundAlpha:Float = 1;
		if (style.backgroundOpacity != null) {
			backgroundAlpha = style.backgroundOpacity;
		}
		var borderAlpha:Float = 1;
		if (style.borderOpacity != null) {
			borderAlpha = style.borderOpacity;
		}

		var styleGraphics:Quad = null;
		if (container.children.length == 0) {
			styleGraphics = new Quad();
			c.children.insert(0, styleGraphics);
		} else {
			styleGraphics = cast(container.children[0], Quad);
		}
		styleGraphics.clear();

		var borderRadius:Float = 0;
		if (style.borderRadius != null && style.borderRadius > 0) {
			borderRadius = style.borderRadius + 1;
		}
		if (style.backgroundColor != null) {
			if (style.backgroundColorEnd != null && style.backgroundColor != style.backgroundColorEnd) {
				var gradientType:String = "vertical";
				if (style.backgroundGradientStyle != null) {
					gradientType = style.backgroundGradientStyle;
				}

				var gradientSize = 256;
				// if (gradientType == "vertical" || gradientType == "horizontal") {
				//     var tile = TileCache.getGradient(gradientType, style.backgroundColor, style.backgroundColorEnd, gradientSize);
				//     styleGraphics.beginTileFill(0, 0, w / gradientSize, h / gradientSize, tile);
				//     if (borderRadius > 0) {
				//         styleGraphics.lineStyle(style.borderLeftSize * Toolkit.scaleX, style.borderLeftColor, borderAlpha);
				//     }
				//     drawRoundedRect(styleGraphics, 0, 0, w, h, borderRadius, 100);
				//     styleGraphics.endFill();
				// }
			} else {
				styleGraphics.color = style.backgroundColor;
				// styleGraphics.alpha = style.backgroundAlpha;
				// styleGraphics.beginFill(style.backgroundColor, backgroundAlpha);
				// if (borderRadius > 0) {
				//     styleGraphics.lineStyle(style.borderLeftSize * Toolkit.scaleX, style.borderLeftColor, borderAlpha);
				// }
				// drawRoundedRect(styleGraphics, 0, 0, w, h, borderRadius, 100);
				// styleGraphics.endFill();
			}
		}

		if (style.backgroundImage != null) {
			Toolkit.assets.getImage(style.backgroundImage, function(imageInfo:ImageInfo) {
				// var bgImageGraphics:Graphics = null;
				// if (container.numChildren == 1) {
				//     bgImageGraphics = new Graphics();
				//     container.addChildAt(bgImageGraphics, 1);
				// } else {
				//     bgImageGraphics = cast(container.getChildAt(1), Graphics);
				// }
				// bgImageGraphics.clear();

				// var tile = TileCache.get(style.backgroundImage);
				// if (tile == null) {
				//     tile = TileCache.set(style.backgroundImage, h2d.Tile.fromBitmap(imageInfo.data));
				// }

				// var trc:Rectangle = new Rectangle(0, 0, imageInfo.width, imageInfo.height);
				// if (style.backgroundImageClipTop != null
				//     && style.backgroundImageClipLeft != null
				//     && style.backgroundImageClipBottom != null
				//     && style.backgroundImageClipRight != null) {
				//         trc = new Rectangle(style.backgroundImageClipLeft,
				//                             style.backgroundImageClipTop,
				//                             style.backgroundImageClipRight - style.backgroundImageClipLeft,
				//                             style.backgroundImageClipBottom - style.backgroundImageClipTop);
				// }

				// var slice:Rectangle = null;
				// if (style.backgroundImageSliceTop != null
				//     && style.backgroundImageSliceLeft != null
				//     && style.backgroundImageSliceBottom != null
				//     && style.backgroundImageSliceRight != null) {
				//     slice = new Rectangle(style.backgroundImageSliceLeft,
				//                           style.backgroundImageSliceTop,
				//                           style.backgroundImageSliceRight - style.backgroundImageSliceLeft,
				//                           style.backgroundImageSliceBottom - style.backgroundImageSliceTop);
				// }

				// if (trc != null) {
				//     tile = tile.sub(trc.left, trc.top, trc.width, trc.height);
				// }
				// if (slice != null) {
				//     var rects:Slice9Rects = Slice9.buildRects(w, h, trc.width, trc.height, slice);
				//     var srcRects:Array<Rectangle> = rects.src;
				//     var dstRects:Array<Rectangle> = rects.dst;

				//     paintTile(bgImageGraphics, tile, srcRects[0], dstRects[0]);
				//     paintTile(bgImageGraphics, tile, srcRects[1], dstRects[1]);
				//     paintTile(bgImageGraphics, tile, srcRects[2], dstRects[2]);

				//     srcRects[3].bottom--;
				//     paintTile(bgImageGraphics, tile, srcRects[3], dstRects[3]);

				//     srcRects[4].bottom--;
				//     paintTile(bgImageGraphics, tile, srcRects[4], dstRects[4]);

				//     srcRects[5].bottom--;
				//     paintTile(bgImageGraphics, tile, srcRects[5], dstRects[5]);

				//     dstRects[6].bottom++;
				//     paintTile(bgImageGraphics, tile, srcRects[6], dstRects[6]);
				//     dstRects[7].bottom++;
				//     paintTile(bgImageGraphics, tile, srcRects[7], dstRects[7]);
				//     dstRects[8].bottom++;
				//     paintTile(bgImageGraphics, tile, srcRects[8], dstRects[8]);
				// } else {
				//     paintTile(bgImageGraphics, tile, trc, new Rectangle(0, 0, w, h));
				// }
			});
		}

		borderSize.left = style.borderLeftSize * Toolkit.scaleX;
		borderSize.top = style.borderTopSize * Toolkit.scaleY;
		borderSize.right = style.borderRightSize * Toolkit.scaleX;
		borderSize.bottom = style.borderBottomSize * Toolkit.scaleY;
		if (style.borderLeftColor != null
			&& style.borderLeftColor == style.borderRightColor
			&& style.borderLeftColor == style.borderBottomColor
			&& style.borderLeftColor == style.borderTopColor

			&& style.borderLeftSize != null
			&& style.borderLeftSize == style.borderRightSize
			&& style.borderLeftSize == style.borderBottomSize
			&& style.borderLeftSize == style.borderTopSize) { // full border
			var left = new Line();
			left.color = style.borderLeftColor;
			// left.alpha = style.borderAlpha;
			// styleGraphics.lineStyle();
			// styleGraphics.beginFill(style.borderLeftColor, borderAlpha);
			// styleGraphics.drawRect(borderRadius, 0 - Std.int(borderSize.left / 2), w - borderRadius * 2, borderSize.left); // top
			// styleGraphics.drawRect(w - borderSize.left + Std.int(borderSize.left / 2), borderRadius, borderSize.left, h - borderRadius * 2); // right
			// styleGraphics.drawRect(borderRadius, h - borderSize.left + Std.int(borderSize.left / 2), w - borderRadius * 2, borderSize.left); // bottom
			// styleGraphics.drawRect(0 - Std.int(borderSize.left / 2), borderRadius, borderSize.left, h - borderRadius * 2); // left
			// styleGraphics.endFill();
		} else { // compound border
			if (style.borderLeftSize != null && style.borderLeftSize > 0) {
				// styleGraphics.lineStyle();
				// styleGraphics.beginFill(style.borderLeftColor, borderAlpha);
				// //styleGraphics.drawRect(0, 0, borderSize.left, h); // left
				// styleGraphics.drawRect(0 - Std.int(borderSize.left / 2), borderRadius, borderSize.left, h - borderRadius * 2); // left
				// styleGraphics.endFill();
			}

			if (style.borderRightSize != null && style.borderRightSize > 0) {
				// styleGraphics.lineStyle();
				// styleGraphics.beginFill(style.borderRightColor, borderAlpha);
				// styleGraphics.drawRect(w - borderSize.right, borderSize.right, borderSize.right, h - 1); // right
				// styleGraphics.endFill();
			}

			if (style.borderTopSize != null && style.borderTopSize > 0) {
				// styleGraphics.lineStyle();
				// styleGraphics.beginFill(style.borderTopColor, borderAlpha);
				// styleGraphics.drawRect(0, 0, w, borderSize.top); // top
				// styleGraphics.endFill();
			}

			if (style.borderBottomSize != null && style.borderBottomSize > 0) {
				// styleGraphics.lineStyle();
				// styleGraphics.beginFill(style.borderBottomColor, borderAlpha);
				// styleGraphics.drawRect(borderSize.left, h - borderSize.bottom, w - (borderSize.left + borderSize.right), borderSize.bottom); // bottom
				// styleGraphics.endFill();
			}
		}
	}
	// private static function paintTile(g:Graphics, tile:Tile, src:Rectangle, dst:Rectangle) {
	// var scaleX = dst.width / src.width;
	// var scaleY = dst.height / src.height;
	// var sub = tile.sub(src.left * scaleX, src.top * scaleY, src.width, src.height);
	// g.beginTileFill(dst.left, dst.top, scaleX, scaleY, sub);
	// g.drawRect(dst.left, dst.top, dst.width, dst.height);
	// g.endFill();
	// }
	// copy of draw round rect without lines as it seems to misdraw (at different scales - strange)
}
