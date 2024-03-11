export class Entity {
    constructor(type, startingPosition) {
        this.type = type
        this.position = startingPosition;
        this.slideDirection = null;
        this.nextPosition = null;
    }

    isSliding() {
        return slideDirection !== null;
    }
}

export class Player extends Entity {
    constructor(startingPosition) {
        super("player", startingPosition)
    }

    setSlideDirection(direction) {
        this.slideDirection = direction;
    }
}