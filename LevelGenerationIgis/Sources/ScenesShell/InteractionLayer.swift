import Igis
import Scenes
import ScenesControls

  /*
     This class is responsible for the interaction Layer.
     Internally, it maintains the RenderableEntities for this layer.
   */


class InteractionLayer : Layer {

      init() {
          // Using a meaningful name can be helpful for debugging
          super.init(name:"Interaction")

          // We insert our RenderableEntities in the constructor
          let incrementLevelButton = Button(name: "IncrementLevel", labelString: "Increment Level Index", topLeft: Point(x: 25, y: 25))
          incrementLevelButton.clickHandler = onIncrementLevelButtonClickHandler
          insert(entity: incrementLevelButton, at: .front)

          let decrementLevelButton = Button(name: "DecrementLevel", labelString: "Decrement Level Index", topLeft: Point(x: 25, y: 60))
          decrementLevelButton.clickHandler = onDecrementLevelButtonClickHandler
          insert(entity: decrementLevelButton, at: .front)
      }

      func background() -> Background {
          guard let mainScene = scene as? MainScene else {
              fatalError("mainScene of type MainScene is required.")
          }
          let backgroundLayer = mainScene.backgroundLayer
          let background = backgroundLayer.background
          return background
      }

      func onIncrementLevelButtonClickHandler(control: Control, localLocation: Point) {
          background().incrementLevelIndex()          
      }
      func onDecrementLevelButtonClickHandler(control: Control, localLocation: Point) {
          background().decrementLevelIndex()
      }
  }
