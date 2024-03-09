var createScene = function () {

    var scene = new BABYLON.Scene(engine);
    var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
    camera.setTarget(BABYLON.Vector3.Zero());
    camera.attachControl(canvas, true);
    var hemiLight = new BABYLON.HemisphericLight("hemiLight", new BABYLON.Vector3(0, 1, 0), scene);

    // 0 = Wall, 1 = Ground, 2 = Portal (WIP)
    // Property Order = Height,
    var properties = [
        [.8],
        [1],
    ];

    var cubeSize = 1;

    // Face Order: Back, Left, Top, Right, Front, Bottom

    var faceBack = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    var faceLeft = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    var faceTop = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    var faceRight = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    var faceFront = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    var faceBottom = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
    ];

    function createFace(array, scene, offSet) {
        for (var i = 0; i < array.length; i++) {
            for (var j = 0; j < array[i].length; j++) {
                var tileValue = array[i][j]

                var height = properties[tileValue][0]
                var cube = BABYLON.MeshBuilder.CreateBox("cube", { height: height, width: cubeSize, depth: cubeSize }, scene);
                cube.position.x = i + offSet;
                cube.position.y = height / 2;
                cube.position.z = j;

            }
        }
    }

    createFace(faceBack, scene, 0)
    createFace(faceLeft, scene, 7)
    createFace(faceTop, scene, 14)
    createFace(faceRight, scene, 21)
    createFace(faceFront, scene, 28)
    createFace(faceBottom, scene, 35)

    return scene;
};
