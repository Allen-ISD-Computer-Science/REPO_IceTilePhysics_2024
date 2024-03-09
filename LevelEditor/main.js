import { Face, Direction, LevelPoint, LevelSize, Level } from "./Level.js";
window.addEventListener('load', function(){
    const canvas = this.document.getElementById('canvas1');
    const context = canvas.getContext('2d');
    canvas.width = 700;
    canvas.height = 700;    

    class Editor {
        constructor(width, height){
            this.width = width;
            this.height = height;
            const startingPosition = new LevelPoint(4, null, 4, Face.top);
            const levelSize = new LevelSize(5, 5, 5);
            this.level = new Level(levelSize, startingPosition);
            console.log(this.level.adjacentLevelPoint(this.level.startingPosition, Direction.backward))
        }

        update(){

        }

        draw(){

        }
    }

    const editor = new Editor(canvas.width, canvas.height);
    console.log(editor);
});