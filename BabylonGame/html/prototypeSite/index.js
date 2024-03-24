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

function trackClick(rect, lvlName, grid, worldLabelContainer){
    rect.onPointerUpObservable.add(function(){
        createScene(lvlName)
        clearLevelSelect(grid, worldLabelContainer)
    });
}

function clearLevelSelect(grid, worldLabelContainer){
    grid.dispose()
    worldLabelContainer.dispose()
}

function generateLevels(worldData, worldLabelContainer){
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
            rect.cornerRadius = 10
            rect.paddingBottom = '15px';
            rect.paddingRight = '15px';
            rect.paddingTop = '15px';
            rect.paddingLeft = '15px';
            rect.width = '100px'
            rect.height = '100px'
    
            trackClick(rect, lvlName, grid, worldLabelContainer)
    
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

//create cube function, loads the level
function createCube(back, left, top, right, front, bottom) {
    var traversableTiles = [];

    //cube materials
    var grass = new BABYLON.StandardMaterial("greenMaterial", scene);
    grass.diffuseColor = new BABYLON.Color3(0, 1, 0); // RGB for green

    var red = new BABYLON.StandardMaterial("redMaterial", scene);
    red.diffuseColor = new BABYLON.Color3(1, 0, 0); // RGB for green

    var blue = new BABYLON.StandardMaterial("blueMaterial", scene);
    blue.diffuseColor = new BABYLON.Color3(0, 0, 1);

    var yellow = new BABYLON.StandardMaterial("yellowMaterial", scene);
    yellow.diffuseColor = new BABYLON.Color3(1, 1, 0);

    var purple = new BABYLON.StandardMaterial("purpleMaterial", scene);
    purple.diffuseColor = new BABYLON.Color3(1, 0, 1);

    var teal = new BABYLON.StandardMaterial("tealMaterial", scene);
    teal.diffuseColor = new BABYLON.Color3(0, 1, 1);

    var black = new BABYLON.StandardMaterial("blackMaterial", scene);
    black.diffuseColor = new BABYLON.Color3(0, 0, 0);

    for (i = 0; i < top.length; i++) {
        for (j = 0; j < top[i].length; j++) {
            var tileValue = top[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("topTile", { height: 1, width: 1, depth: 1 }, scene);
            cube.updatable = true;
            cube.position.x = i;
            cube.position.y = 0;
            cube.position.z = -j + top[i].length - 1;
            cube.test = true

            if (tileValue == 0) {
                cube.position.y = cube.position.y + .4

                cube.name = "traversableTop";
                traversableTiles.push(cube);
            }
        }
    }
    for (i = 0; i < left.length; i++) {
        for (j = 0; j < left[i].length; j++) {
            var tileValue = left[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("leftTile")
            cube.updatable = true;

            cube.position.x = 0;
            cube.position.y = -(left.length - 1 - i);
            cube.position.z = left[i].length - 1 - j;
            cube.test = true

            if (tileValue == 0) {
                cube.position.x = cube.position.x - .4

                cube.name = "traversableLeft";
                traversableTiles.push(cube);
            }
        }
    }
    for (i = 0; i < back.length; i++) {
        for (j = 0; j < back[i].length; j++) {
            var tileValue = back[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("backTile")
            cube.updatable = true;

            cube.position.x = i;
            cube.position.y = j - back[i].length + 1;
            cube.position.z = back[i].length - 1;
            cube.test = true
            if (tileValue == 0) {
                cube.position.z = cube.position.z + .4

                cube.name = "traversableBack"
                traversableTiles.push(cube);
            }
        }
    }
    for (i = 0; i < right.length; i++) {
        for (j = 0; j < right[i].length; j++) {
            var tileValue = right[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("rightTile") //right
            cube.updatable = true;

            cube.position.x = right[i].length - 1;
            cube.position.y = -i;
            cube.position.z = right[i].length - 1 - j;
            cube.test = true
            if (tileValue == 0) {
                cube.position.x = cube.position.x + .4
                cube.name = "traversableRight"
                traversableTiles.push(cube);
            }
        }
    }
    for (i = 0; i < front.length; i++) {
        for (j = 0; j < front[i].length; j++) {
            var tileValue = front[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("frontTile")
            cube.updatable = true;

            cube.position.x = i;
            cube.position.y = -j;
            cube.position.z = 0;
            cube.test = true
            if (tileValue == 0) {
                cube.position.z = cube.position.z - .4

                cube.name = "traversableFront";
                traversableTiles.push(cube);
            }
        }
    }
    for (i = 0; i < bottom.length; i++) {
        for (j = 0; j < bottom[i].length; j++) {
            var tileValue = bottom[i][j]
            var cube = BABYLON.MeshBuilder.CreateBox("bottomTile")
            cube.updatable = true;

            cube.position.x = i;
            cube.position.y = -bottom[i].length + 1;
            cube.position.z = j;
            cube.test = true
            if (tileValue == 0) {
                cube.position.y = cube.position.y - .4

                cube.name = "traversableBottom";
                traversableTiles.push(cube);
            }
        }
    }
    for (c = 0; c < traversableTiles.length; c++) {
        if (traversableTiles[c].name == "traversableTop") {
            traversableTiles[c].material = grass;
        } else if (traversableTiles[c].name == "traversableLeft") {
            traversableTiles[c].material = blue;
        } else if (traversableTiles[c].name == "traversableBack") {
            traversableTiles[c].material = yellow;
        } else if (traversableTiles[c].name == "traversableRight") {
            traversableTiles[c].material = purple;
        } else if (traversableTiles[c].name == "traversableFront") {
            traversableTiles[c].material = teal;
        } else if (traversableTiles[c].name == "traversableBottom") {
            traversableTiles[c].material = black
        }
    }

    loop: for (z = 0; z < traversableTiles.length; z++) {
        for (y = 0; y < traversableTiles.length; y++) {
            if (BABYLON.Vector3.DistanceSquared(traversableTiles[y].position, traversableTiles[z].position) < 1.0) {
                if (traversableTiles[y].name == traversableTiles[z].name) continue;
                traversableTiles[y].material = red
                traversableTiles[z].material = red
            }
        }
    }
}


function createScene(level){
    // Creates a basic Babylon Scene object
    const scene = new BABYLON.Scene(engine);  // Creates and positions an Arc Rotating camera
      // Creates a light, aiming 0,1,0 - to the sky
      var camera = new BABYLON.ArcRotateCamera("camera", BABYLON.Tools.ToRadians(50), BABYLON.Tools.ToRadians(65), 20, BABYLON.Vector3.Zero(), scene);
      camera.setTarget(BABYLON.Vector3.Zero());
      camera.attachControl(canvas, true);

      var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 5, 0), scene);
      var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, -5, 0), scene);
      light.intensity = 0.7;
    
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

        levelGrid.dispose()
        fetchWorld(selectedWorld)
            .then(
                worldData => {
                levelGrid = generateLevels(worldData, worldLabelContainer)
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

        levelGrid.dispose()
        fetchWorld(selectedWorld)
            .then(
                worldData => {
                levelGrid = generateLevels(worldData, worldLabelContainer)
                tex.addControl(levelGrid);
            }
        )

        worldLabel.text = worldLabelPrefix.concat((selectedWorld+1).toString())
    });

    fetchWorld(selectedWorld)
    .then(
        worldData => {
            levelGrid = generateLevels(worldData, worldLabelContainer)
            tex.addControl(levelGrid);
        }
    )
    } else {
        // Variable Initialization

        var importedLevel;
        var importedBack;
        var importedLeft;
        var importedTop;
        var importedRight;
        var importedFront;
        var importedBottom;

        var levelDirectory = '../../../IgisLevelEditor/Levels/'.concat(level, ".lvl")
        console.log(levelDirectory)

        // Load level from file

        fetch(levelDirectory)
            .then(response => response.json())
            .then(data => {
                importedLevel = data.face_tiles;

                importedBack = importedLevel[0];
                importedLeft = importedLevel[1];
                importedTop = importedLevel[2];
                importedRight = importedLevel[3];
                importedFront = importedLevel[4];
                importedBottom = importedLevel[5];

                createCube(importedBack, importedLeft, importedTop, importedRight, importedFront, importedBottom)

            })
            .catch(error => console.error('Error loading the JSON file:', error));
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
