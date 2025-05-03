package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Color;
import ceramic.AlphaColor;
import ceramic.BezierEasing;

class RoundedBorder extends Mesh {
	@content public var topLeft:Float = 0;
	@content public var topRight:Float = 0;
	@content public var bottomLeft:Float = 0;
	@content public var bottomRight:Float = 0;

	@content public var thickness:Float = 1;

	@content public var topThickness:Float = 1;
	@content public var rightThickness:Float = 1;
	@content public var bottomThickness:Float = 1;
	@content public var leftThickness:Float = 1;

	@content public var curveSegments:Int = 8;

	@content public var showTop:Bool = true;
	@content public var showRight:Bool = true;
	@content public var showBottom:Bool = true;
	@content public var showLeft:Bool = true;

	@content public var topColor:Color = Color.BLACK;
	@content public var rightColor:Color = Color.BLACK;
	@content public var bottomColor:Color = Color.BLACK;
	@content public var leftColor:Color = Color.BLACK;

	// Bezier curve control points factor (0.55 is a good approximation for circles)
	// See: https://spencermortensen.com/articles/bezier-circle/
	@content public var bezierFactor:Float = 0.55;

	public var radius(default, set):Float;

	function set_radius(value) {
		topLeft = value;
		topRight = value;
		bottomLeft = value;
		bottomRight = value;
		return value;
	}

	public function new(thickness:Float = 1, color:Color = Color.BLACK) {
		super();

		this.thickness = thickness;
		this.topThickness = thickness;
		this.rightThickness = thickness;
		this.bottomThickness = thickness;
		this.leftThickness = thickness;

		this.topColor = color;
		this.rightColor = color;
		this.bottomColor = color;
		this.leftColor = color;

		this.colorMapping = VERTICES;
	}

	override function computeContent() {
		super.computeContent();
		rebuild();
	}

	public function rebuild() {
		if (width <= 0 || height <= 0) {
			return;
		}

		if (thickness <= 0) {
			return;
		}

		vertices = [];
		indices = [];
		colors = [];

		syncThicknesses();

		if (showTop)
			drawBorderSide(BorderSide.TOP, topColor, topThickness);
		if (showRight)
			drawBorderSide(BorderSide.RIGHT, rightColor, rightThickness);
		if (showBottom)
			drawBorderSide(BorderSide.BOTTOM, bottomColor, bottomThickness);
		if (showLeft)
			drawBorderSide(BorderSide.LEFT, leftColor, leftThickness);

		drawCorners();

		if (vertices.length == 0) {
			vertices = [0, 0];
			colors = [new AlphaColor(Color.BLACK, 0)];
		}
	}

	private function syncThicknesses() {
		if (topThickness <= 0)
			topThickness = thickness;
		if (rightThickness <= 0)
			rightThickness = thickness;
		if (bottomThickness <= 0)
			bottomThickness = thickness;
		if (leftThickness <= 0)
			leftThickness = thickness;
	}

	private function drawBorderSide(side:BorderSide, color:Color, sideThickness:Float) {
		var startIndex = Std.int(vertices.length / 2);
		var w = width;
		var h = height;
		var t = sideThickness;

		var maxRadius = Math.min(w / 2, h / 2);
		var tlRadius = Math.min(topLeft, maxRadius);
		var trRadius = Math.min(topRight, maxRadius);
		var blRadius = Math.min(bottomLeft, maxRadius);
		var brRadius = Math.min(bottomRight, maxRadius);

		switch (side) {
			case TOP:
				vertices.push(tlRadius);
				vertices.push(0);

				vertices.push(w - trRadius);
				vertices.push(0);

				vertices.push(w - trRadius);
				vertices.push(t);

				vertices.push(tlRadius);
				vertices.push(t);

			case RIGHT:
				vertices.push(w);
				vertices.push(trRadius);

				vertices.push(w);
				vertices.push(h - brRadius);

				vertices.push(w - t);
				vertices.push(h - brRadius);

				vertices.push(w - t);
				vertices.push(trRadius);

			case BOTTOM:
				vertices.push(w - brRadius);
				vertices.push(h);

				vertices.push(blRadius);
				vertices.push(h);

				vertices.push(blRadius);
				vertices.push(h - t);

				vertices.push(w - brRadius);
				vertices.push(h - t);

			case LEFT:
				vertices.push(0);
				vertices.push(h - blRadius);

				vertices.push(0);
				vertices.push(tlRadius);

				vertices.push(t);
				vertices.push(tlRadius);

				vertices.push(t);
				vertices.push(h - blRadius);
		}

		indices.push(startIndex);
		indices.push(startIndex + 1);
		indices.push(startIndex + 2);

		indices.push(startIndex);
		indices.push(startIndex + 2);
		indices.push(startIndex + 3);

		var alphaColor = color.toAlphaColor();
		colors.push(alphaColor);
		colors.push(alphaColor);
		colors.push(alphaColor);
		colors.push(alphaColor);
	}

