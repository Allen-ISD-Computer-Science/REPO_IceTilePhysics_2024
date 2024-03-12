import { Direction, getOppositeDirection } from "./Direction.js";
import { SlideContext, ActivationContext } from "./BehaviorContext.js";

// Superclass for all TileBehavior, defines default behavior
export class TileBehavior {
    activateBehavior(entity, context) {
    }
}

// Defines WallBehavior for a Tile
export class WallBehavior extends TileBehavior {
    activateBehavior(entity, context){
        if (context.activationContext === ActivationContext.into) {
            entity.slideDirection = null;    
            entity.nextPosition = null;
        }
    }
}

export class BendBehavior extends TileBehavior {
    constructor(exitOne, exitTwo) {
        super()
        this.exitOne = exitOne
        this.exitTwo = exitTwo        
    }

    _shouldBendSlide(slideDirection) {
        if (slideDirection === getOppositeDirection(this.exitOne) || slideDirection === getOppositeDirection(this.exitTwo)) {
            return true
        } else {
            return false
        }        
    }

    _bendSlide(slideDirection) {
        // If they are sliding in the opposite direction as exitOne, they will slide in the direction of exitTwo
        if (slideDirection === getOppositeDirection(this.exitOne)) {
            return this.exitTwo;
        // If they are sliding in the opposite direction as exitTwo, they will slide in the direction of exitOne
        } else if (slideDirection === getOppositeDirection(this.exitTwo)) {
            return this.exitOne;
        }
    }

    // A Bend Tile has two exits as Directions, if the player is on the tile and sliding the opposite direction as one of these exits, they will begin sliding in the other exits direction, if not, they will stop sliding
    activateBehavior(entity, context) {

        if (context.activateContext === ActivationContext.into) {
            if (!this._shouldBendSlide) {
                entity.slideDirection = null;
                entity.nextPosition = null;
            }
        }

        // Check if the entity is on the tile
        if (context.activationContext  === ActivationContext.on) {
            if (this._shouldBendSlide) {
                entity.slideDirection = this._bendSlide(entity.slideDirection);
            }
        }
    }
}