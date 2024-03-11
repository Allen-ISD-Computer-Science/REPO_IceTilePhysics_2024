import { TileStatus } from "./TileStatus.js";
import { TileBehavior } from "./TileBehavior.js";

// Defines a Single Tile within a Level
export class Tile {
    
    constructor(point, behavior = null){
        this.point = point;
        this.status = new TileStatus();
        this.behavior = (behavior == null) ? new TileBehavior() : behavior;    
    }

}