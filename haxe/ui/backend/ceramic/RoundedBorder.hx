package haxe.ui.backend.ceramic;

import ceramic.Mesh;
import ceramic.Color;
import ceramic.AlphaColor;

class RoundedBorder extends Mesh {
	@content public var topLeft:Float = 0;
	@content public var topRight:Float = 0;
	@content public var bottomLeft:Float = 0;
	@content public var bottomRight:Float = 0;

	@content public var thickness:Float;

	@content public var topThickness:Float = 1;
	@content public var rightThickness:Float = 1;
	@content public var bottomThickness:Float = 1;
	@content public var leftThickness:Float = 1;

	public var segments:Int = 10;

	@content public var showTop:Bool = true;
	@content public var showRight:Bool = true;
	@content public var showBottom:Bool = true;
	@content public var showLeft:Bool = true;

	@content public var topColor:Color = Color.BLACK;
	@content public var rightColor:Color = Color.BLACK;
	@content public var bottomColor:Color = Color.BLACK;
	@content public var leftColor:Color = Color.BLACK;

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
			//trace('Invalid dimensions: ${width}x${height}');
			return;
		}

		if (thickness <= 0) {
			//trace('Invalid thickness: ${thickness}');
			return;
		}

		// trace(
		// 	'thickness: main=${thickness}, top=${topThickness}, right=${rightThickness}, bottom=${bottomThickness}, left=${leftThickness}'
		// );

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

		// trace('Drawing side: ${side}, thickness: ${t}, color: ${color}');

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

		var tlColor = showTop ? topColor : (showLeft ? leftColor : Color.BLACK);
		var trColor = showTop ? topColor : (showRight ? rightColor : Color.BLACK);
		var brColor = showBottom ? bottomColor : (showRight ? rightColor : Color.BLACK);
		var blColor = showBottom ? bottomColor : (showLeft ? leftColor : Color.BLACK);

		var tlThickness = Math.max(topThickness, leftThickness);
		var trThickness = Math.max(topThickness, rightThickness);
		var brThickness = Math.max(bottomThickness, rightThickness);
		var blThickness = Math.max(bottomThickness, leftThickness);

		if (tlRadius > 0 && (showTop || showLeft))
			drawCornerArc(0, 0, tlRadius, Math.PI, Math.PI * 1.5, tlColor, tlThickness);

		if (trRadius > 0 && (showTop || showRight))
			drawCornerArc(w, 0, trRadius, Math.PI * 1.5, Math.PI * 2, trColor, trThickness);

		if (brRadius > 0 && (showBottom || showRight))
			drawCornerArc(w, h, brRadius, 0, Math.PI * 0.5, brColor, brThickness);

		if (blRadius > 0 && (showBottom || showLeft))
			drawCornerArc(0, h, blRadius, Math.PI * 0.5, Math.PI, blColor, blThickness);
	}

	private function drawCornerArc(cx:Float, cy:Float, radius:Float, startAngle:Float, endAngle:Float, color:Color, cornerThickness:Float) {
		if (radius <= 0)
			return;

		var innerRadius = Math.max(0, radius - cornerThickness);

		var arcCenterX:Float;
		var arcCenterY:Float;

		if (cx == 0 && cy == 0) {
			arcCenterX = radius;
			arcCenterY = radius;
		} else if (cx > 0 && cy == 0) {
			arcCenterX = cx - radius;
			arcCenterY = radius;
		} else if (cx > 0 && cy > 0) {
			arcCenterX = cx - radius;
			arcCenterY = cy - radius;
		} else {
			arcCenterX = radius;
			arcCenterY = cy - radius;
		}

		var angleStep = (endAngle - startAngle) / segments;
		var startIdx = Std.int(vertices.length / 2);
		var alphaColor = color.toAlphaColor();

		for (i in 0...segments + 1) {
			var angle = startAngle + i * angleStep;

			var outerX = arcCenterX + Math.cos(angle) * radius;
			var outerY = arcCenterY + Math.sin(angle) * radius;
			vertices.push(outerX);
			vertices.push(outerY);
			colors.push(alphaColor);

			var innerX = arcCenterX + Math.cos(angle) * innerRadius;
			var innerY = arcCenterY + Math.sin(angle) * innerRadius;
			vertices.push(innerX);
			vertices.push(innerY);
			colors.push(alphaColor);

			if (i > 0) {
				indices.push(startIdx + (i - 1) * 2);
				indices.push(startIdx + i * 2);
				indices.push(startIdx + (i - 1) * 2 + 1);

				indices.push(startIdx + (i - 1) * 2 + 1);
				indices.push(startIdx + i * 2);
				indices.push(startIdx + i * 2 + 1);
			}
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
}

enum BorderSide {
	TOP;
	RIGHT;
	BOTTOM;
	LEFT;
}
