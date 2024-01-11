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
          let incrementTopCubeFaceLevelButton = Button(name: "IncrementLevel", labelString: "Increment Index", topLeft: Point(x: 25, y: 25))
          incrementTopCubeFaceLevelButton.clickHandler = onIncrementTopCubeFaceLevelButtonClickHandler
          insert(entity: incrementTopCubeFaceLevelButton, at: .front)

          let decrementTopCubeFaceLevelButton = Button(name: "DecrementLevel", labelString: "Decrement Index", topLeft: Point(x: 25, y: 60))
          decrementTopCubeFaceLevelButton.clickHandler = onDecrementTopCubeFaceLevelButtonClickHandler
          insert(entity: decrementTopCubeFaceLevelButton, at: .front)

          let resetTopCubeFaceLevelsButton = Button(name: "ResetLevels", labelString: "Reset Levels", topLeft: Point(x: 25, y: 95))
          resetTopCubeFaceLevelsButton.clickHandler = onResetTopCubeFaceLevelsButtonClickHandler
          insert(entity: resetTopCubeFaceLevelsButton, at: .front)

          let maxTopCubeFaceLevelButton = Button(name: "LastLevel", labelString: "Last Level", topLeft: Point(x: 25, y: 130))
          maxTopCubeFaceLevelButton.clickHandler = onMaxTopCubeFaceLevelButtonClickHandler
          insert(entity: maxTopCubeFaceLevelButton, at: .front)
      }

      func background() -> Background {
          guard let mainScene = scene as? MainScene else {
              fatalError("mainScene of type MainScene is required.")
          }
          let backgroundLayer = mainScene.backgroundLayer
          let background = backgroundLayer.background
          return background
      }

      func onIncrementTopCubeFaceLevelButtonClickHandler(control: Control, localLocation: Point) {
          background().incrementTopCubeFaceLevelIndex()          
      }
      func onDecrementTopCubeFaceLevelButtonClickHandler(control: Control, localLocation: Point) {
          background().decrementTopCubeFaceLevelIndex()
      }
      func onResetTopCubeFaceLevelsButtonClickHandler(control: Control, localLocation: Point) {
          background().resetTopCubeFaceLevels()
      }
      func onMaxTopCubeFaceLevelButtonClickHandler(control: Control, localLocation: Point) {
          background().maxTopLevelIndex()
      }
  }
