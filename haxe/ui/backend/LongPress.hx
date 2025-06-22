package haxe.ui.backend;

import ceramic.Component;
import ceramic.Entity;
import ceramic.Screen;
import ceramic.TouchInfo;
import ceramic.Click;
import ceramic.Timer;
import ceramic.Shortcuts.*;

// Basically ceramic.LongPress but only works on touch and operates on screen instead of a ceramic entity
class LongPress extends Entity implements Component {
	// Events
    @event function longPress(info:TouchInfo);
	
	// Properties
    public var threshold = 4.0;
    public var requiredDuration = 0.5;
    public var entity:Screen;
    public var click:Click;

	// Lifecycle
    public function new(?handleLongPress:TouchInfo->Void, ?click:Click) {
        super();
        this.click = click;

        if (handleLongPress != null) {
            onLongPress(null, handleLongPress);
        }
    }

    function bindAsComponent() {
        // Bind pointer events
        bindTouchEvents();
    }

	// Internal
    var pointerStartX = 0.0;
    var pointerStartY = 0.0;
    var didLongPress = false;
    var cancelLongPress:Void->Void = null;

    function bindTouchEvents() {
        entity.onTouchDown(this, handleTouchDown);
        entity.onTouchUp(this, handleTouchUp);
    }

    function handleTouchDown(touchIndex:Int, x:Float, y:Float) {
        didLongPress = false;

        pointerStartX = screen.pointerX;
        pointerStartY = screen.pointerY;

        screen.onTouchMove(this, handleTouchMove);

        cancelLongPress = Timer.delay(this, requiredDuration, function() {
            cancelLongPress = null;
            didLongPress = true;

            if (click != null) {
                click.cancel();
            }

            emitLongPress({touchIndex: touchIndex, x: x, y: y, buttonId: -1, hits: true});
        });
    }

    function handleTouchMove(touchIndex:Int, x:Float, y:Float) {
        if (Math.abs(screen.pointerX - pointerStartX) > threshold || Math.abs(screen.pointerY - pointerStartY) > threshold) {
            screen.offTouchMove(handleTouchMove);
            if (cancelLongPress != null) {
                cancelLongPress();
                cancelLongPress = null;
            }
        }
    }

    function handleTouchUp(touchIndex:Int, x:Float, y:Float) {
        if (cancelLongPress != null) {
            cancelLongPress();
            cancelLongPress = null;
        }
        screen.offTouchMove(handleTouchMove);
    }
}
