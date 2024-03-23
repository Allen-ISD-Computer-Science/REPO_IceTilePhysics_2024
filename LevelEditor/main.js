import { Editor } from "./Editor.js";
import { LevelPoint } from "./Level.js";
import { Face } from "./Face.js";
import * as TileBehavior from "./TileBehavior.js";

const canvas = document.getElementById('canvas');
const editor = new Editor();
const engine = new BABYLON.Engine(canvas, true);

const createScene = function(editor) {
    const scene = new BABYLON.Scene(engine);
    scene.editor = editor;
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 10, BABYLON.Vector3.Zero(), scene);
    camera.attachControl(canvas, true);
    var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 10, 0), scene);
    var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, -10, 0), scene);
    const tilesMeshes = [];

    const defaultColor = new BABYLON.Color3(0, 0, 0);
    const defaultFaceColors = [
        new BABYLON.Color4(0, 0, 1, 1),
        new BABYLON.Color4(0, 1, 0, 1),
        new BABYLON.Color4(1, 0, 0, 1),
        new BABYLON.Color4(1, 0, 1, 1),
        new BABYLON.Color4(1, 1, 0, 1),
        new BABYLON.Color4(0, 1, 1, 1)
    ];

    function coordinateToLevelPoint(x, y, z, faceIndex) {
        switch (faceIndex) {
            case 0: return new LevelPoint(x, y, null, Face.front);
            case 1: return new LevelPoint(x, y, null, Face.back);
            case 2: return new LevelPoint(null, y, z, Face.right);
            case 3: return new LevelPoint(null, y, z, Face.left);
            case 4: return new LevelPoint(x, null, z, Face.top);
            case 5: return new LevelPoint(x, null, z, Face.bottom);
            default: console.error("Unexpected faceIndex");
        }
    }

    for (let x = 0; x < editor.level.levelSize.x; x ++) {
        for (let y = 0; y < editor.level.levelSize.y; y++) {
            for (let z = 0; z < editor.level.levelSize.z; z++) {
                const facesOfCoordinate = editor.level.facesOfCoordinate(x, y, z);
                // Check if we should create a box if the faces array has any true values
                if (facesOfCoordinate.filter(isFaceBorder => isFaceBorder).length  > 0) {
                    const faceColors = [];
                    for (let i = 0; i < facesOfCoordinate.length; i++) {
                        if (facesOfCoordinate[i] === true) {
                            const levelPoint = coordinateToLevelPoint(x, y, z, i);
                            const tile = editor.level.getTile(levelPoint);
                            switch (tile.behavior.name) {
                                case "wall": 
                                    faceColors.push(new BABYLON.Color4(0, 0, 0, 1));
                                    break;
                                case "bend": 
                                    faceColors.push(new BABYLON.Color4(.5, .5, 1, 1));
                                    break;
                                default: faceColors.push(defaultFaceColors[i]);
                            }
                        } else {
                            faceColors.push(defaultColor)
                        }
                    }
                    const box = BABYLON.MeshBuilder.CreateBox(`${x},${y},${z}`, {
                        size: 1,
                        faceColors: faceColors
                    }, scene)
                    box.position = new BABYLON.Vector3(x, -y, -z);
                    box.enableEdgesRendering();  
                    box.edgesWidth = 4.0;   
                    box.edgesColor = new BABYLON.Color4(0, 0, 0, 1);
                }
            }
        }
    }
    return scene;
}

const scene = createScene(editor);

engine.runRenderLoop(() => {
    scene.render();
})

window.addEventListener('resize', () => {
    engine.resize();
});

// Add pointer down event to detect clicks on the scene
scene.onPointerDown = function (evt, pickResult) {
    function faceClicked(normal) {
        if (normal.x === 1) {
            return Face.right;
        } else if (normal.x === -1) {
            return Face.left;
        } else if (normal.y === 1) {
            return Face.top;
        } else if (normal.y === -1) {
            return Face.bottom;
        } else if (normal.z === 1) {
            return Face.back;
        } else if (normal.z === -1) {
            return Face.front;
        }
    }
    // Check if any mesh was clicked
    if (pickResult.hit) {
        const pickedMesh = pickResult.pickedMesh;
        const normal = pickResult.getNormal(true);
        console.log(faceClicked(normal));
        console.log(pickedMesh.position);
        // Perform actions based on the picked mesh
        // For example, changing the color of the clicked box
        if (pickedMesh === scene.box) {
            pickedMesh.material = new BABYLON.StandardMaterial("material", scene);
            pickedMesh.material.diffuseColor = new BABYLON.Color3(Math.random(), Math.random(), Math.random());
        }
    }
};