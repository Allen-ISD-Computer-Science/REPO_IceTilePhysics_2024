const root = '../..';
const levelsDir =  root.concat('/IgisLevelEditor/Levels');
const assets = root.concat('/assets')
const textures = assets.concat('/textures/ui/titleScreen');

const canvas = document.getElementById("renderCanvas"); // Get the canvas element
const engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine

var scene;

console.log(textures.concat('.bg_1.png'))
console.log(assets)

function createScene(level){
    // Creates a basic Babylon Scene object
    const scene = new BABYLON.Scene(engine);  // Creates and positions an Arc Rotating camera
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 10), scene);  // Targets the camera to scene origin
    camera.setTarget(BABYLON.Vector3.Zero());  // This attaches the camera to the canvas
    camera.attachControl(canvas, true);  // Creates a light, aiming 0,1,0 - to the sky
    const light = new BABYLON.HemisphericLight("light",                                            new BABYLON.Vector3(0, 1, 0), scene);       // Dim the light a small amount - 0 to 1
    light.intensity = 0.7;       // Built-in 'sphere' shape.
    const box = BABYLON.MeshBuilder.CreateBox("box", { size: 2}, scene);       // Move the sphere upward 1/2 its height
    box.position.y = 1;       // Built-in 'ground' shape.
    const ground = BABYLON.MeshBuilder.CreateGround("ground",     { width: 6, height: 6 }, scene);
    const tex = BABYLON.GUI.AdvancedDynamicTexture.CreateFullscreenUI("myUI");

    // if level is levels, display level select screen
    if (level == "levels") {
	var bg = new BABYLON.GUI.Image(textures.concat('.bg_1.png'))
	bg.width = canvas.width
	bg.height = canvas.height
	
	tex.addControl(bg);	

    //defining the grid
    const grid = new BABYLON.GUI.Grid();

    grid.height = 0.8;
    grid.width = 0.8;
// initilizing the grid with its first row
    grid.addRowDefinition(100, true)

// lc = level count, will hold the number of levels needing to be displayed
    var lc = 20;
    var column = 0;
    let columnLimit = 6
    var row = 0;
    var rects = {}

    //loops through each level, makes a new rectangle for each
    for (i = 0; i < lc; i++) {
        var rect = new BABYLON.GUI.Rectangle();
        var color = "blue"
        if (i % 2 == 0) {
            color = "red";
        }

        rect.background = color;
        rect.thickness = 0;
        rect.paddingBottom = '15px';
        rect.paddingRight = '15px';
        rect.paddingTop = '15px';
        rect.paddingLeft = '15px';
        rect.width = '100px'
        rect.height = '100px'
        
        

        if (column < columnLimit) {
            grid.addColumnDefinition(100, true);
        } else {
            grid.addRowDefinition(100, true)
            row++;
            column = 0;
        }

        grid.addControl(rect, row, column);
        column++;
    }
    tex.addControl(grid);
    }

    return scene;
}


function play(){
    if (scene) {
	return;
    }
    scene = createScene("levels");

    engine.runRenderLoop(function(){
	scene.render();	
    });

}

window.addEventListener("resize", function () {
    engine.resize();
});
