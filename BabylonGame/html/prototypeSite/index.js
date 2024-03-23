const root = '../..';
const levelsDir =  root.concat('/IgisLevelEditor/Levels');
const assets = root.concat('/assets')
const textures = assets.concat('/textures/ui/titleScreen');

const canvas = document.getElementById("renderCanvas"); // Get the canvas element
const engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine

var scene;

function fetchWorld(index){
    return new Promise((resolve, reject) => {
        fetch("campaign.json")
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to fetch campaign.json');
                }
                return response.json();
            })
            .then(data => {
                console.log(data.worlds[index].world);
                resolve(data.worlds[index].world);
            })
            .catch(error => {
                console.error('Error loading the JSON file:', error);
                reject(error);
            });
    });
}

function generateLevels(worldData){
        //defining the grid
        const grid = new BABYLON.GUI.Grid();

        grid.height = 0.8;
        grid.width = 0.8;
    // initilizing the grid with its first row
        grid.addRowDefinition(100, true)
    
    
    // lc = level count, will hold the number of levels needing to be displayed
    console.log(worldData)
        var lc = worldData.length;
        var column = 0;
        let columnLimit = 6
        var row = 0;
        var rects = {}
    
        //loops through each level, makes a new rectangle for each
        for (i = 0; i < lc; i++) {
            var rect = new BABYLON.GUI.Button();
            //defines textblock that holds level name, this will be used to detect level user is trying to load
            var lvlName = worldData[i].slice(0, -4)
            var textBlock = new BABYLON.GUI.TextBlock("text_button", lvlName)
            rect.addControl(textBlock)
    
            var color = "blue"
            
    
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
        return grid
}


function createScene(level){
    // Creates a basic Babylon Scene object
    const scene = new BABYLON.Scene(engine);  // Creates and positions an Arc Rotating camera
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 10), scene);  // Targets the camera to scene origin
    camera.setTarget(BABYLON.Vector3.Zero());  // This attaches the camera to the canvas
      // Creates a light, aiming 0,1,0 - to the sky
    const light = new BABYLON.HemisphericLight("light",                                            new BABYLON.Vector3(0, 1, 0), scene);       // Dim the light a small amount - 0 to 1
    light.intensity = 0.7;     
    const box = BABYLON.MeshBuilder.CreateBox("box", { size: 2}, scene);       // Move the sphere upward 1/2 its height
    box.position.y = 1;    
    
    const tex = BABYLON.GUI.AdvancedDynamicTexture.CreateFullscreenUI("myUI");

    // if level is levels, display level select screen
    if (level == "levels") {

    // VARIABLES
    var selectedWorld = 0
    var levelGrid
    const worldLabelPrefix = "WORLD "
    //

	var bg = new BABYLON.GUI.Image(textures.concat('.bg_1.png'))
	bg.width = canvas.width
	bg.height = canvas.height
	
	tex.addControl(bg);	

    //defining world select buttons

    var worldLabelContainer = new BABYLON.GUI.Rectangle("worldLabelContainer");
    var worldLabel = new BABYLON.GUI.TextBlock("world_label", "WORLD 1");

    //container

    
    worldLabelContainer.verticalAlignment = 1;
    worldLabelContainer.width = 0.5;
    worldLabelContainer.thickness = 0;

    //buttons
    const prevButton = BABYLON.GUI.Button.CreateSimpleButton("prev_button", "<") 
    const nextButton = BABYLON.GUI.Button.CreateSimpleButton("next_button", ">")

    nextButton.width = .2;
    nextButton.height = 1;
    prevButton.width = .2;
    prevButton.height = 1;
    prevButton.thickness = 0;
    nextButton.thickness = 0;
    prevButton.textBlock.outlineColor = "white";
    prevButton.textBlock.outlineWidth = 2;
    nextButton.textBlock.outlineColor = "white";
    nextButton.textBlock.outlineWidth = 2;

    prevButton.fontSize = 55
    nextButton.fontSize = 55

    prevButton.horizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_LEFT;
    nextButton.horizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_RIGHT;

    //world label
    worldLabelContainer.height = 0.2;
    worldLabel.outlineColor = "white";
    worldLabel.outlineWidth = 2;
    worldLabel.fontSize = 44

    tex.addControl(worldLabelContainer)
    worldLabelContainer.addControl(worldLabel)
    worldLabelContainer.addControl(nextButton)
    worldLabelContainer.addControl(prevButton)

    //button controls
    nextButton.onPointerUpObservable.add(function(){
        selectedWorld += 1
        if (selectedWorld > 2) {
            selectedWorld = 0
        }

        fetchWorld(selectedWorld)
            .then(
                worldData => {
                var levelGrid = generateLevels(worldData)
                tex.addControl(levelGrid);
            }
        )
        
        worldLabel.text = worldLabelPrefix.concat((selectedWorld+1).toString())
    });

    prevButton.onPointerUpObservable.add(function(){
        selectedWorld -= 1
        if (selectedWorld < 0) {
            selectedWorld = 2
        }

        fetchWorld(selectedWorld)
            .then(
                worldData => {
                var levelGrid = generateLevels(worldData)
                tex.addControl(levelGrid);
            }
        )

        worldLabel.text = worldLabelPrefix.concat((selectedWorld+1).toString())
    });

    fetchWorld(selectedWorld)
    .then(
        worldData => {
            var levelGrid = generateLevels(worldData)
            tex.addControl(levelGrid);
        }
    )
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
