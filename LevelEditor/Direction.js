import { Face } from "./Face.js";

// Defines the 6 Directions in which an Enitity can move
export const Direction = Object.freeze({
    left: "left", // Decrement X, towards Left Face
    right: "right", // Icrement X, towards Right Face
    up: "up", // Decrement Y, towards Top Face
    down: "down", // Increment Y, towards Bottom Face
    forward: "forward", // Decrement Z, towards Front Face
    backward: "backward" // Increment Z, towards Back Face
});

export function getOppositeDirection(direction) {
    switch (direction) {      
        case Direction.forward:
            return Direction.backward;
        case Direction.backward:
            return Direction.forward;
        case Direction.right:
            return Direction.left;
        case Direction.left:
            return Direction.right;
        case Direction.up:
            return Direction.down;
        case Direction.down:
            return Direction.up;
        default:
            console.error("Invalid Direction");
    }
}