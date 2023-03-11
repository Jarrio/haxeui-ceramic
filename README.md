# HaxeUI Ceramic backend
- The cwd for `resources` and `@:build` xmls is `2` levels deep from project root. Add `../../` to your haxeui filepaths 

## How to use
1) [Install ceramic](https://ceramic-engine.com/guides/install-ceramic/#install-ceramic)
2) Open an empty directory and run `ceramic init --name myproject` to create a blank project
3) Open the project in vscode
  a) Install the [ceramic vscode extension](https://marketplace.visualstudio.com/items?itemName=jeremyfa.ceramic) if you haven't got it already
4) Run in the **same** project directory: 
```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib git haxeui-ceramic https://github.com/Jarrio/haxeui-ceramic
```
5) Add the following to your ceramic.yml
```
    libs:
        - haxeui-core
        - haxeui-ceramic
```
6) In your `Project.hx` `ready()` function initialise your haxeui things
```
//put the following code AFTER you call app.scenes.main = new MainScene()
Toolkit.init();
//Toolkit.theme = 'dark';
var haxeui_component = new MyComponent();
Screen.instance.addComponent(haxeui_component);
```

----

Working:
basic 
- buttons
- button bar
- checkboxes
- option boxes
- progress bars
- sliders
- scrollbars
- classic scroll bars
- calendars
- labels
- drop down 
- dropdown
- switches

containers
- tabs
- frames
- scroll views
- table views
- accordian
- cards
- menus
- list view
- tables

layouts
- absolute
- box
- horizontal
- vertial
- grid
- splitter
- spliter

misc
- tooltips
- drag
- animations
- clipping
- images

Not working/Bugged:

- canvas
- number stepper (text alignment)
- tree view (hover)
