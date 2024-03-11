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