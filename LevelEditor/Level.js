import { Direction } from "./Direction.js";
import { Face, getOppositeFace } from "./Face.js";
import { Tile } from "./Tile.js";
import { WallBehavior } from "./TileBehavior.js";
import { BehaviorContextFactory, BehaviorContext, SlideContext, ActivationContext } from "./BehaviorContext.js";

// Defines a Ice Tile Physics Level
export class Level {
    constructor(levelSize, startingPosition){
        // A factory is a way to ensure that only one LevelPoint/Behavior Context is generated with the same data
        this.levelPointFactory = new LevelPointFactory(); 
        this.behaviorContextFactory = new BehaviorContextFactory();

        this.levelSize = levelSize;
        this.startingPosition = this.levelPointFactory.get(startingPosition);
        this.tiles = new Map();        
        this.entities = [];
        
        // Initialize Top and Bottom faces which have x and z values for LevelPoints
        for (let x = 0; x < levelSize.x; x += 1) {
            for (let z = 0; z < levelSize.z; z += 1) {    
                const tileBehavior = this.isFaceBorder(x, null, z) ? new WallBehavior() : null
                const topPoint = this.levelPointFactory.get(new LevelPoint(x, null, z, Face.top));
                const topTile = new Tile(topPoint, tileBehavior);
                this.tiles.set(topPoint, topTile);
                const bottomPoint = this.levelPointFactory.get(new LevelPoint(x, null, z, Face.bottom));
                const bottomTile = new Tile(bottomPoint, tileBehavior);
                this.tiles.set(bottomPoint, bottomTile);
            }
        }
        // Initialize Front and Back faces which have x and y values for LevelPoints
        for (let x = 0; x < levelSize.x; x += 1) {
            for (let y = 0; y < levelSize.y; y += 1) {
                const tileBehavior = this.isFaceBorder(x, y, null) ? new WallBehavior() : null;
                const frontPoint = this.levelPointFactory.get(new LevelPoint(x, y, null, Face.front));
                const frontTile = new Tile(frontPoint, tileBehavior);
                this.tiles.set(frontPoint, frontTile);
                const backPoint = this.levelPointFactory.get(new LevelPoint(x, y, null, Face.back));
                const backTile = new Tile(backPoint, tileBehavior);
                this.tiles.set(backPoint, backTile);
            }
        }
        // Initialize Left and Right faces which have y and z values for LevelPoints
        for (let y = 0; y < levelSize.y; y += 1) {
            for (let z = 0; z < levelSize.z; z += 1) {
                const tileBehavior = this.isFaceBorder(null, y, z) ? new WallBehavior() : null
                const leftPoint = this.levelPointFactory.get(new LevelPoint(null, y, z, Face.left));
                const leftTile = new Tile(leftPoint, tileBehavior);
                this.tiles.set(leftPoint, leftTile);
                const rightPoint = this.levelPointFactory.get(new LevelPoint(null, y, z, Face.right));
                const rightTile = new Tile(rightPoint, tileBehavior);
                this.tiles.set(rightPoint, rightTile);                
            }
        }
    }

    isFaceBorder(x, y, z) {
        // Check the X-axis Border
        if (x !== null && (x === 0 || x === this.levelSize.x - 1)) {
            return true;
        }
        // Check the Y-axis Border
        if (y !== null && (y === 0 || y === this.levelSize.y - 1)) {
            return true;
        }
        // Check the Z-axis Border
        if (z !== null && (z === 0 || z === this.levelSize.z - 1)) {
            return true;
        }
        return false; // The Point is not on a Border
    }

    facesOfCoordinate(x, y, z) {
        const isFront = (z === 0);
        const isBack = (z === this.levelSize.z - 1);
        const isRight = (x === this.levelSize.x - 1);
        const isLeft = (x === 0);
        const isTop  = (y === 0);
        const isBottom = (y === this.levelSize.y - 1);

        return [isFront, isBack, isRight, isLeft, isTop, isBottom]
    }

    insertEntity(entity) {
        this.entities.push(entity);
    }

    getTile(levelPoint) {
        return this.tiles.get(this.levelPointFactory.get(levelPoint));
    }

