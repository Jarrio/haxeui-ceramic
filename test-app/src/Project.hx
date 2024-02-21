package;

import ceramic.Entity;
import ceramic.Color;
import ceramic.InitSettings;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.ComponentBuilder;

class Project extends Entity {
    function new(settings:InitSettings) {
        super();

        settings.antialiasing = 2;
        settings.background = Color.BLACK;
        settings.targetWidth = 640;
        settings.targetHeight = 480;
        settings.scaling = FIT;
        settings.resizable = true;

        app.onceReady(this, ready);
    }

	function ready() {
		Toolkit.init();
		final main = ComponentBuilder.fromFile("../../assets/main.xml");
		Screen.instance.addComponent(main);
    }
}
