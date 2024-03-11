import { Tile } from "./Tile.js";
import { WallBehavior } from "./TileBehavior.js";
import { BehaviorContextFactory, BehaviorContext, SlideContext, ActivationContext } from "./BehaviorContext.js";

// Defines a Ice Tile Physics Level
export class Level {
    constructor(levelSize, startingPosition){
        // A factory is a way to ensure that only one LevelPoint is generated with the same data
        this.levelPointFactory = new LevelPointFactory(); 
        this.behaviorContextFactory = new BehaviorContextFactory();

        this.levelSize = levelSize;
        this.startingPosition = this.levelPointFactory.getWithProperties(startingPosition.x, startingPosition.y, startingPosition.z, startingPosition.face);
        this.tiles = new Map();        
        this.entities = [];
        
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
                const tileBehavior = isBorder(x, null, z) ? new WallBehavior() : null
                const topPoint = this.levelPointFactory.getWithProperties(x, null, z, Face.top);
                const topTile = new Tile(topPoint, tileBehavior);
                this.tiles.set(topPoint, topTile);
                const bottomPoint = this.levelPointFactory.getWithProperties(x, null, z, Face.bottom);
                const bottomTile = new Tile(bottomPoint, tileBehavior);
                this.tiles.set(bottomPoint, bottomTile);
            }
        }
        // Initialize Front and Back faces which have x and y values for LevelPoints
        for (let x = 0; x < levelSize.x; x += 1) {
            for (let y = 0; y < levelSize.y; y += 1) {
                const tileBehavior = isBorder(x, y, null) ? new WallBehavior() : null
                const frontPoint = this.levelPointFactory.getWithProperties(x, y, null, Face.front);
                const frontTile = new Tile(frontPoint, tileBehavior);
                this.tiles.set(frontPoint, frontTile);
                const backPoint = this.levelPointFactory.getWithProperties(x, y, null, Face.back);
                const backTile = new Tile(backPoint, tileBehavior);
                this.tiles.set(backPoint, backTile);
            }
        }
        // Initialize Left and Right faces which have y and z values for LevelPoints
        for (let y = 0; y < levelSize.y; y += 1) {
            for (let z = 0; z < levelSize.z; z += 1) {
                const tileBehavior = isBorder(null, y, z) ? new WallBehavior() : null
                const leftPoint = this.levelPointFactory.getWithProperties(null, y, z, Face.left);
                const leftTile = new Tile(leftPoint, tileBehavior);
                this.tiles.set(leftPoint, leftTile);
                const rightPoint = this.levelPointFactory.getWithProperties(null, y, z, Face.right);
                const rightTile = new Tile(rightPoint, tileBehavior);
                this.tiles.set(rightPoint, rightTile);                
            }
        }
    }

    insertEntity(entity) {
        this.entities.push(entity);
    }

    adjacentLevelPoint(levelPoint, direction) {
        if (levelPoint.x === null && (direction === Direction.left || direction === Direction.right)) {
            console.error("Cannot slide width-wise when on the Left or Right Face.");
        }
        if (levelPoint.y === null && (direction === Direction.up || direction === Direction.down)) {
            console.error("Cannot slide heighth-wise when on the Top or Bottom Face.");
        }
        if (levelPoint.z === null && (direction === Direction.forward || direction === Direction.backward)) {
            console.error("Cannot slide depth-wise when on the Front or Back Face.");
        }

        // Function that alters the value of the old Level Point when crossing a face
        const newPointOverEdge = function(oldLevelPoint, originFace, destinationFace) {
            let x = oldLevelPoint.x;
            let y = oldLevelPoint.y;
            let z = oldLevelPoint.z;
            // Origin Face dictates the new value of the previous null property
            switch (originFace) {
                case Face.left:
                    x = 0;
                    break;
                case Face.right:
                    x = levelSize.x - 1;
                    break;
                case Face.top:
                    y = 0;
                    break;
                case Face.bottom:
                    y = levelSize.y - 1;
                    break;
                case Face.front:
                    z = 0;
                    break;
                case Face.back:
                    z = levelSize.z - 1;
                    break;
                default:
                    console.error("Invalid Face.");
            }
            // Destination Face determines which value is now null
            switch (destinationFace) {
                case Face.left:
                case Face.right:
                    x = null;
                    break;
                case Face.top:
                case Face.bottom:
                    y = null;
                    break;
                case Face.front:
                case Face.back:
                    z = null;
                    break;
                default:
                    console.error("Invalid Face.");
            }
            return {x: x, y: y, z: z, face: destinationFace};
        };

        switch (direction) {
            case Direction.left: // Decrement X, towards Left Face
                return this.levelPointFactory.getWithLiteral((levelPoint.x - 1 < 0) ? newPointOverEdge(levelPoint, levelPoint.face, Face.left) : {x: levelPoint.x - 1, y: levelPoint.y, z: levelPoint.z, face: levelPoint.face});
            case Direction.right: // Icrement X, towards Right Face
                 return this.levelPointFactory.getWithLiteral((levelPoint.x + 1 >= this.levelSize.x) ? newPointOverEdge(levelPoint, levelPoint.face, Face.right) : {x: levelPoint.x + 1, y: levelPoint.y, z: levelPoint.z, face: levelPoint.face});
            case Direction.up: // Decrement Y, towards Top Face
                return this.levelPointFactory.getWithLiteral((levelPoint.y - 1 < 0) ? newPointOverEdge(levelPoint, levelPoint.face, Face.top) : {x: levelPoint.x, y: levelPoint.y - 1, z: levelPoint.z, face: levelPoint.face});
            case Direction.down: // Increment Y, towards Bottom Face
                return this.levelPointFactory.getWithLiteral((levelPoint.y + 1 >= this.levelSize.y) ? newPointOverEdge(levelPoint, levelPoint.face, Face.bottom) : {x: levelPoint.x, y: levelPoint.y + 1, z: levelPoint.z, face: levelPoint.face});
            case Direction.forward: // Decrement Z, towards Front Face
                return this.levelPointFactory.getWithLiteral((levelPoint.z - 1 < 0) ? newPointOverEdge(levelPoint, levelPoint.face, Face.front) : {x: levelPoint.x, y: levelPoint.y, z: levelPoint.z - 1, face: levelPoint.face});
            case Direction.backward: // Increment Z, towards Back Face
                return this.levelPointFactory.getWithLiteral((levelPoint.z + 1 >= this.levelSize.z) ? newPointOverEdge(levelPoint, levelPoint.face, Face.back) : {x: levelPoint.x, y: levelPoint.y, z: levelPoint.z + 1, face: levelPoint.face});
            case null:
                console.error("Unexpectedly found null when expecting a Direction.");
                break;
            default:
                console.error("Invalid Direction.");
                return null;
        }
    }   

    _activateBehavior(slidingEntities, slideContext) {
        const slideContextOn = this.behaviorContextFactory.getWithProperties(slideContext, ActivationContext.on);
        const slideContextInto = this.behaviorContextFactory.getWithProperties(slideContext, ActivationContext.into);

        slidingEntities.forEach((entity) => { 
            const position = this.levelPointFactory.getWithLiteral(entity.position);
            this.tiles.get(position).behavior.activateBehavior(entity, slideContextOn);
            if (entity.slideDirection !== null) {
                entity.nextPosition = this.adjacentLevelPoint(position, entity.slideDirection);
                this.tiles.get(entity.nextPosition).behavior.activateBehavior(entity, slideContextInto);
            }
        });       
        return slidingEntities.filter(entity => entity.slideDirection !== null);
    }

    calculateSlide(direction) {
        let slidingEntities = this.entities;
        slidingEntities.forEach((entity) => { entity.slideDirection = direction });

        // Start Slide by setting Direction and performing Start Activation
        slidingEntities = this._activateBehavior(slidingEntities, SlideContext.start);        
        
        while (slidingEntities.length > 0) {
            slidingEntities.forEach ((entity) => {
                entity.position = entity.nextPosition;
                entity.nextPosition = null;
            });
            slidingEntities = this._activateBehavior(slidingEntities, SlideContext.slide);
        }
        
    }
}

