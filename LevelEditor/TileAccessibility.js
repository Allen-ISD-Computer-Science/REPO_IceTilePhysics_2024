// Defines the ways in which a Tile is accessible
export const TileAccessibility = Object.freeze({
    critical: "critical", // An Entity is able to land on the Tile
    accessible: "accessible", // An Entity is able to slide over the Tile
    unaccessible: "unaccessible" // An Entity is unable to slide over the Tile
});