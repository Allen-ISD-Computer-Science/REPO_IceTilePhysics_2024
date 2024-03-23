import { Direction } from "./Direction.js";
import { Face } from "./Face.js";
import { LevelPoint, LevelSize, Level } from "./Level.js";
import { TileBehavior, WallBehavior, BendBehavior, PortalBehavior } from "./TileBehavior.js";
import { Entity, Player } from "./Entity.js";

export class Editor {
    constructor(){
        const startingPosition = new LevelPoint(1, null, 3, Face.top);
        const levelSize = new LevelSize(5, 5, 5);
        this.level = new Level(levelSize, startingPosition);
        const player = new Player(startingPosition);
        this.level.insertEntity(player);
        this.level.setTileBehavior(new BendBehavior(Direction.backward, Direction.left), new LevelPoint(1, null, 1, Face.top));
        this.level.setTileBehavior(new TileBehavior(), new LevelPoint(0, null, 1, Face.top));
        this.level.setTileBehavior(new TileBehavior(), new LevelPoint(null, 0, 1, Face.left));
        const portalDestinationTile = this.level.getTile(new LevelPoint(null, 3, 3, Face.right));
        console.log(portalDestinationTile);
        this.level.setTileBehavior(new PortalBehavior(portalDestinationTile, Direction.up), new LevelPoint(null, 3, 1, Face.left));
        this.level.calculateSlide(Direction.forward);
        console.log(player);
    }

    update(){

    }

    draw(){

    }
}