// Defines a Location within a Level
export class LevelPoint {
    constructor(x, y, z, face){
        this.x = x;
        this.y = y;
        this.z = z;
        this.face = face;
    }    
}

// Factory to access a LevelPoint, saves memory by returning references to already initialized LevelPoints
class LevelPointFactory {
    constructor(){
        this.levelPoints = new Map()
    }    

    getWithProperties(x, y, z, face) {
        const key = `${x},${y},${z},${face}`;
        if (!this.levelPoints.has(key)) {
            const levelPoint = new LevelPoint(x, y, z, face);
            this.levelPoints.set(key, levelPoint);
        }
        return this.levelPoints.get(key);
    }

    getWithLiteral(levelPointLiteral) {
        return this.getWithProperties(levelPointLiteral.x, levelPointLiteral.y, levelPointLiteral.z, levelPointLiteral.face)
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

// Defines the 6 faces of rectangular prism geometry
export const Face = Object.freeze({
    left: "left",
    right: "right",
    top: "top",
    bottom: "bottom",
    front: "front",
    back: "back",
});

// Defines the 6 Directions in which an Enitity can move
export const Direction = Object.freeze({
    left: "left", // Decrement X, towards Left Face
    right: "right", // Icrement X, towards Right Face
    up: "up", // Decrement Y, towards Top Face
    down: "down", // Increment Y, towards Bottom Face
    forward: "forward", // Decrement Z, towards Front Face
    backward: "backward" // Increment Z, towards Back Face
});