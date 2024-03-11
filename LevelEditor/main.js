import { Face, Direction, LevelPoint, LevelSize, Level } from "./Level.js";
import { Entity, Player } from "./Entity.js";
window.addEventListener('load', function(){
    const canvas = this.document.getElementById('canvas1');
    const context = canvas.getContext('2d');
    canvas.width = 700;
    canvas.height = 700;    

    class Editor {
        constructor(width, height){
            this.width = width;
            this.height = height;
            const startingPosition = {x: 1, y: null, z: 3, face: Face.top};
            const levelSize = new LevelSize(5, 5, 5);
            this.level = new Level(levelSize, startingPosition);
            const player = new Player(startingPosition);
            this.level.insertEntity(player);
            this.level.calculateSlide(Direction.forward);
            console.log(player);
        }

        update(){

        }

        draw(){

        }
    }

    const editor = new Editor(canvas.width, canvas.height);
    console.log(editor);
});