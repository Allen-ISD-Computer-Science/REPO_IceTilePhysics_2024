export class BehaviorContext {
    constructor(slideContext, activationContext) {
        this.slideContext = slideContext;
        this.activationContext = activationContext;
    }
}

export const SlideContext = Object.freeze({
    start: "start", // Context used as an entity begins a slide
    slide: "slide", // Context used as an entity is sliding
    stop: "stop"    // Context used as an entity ends a slide
})

export const ActivationContext = Object.freeze({
    from: {type: "from"},   // Context used to activate a tile that an entity is leaving
    on: {type: "on"},       // Context used to activate a tile that an entity is currently on
    into: {type: "into"},   // Context used to activate a tile than an entity is entering
})

export class BehaviorContextFactory {
    constructor() {
        this.behaviorContexts = new Map();
    }
    
    getWithProperties(slideContext, activationContext) {
        const key = `${slideContext},${activationContext.type}`;
        if (!this.behaviorContexts.has(key)) {
            const behaviorContext = new BehaviorContext(slideContext, activationContext);
            this.behaviorContexts.set(key, behaviorContext);
        }
        return this.behaviorContexts.get(key);
    }
}