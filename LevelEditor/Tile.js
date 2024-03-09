import { TileAccessibility } from "./TileAccessibility.js";
import { TileBehavior } from "./TileBehavior.js";

// Defines a Single Tile within a Level
export class Tile {
    
    constructor(point, behavior = null){
        this.point = point;
        this.accessibility = TileAccessibility.unaccessible;
        this.behavior = (behavior == null) ? new TileBehavior() : behavior;    
    }

}