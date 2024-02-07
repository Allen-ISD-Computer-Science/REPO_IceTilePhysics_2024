
const canvas = document.getElementById("renderCanvas"); // Get the canvas element
const engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine

function createScene(){
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

    return scene;
}

function play(){
    var scene = createScene();

    engine.runRenderLoop(function(){
	scene.render();	
    });

}

window.addEventListener("resize", function () {
    engine.resize();
});
