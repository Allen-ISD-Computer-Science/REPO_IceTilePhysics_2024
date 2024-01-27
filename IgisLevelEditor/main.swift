import Igis

print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:ShellDirector.self)
} catch (let error) {
    print("Error: \(error)")
}
