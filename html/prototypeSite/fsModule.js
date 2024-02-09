const fs = import fs from 'fs';

export function fetchLevels(levelsDir){
    var levels = [];

    //reads from the levels folder in directory, puts them into array
    levels = fs.readdir(levelsDir);

    return levels;
}
