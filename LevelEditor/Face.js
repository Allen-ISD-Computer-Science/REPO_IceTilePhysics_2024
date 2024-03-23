import { Direction } from "./Direction.js";

// Defines the 6 faces of rectangular prism geometry
export const Face = Object.freeze({
    front: "front",
    back: "back",
    right: "right",
    left: "left",
    top: "top",
    bottom: "bottom",
});

export function getOppositeFace(face) {
    switch (face) {
        case Face.front:
            return Face.back;
        case Face.back:
            return Face.front;
        case Face.right:
            return Face.left;
        case Face.left:
            return Face.right;
        case Face.top:
            return Face.bottom;
        case Face.bottom:
            return Face.top;
        default:
            console.error("Invalid Face");
    }
}