	private function drawCorners() {
		var w = width;
		var h = height;

		var maxRadius = Math.min(w / 2, h / 2);
		var tlRadius = Math.min(topLeft, maxRadius);
		var trRadius = Math.min(topRight, maxRadius);
		var brRadius = Math.min(bottomRight, maxRadius);
		var blRadius = Math.min(bottomLeft, maxRadius);

		// Top-left corner
		if (tlRadius > 0) {
			var drawTL = true;
			var tlColor = topColor;
			var tlThickness = topThickness;

			if (!showTop && !showLeft) {
				drawTL = false;
			} else if (!showTop) {
				tlColor = leftColor;
				tlThickness = leftThickness;
			} else if (!showLeft) {
				tlColor = topColor;
				tlThickness = topThickness;
			} else {
				tlThickness = Math.max(topThickness, leftThickness);
				tlColor = (leftThickness > topThickness) ? leftColor : topColor;
			}

			if (drawTL) {
				drawCornerWithTaper(0, 0, tlRadius, Math.PI, Math.PI * 1.5, tlColor, tlThickness, !showLeft, !showTop);
			}
		}

		// Top-right corner
		if (trRadius > 0) {
			var drawTR = true;
			var trColor = topColor;
			var trThickness = topThickness;

			if (!showTop && !showRight) {
				drawTR = false;
			} else if (!showTop) {
				trColor = rightColor;
				trThickness = rightThickness;
			} else if (!showRight) {
				trColor = topColor;
				trThickness = topThickness;
			} else {
				trThickness = Math.max(topThickness, rightThickness);
				trColor = (rightThickness > topThickness) ? rightColor : topColor;
			}

			if (drawTR) {
				drawCornerWithTaper(w, 0, trRadius, Math.PI * 1.5, Math.PI * 2, trColor, trThickness, !showTop, !showRight);
			}
		}

		// Bottom-right corner
		if (brRadius > 0) {
			var drawBR = true;
			var brColor = bottomColor;
			var brThickness = bottomThickness;

			if (!showBottom && !showRight) {
				drawBR = false;
			} else if (!showBottom) {
				brColor = rightColor;
				brThickness = rightThickness;
			} else if (!showRight) {
				brColor = bottomColor;
				brThickness = bottomThickness;
			} else {
				brThickness = Math.max(bottomThickness, rightThickness);
				brColor = (rightThickness > bottomThickness) ? rightColor : bottomColor;
			}

			if (drawBR) {
				drawCornerWithTaper(w, h, brRadius, 0, Math.PI * 0.5, brColor, brThickness, !showRight, !showBottom);
			}
		}

		// Bottom-left corner
		if (blRadius > 0) {
			var drawBL = true;
			var blColor = bottomColor;
			var blThickness = bottomThickness;

			if (!showBottom && !showLeft) {
				drawBL = false;
			} else if (!showBottom) {
				blColor = leftColor;
				blThickness = leftThickness;
			} else if (!showLeft) {
				blColor = bottomColor;
				blThickness = bottomThickness;
			} else {
				blThickness = Math.max(bottomThickness, leftThickness);
				blColor = (leftThickness > bottomThickness) ? leftColor : bottomColor;
			}

			if (drawBL) {
				drawCornerWithTaper(0, h, blRadius, Math.PI * 0.5, Math.PI, blColor, blThickness, !showBottom, !showLeft);
			}
		}
	}

