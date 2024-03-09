import { Tile } from "./Tile.js";
import { WallBehavior } from "./TileBehavior.js";

// Defines a Ice Tile Physics Level
export class Level {
    constructor(levelSize, startingPosition){
        this.levelSize = levelSize;
        this.startingPosition = startingPosition;
        this.tiles = new Map();        
        
        function isBorder(x, y, z) {
            // Check the X-axis Border
            if (x !== null && (x === 0 || x === levelSize.x - 1)) {
                return true;
            }
        
            // Check the Y-axis Border
            if (y !== null && (y === 0 || y === levelSize.y - 1)) {
                return true;
            }
        
            // Check the Z-axis Border
            if (z !== null && (z === 0 || z === levelSize.z - 1)) {
                return true;
            }
            
            return false; // The Point is not on a Border
        }
        

        // Initialize Top and Bottom faces which have x and z values for LevelPoints
        for (let x = 0; x < levelSize.x; x += 1) {
            for (let z = 0; z < levelSize.z; z += 1) {
                let tileBehavior = isBorder(x, null, z) ? new WallBehavior() : null
                const topPoint = new LevelPoint(x, null, z, Face.top);
                const topTile = new Tile(topPoint, tileBehavior);
                this.tiles.set(topPoint, topTile);
                const bottomPoint = new LevelPoint(x, null, z, Face.bottom);
                const bottomTile = new Tile(bottomPoint, tileBehavior);
                this.tiles.set(bottomPoint, bottomTile);
            }
        }

        // Initialize Front and Back faces which have x and y values for LevelPoints
        for (let x = 0; x < levelSize.x; x += 1) {
            for (let y = 0; y < levelSize.y; y += 1) {
                let tileBehavior = isBorder(x, y, null) ? new WallBehavior() : null
                const frontPoint = new LevelPoint(x, y, null, Face.front);
                const frontTile = new Tile(frontPoint, tileBehavior);
                this.tiles.set(frontPoint, frontTile);
                const backPoint = new LevelPoint(x, y, null, Face.back);
                const backTile = new Tile(backPoint, tileBehavior);
                this.tiles.set(backPoint, backTile);
            }
        }

        // Initialize Left and Right faces which have y and z values for LevelPoints
        for (let y = 0; y < levelSize.y; y += 1) {
            for (let z = 0; z < levelSize.z; z += 1) {
                let tileBehavior = isBorder(null, y, z) ? new WallBehavior() : null
                const leftPoint = new LevelPoint(null, y, z, Face.left);
                const leftTile = new Tile(leftPoint, tileBehavior);
                this.tiles.set(leftPoint, leftTile);
                const rightPoint = new LevelPoint(null, y, z, Face.right);
                const rightTile = new Tile(rightPoint, tileBehavior);
                this.tiles.set(rightPoint, rightTile);                
            }
        }
    }
}

export const Face = Object.freeze({
    top: "top",
    bottom: "bottom",
    left: "left",
    right: "right",
    front: "front",
    back: "back",
});

// Defines a Location within a Level
export class LevelPoint {
    constructor(x, y, z, face){
        this.x = x;
        this.y = y;
        this.z = z;
        this.face = face;
    }    
}

// Defines the count of tiles within each particular 3D axis
export class LevelSize {
    constructor(x, y, z){
        this.x = x;
        this.y = y;
        this.z = z;
    }
}