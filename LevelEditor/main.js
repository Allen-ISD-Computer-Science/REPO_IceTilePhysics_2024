import { Face, LevelPoint, LevelSize, Level } from "./Level.js";
window.addEventListener('load', function(){
    const canvas = this.document.getElementById('canvas1');
    const context = canvas.getContext('2d');
    canvas.width = 700;
    canvas.height = 700;    

    class Editor {
        constructor(width, height){
            this.width = width;
            this.height = height;
            const startingPosition = new LevelPoint(1, 1, null, Face.front);
            const levelSize = new LevelSize(5, 5, 5);
            this.level = new Level(levelSize, startingPosition);
        }

        update(){

        }

        draw(){

        }
    }

    const editor = new Editor(canvas.width, canvas.height);
    console.log(editor);
});