	/**
	 * Draws a corner with optional tapering on one or both ends
	 * @param cx X-coordinate of the corner
	 * @param cy Y-coordinate of the corner
	 * @param radius Corner radius
	 * @param startAngle Start angle in radians
	 * @param endAngle End angle in radians
	 * @param color Corner color
	 * @param cornerThickness Corner thickness
	 * @param taperStart Whether to taper the start of the corner
	 * @param taperEnd Whether to taper the end of the corner
	 */
	private function drawCornerWithTaper(cx:Float, cy:Float, radius:Float, startAngle:Float, endAngle:Float, color:Color, thickness:Float,
			taperStart:Bool, taperEnd:Bool) {
		if (radius <= 0 || thickness <= 0)
			return;

		// Ensure minimum radius
		radius = Math.max(radius, 2.0);

		// Calculate arc center
		var centerX = (cx == 0) ? radius : cx - radius;
		var centerY = (cy == 0) ? radius : cy - radius;

		var segments = Math.round(Math.max(8, Std.int(radius / 2)));
		var alphaColor = color.toAlphaColor();
		var startIdx = Std.int(vertices.length / 2);

		// Pre-calculate points
		var outerPoints = [];
		var innerPoints = [];

		// Calculate angle values
		var angleStep = ((endAngle - startAngle) / segments);

		for (i in 0...segments + 1) {
			var t = i / segments;
			var angle = startAngle + t * (endAngle - startAngle);

			// Calculate thickness with proper easing
			var adjustedThickness = thickness;

			if (taperStart && taperEnd) {
				// Symmetrical peak in middle
				adjustedThickness = thickness * (Math.sin(Math.PI * t));
			} else if (taperStart) {
				// Ease-in
				adjustedThickness = thickness * Math.sin(Math.PI / 2 * t);
			} else if (taperEnd) {
				// Ease-out
				adjustedThickness = thickness * Math.sin(Math.PI / 2 * (1 - t));
			}

			// Outer point
			var outerX = centerX + Math.cos(angle) * radius;
			var outerY = centerY + Math.sin(angle) * radius;
			outerPoints.push({x: outerX, y: outerY});

			// Inner point - ensure no negative radius
			var innerRadius = Math.max(0.1, radius - adjustedThickness);
			var innerX = centerX + Math.cos(angle) * innerRadius;
			var innerY = centerY + Math.sin(angle) * innerRadius;
			innerPoints.push({x: innerX, y: innerY});
		}

		// Add vertices
		for (i in 0...outerPoints.length) {
			vertices.push(outerPoints[i].x);
			vertices.push(outerPoints[i].y);
			colors.push(alphaColor);

			vertices.push(innerPoints[i].x);
			vertices.push(innerPoints[i].y);
			colors.push(alphaColor);
		}

		// Create triangles
		for (i in 0...segments) {
			var baseIdx = startIdx + i * 2;

			indices.push(baseIdx); // outer1
			indices.push(baseIdx + 2); // outer2
			indices.push(baseIdx + 1); // inner1

			indices.push(baseIdx + 1); // inner1
			indices.push(baseIdx + 2); // outer2
			indices.push(baseIdx + 3); // inner2
		}
	}

	public function setBorderSideVisible(side:BorderSide, visible:Bool) {
		switch (side) {
			case TOP:
				showTop = visible;
			case RIGHT:
				showRight = visible;
			case BOTTOM:
				showBottom = visible;
			case LEFT:
				showLeft = visible;
		}
	}

	public function setAllBorders(radius:Float, thickness:Float, color:Color) {
		this.radius = radius;
		this.thickness = thickness;
		this.topThickness = thickness;
		this.rightThickness = thickness;
		this.bottomThickness = thickness;
		this.leftThickness = thickness;

		setAllBordersColor(color);
		setAllBordersVisible(true);
		rebuild();
	}

	public function setBorderSideColor(side:BorderSide, color:Color) {
		switch (side) {
			case TOP:
				topColor = color;
			case RIGHT:
				rightColor = color;
			case BOTTOM:
				bottomColor = color;
			case LEFT:
				leftColor = color;
		}
	}

	public function setBorderSideThickness(side:BorderSide, thickness:Float) {
		switch (side) {
			case TOP:
				topThickness = thickness;
				if (thickness > 0)
					showTop = true;
			case RIGHT:
				rightThickness = thickness;
				if (thickness > 0)
					showRight = true;
			case BOTTOM:
				bottomThickness = thickness;
				if (thickness > 0)
					showBottom = true;
			case LEFT:
				leftThickness = thickness;
				if (thickness > 0)
					showLeft = true;
		}
	}

	public function setAllBordersVisible(visible:Bool) {
		showTop = visible;
		showRight = visible;
		showBottom = visible;
		showLeft = visible;
	}

	public function setAllBordersColor(color:Color) {
		topColor = color;
		rightColor = color;
		bottomColor = color;
		leftColor = color;
	}

	public function setCurveQuality(segments:Int) {
		if (segments < 4)
			segments = 4; // Minimum quality
		if (segments > 32)
			segments = 32; // Reasonable maximum

		this.curveSegments = segments;
	}
}

enum BorderSide {
	TOP;
	RIGHT;
	BOTTOM;
	LEFT;
}