    setTileBehavior(behavior, levelPoint) {
        const tile = this.getTile(levelPoint);
        tile.behavior = behavior;
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
        const levelSize = this.levelSize;
        const newPointOverEdge = function(oldLevelPoint, destinationFace) {
            let x = oldLevelPoint.x;
            let y = oldLevelPoint.y;
            let z = oldLevelPoint.z;
            // Origin Face dictates the new value of the previous null property
            switch (oldLevelPoint.face) {
                case Face.front:
                    z = 0;
                    break;
                case Face.back:
                    z = levelSize.z - 1;
                    break;
                case Face.right:
                    x = levelSize.x - 1;
                    break;
                case Face.left:
                    x = 0;
                    break;
                case Face.top:
                    y = 0;
                    break;
                case Face.bottom:
                    y = levelSize.y - 1;
                    break;
                default:
                    console.error("Invalid Face.");
            }
            // Destination Face determines which value is now null
            switch (destinationFace) {
                case Face.front:
                case Face.back:
                    z = null;
                    break;
                case Face.right:
                case Face.left:
                    x = null;
                    break;
                case Face.top:
                case Face.bottom:
                    y = null;
                    break;
                default:
                    console.error("Invalid Face.");
            }
            return new LevelPoint(x, y, z, destinationFace);
        }

        switch (direction) {
            case Direction.forward:
                if (levelPoint.z == 0) {
                    return this.LevelPointFactory.get(newPointOverEdge(levelPoint, Face.front));
                }
                return this.levelPointFactory.get(new LevelPoint(levelPoint.x, levelPoint.y, levelPoint.z - 1, levelPoint.face));
            case Direction.backward:
                if (levelPoint.z == levelSize.z - 1) {
                    return this.LevelPointFactory.get(newPointOverEdge(levelPoint, Face.back));
                }
                return this.levelPointFactory.get(new LevelPoint(levelPoint.x, levelPoint.y, levelPoint.z + 1, levelPoint.face));
            case Direction.right:
                if (levelPoint.x == levelSize.x - 1) {
                    return this.LevelPointFactory.get(newPointOverEdge(levelPoint, Face.right));
                }
                return this.levelPointFactory.get(new LevelPoint(levelPoint.x + 1, levelPoint.y, levelPoint.z, levelPoint.face));
            case Direction.left:
                if (levelPoint.x == 0) {
                    return this.levelPointFactory.get(newPointOverEdge(levelPoint, Face.left));
                }
                return this.levelPointFactory.get(new LevelPoint(levelPoint.x - 1, levelPoint.y, levelPoint.z, levelPoint.face));
            case Direction.up:
                    if (levelPoint.y == 0) {
                        return this.LevelPointFactory.get(newPointOverEdge(levelPoint, Face.top));
                    }
                    return this.levelPointFactory.get(new LevelPoint(levelPoint.x, levelPoint.y - 1, levelPoint.z, levelPoint.face));
            case Direction.down:
                    if (levelPoint.y == levelSize.y - 1) {
                        return this.LevelPointFactory.get(newPointOverEdge(levelPoint, Face.bottom));
                    }
                    return this.levelPointFactory.get(new LevelPoint(levelPoint.x, levelPoint.y + 1, levelPoint.z, levelPoint.face));
            case null:
                console.error("Unexpectedly found null for a Direction value");
            default:
                console.error(`Unknown Direction ${direction}`);
        }
    }   

    _activateBehavior(slidingEntities, slideContext) {
        const slideContextOn = this.behaviorContextFactory.getWithProperties(slideContext, ActivationContext.on);
        const slideContextInto = this.behaviorContextFactory.getWithProperties(slideContext, ActivationContext.into);

        slidingEntities.forEach((entity) => { 
            this.tiles.get(this.levelPointFactory.get(entity.position)).behavior.activateBehavior(entity, slideContextOn);
            if (entity.slideDirection !== null) {
                entity.nextPosition = this.adjacentLevelPoint(this.levelPointFactory.get(entity.position), entity.slideDirection);
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
                if (entity.position.face !== entity.nextPosition.face) {
                    // When an entity is about to slide onto another face, they will then begin sliding to the opposite of the current face
                    const oppositeFace = getOppositeFace(entity.position.face);
                    entity.slideDirection = FaceToDirectionMap.get(oppositeFace);
                }
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

    stringKey() {
        return `${this.x},${this.y},${this.z},${this.face}`
    }
}

// Factory to access a LevelPoint, saves memory by returning references to already initialized LevelPoints
class LevelPointFactory {
    constructor(){
        this.levelPoints = new Map();
    }    

    get(levelPoint) {
        const key = levelPoint.stringKey();
        if (!this.levelPoints.has(key)) {
            this.levelPoints.set(key, levelPoint);
        }
        return this.levelPoints.get(key);
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

const FaceToDirectionMap = new Map([
    [Face.front, Direction.forward],
    [Face.back, Direction.backward],
    [Face.right, Direction.right],
    [Face.left, Direction.left],
    [Face.top, Direction.up],
    [Face.bottom, Direction.down]
])

const DirectionToFaceMap = new Map([
    [Direction.forward, Face.front],
    [Direction.backward, Face.back],
    [Direction.right, Face.right],
    [Direction.left, Face.left],
    [Direction.up, Face.top],
    [Direction.down, Face.bottom]
]);


