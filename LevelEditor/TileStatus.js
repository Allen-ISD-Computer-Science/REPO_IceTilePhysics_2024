export const TilePaintedStatus = Object.freeze({
    painted: "painted",
    unpainted: "unpainted"
});

export const TileAccessibilityStatus = Object.freeze({
    critical: "critical",
    accessible: "accessible",
    unaccessible: "unaccessible"
})

export class TileStatus {
    constructor(paintedStatus = TilePaintedStatus.unpainted) {
        this.paintedStatus = paintedStatus
        this.accessibleByEntities = new Map();
    }

    setAccessibilityStatus(entity, accessibility) {
        this.accessibleByEntities.set(entity, accessibility);
    }

    accessibilityStatusOf(entity = null) {
        if (this.accessibleByEntities.size === 0) {
            return TileAccessibilityStatus.unaccessible;
        } else {
            return this.accessibleByEntities.get(entity) ?? TileAccessibilityStatus.unaccessible;
        }
    }
}