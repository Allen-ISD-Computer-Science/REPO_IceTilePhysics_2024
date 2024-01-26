import Igis

/*
 This main code is responsible for starting Igis and initializing
 the Director.
 It rarely needs to be altered.
 */
print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:ShellDirector.self)
} catch (let error) {
    print("Error: \(error)")
}

