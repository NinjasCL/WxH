import "graphics" for Canvas
import "dome" for Window
import "nokia" for Display, Palette, Font, Sound
import "random" for Random

var Rand = Random.new()
var Operators = ["+", "-"]
var Blips = ["blip1", "blip2", "blip3", "blip4"]

class Dimensions {
  static widthMin {300}
  static widthMax {1024}

  static heightMin {300}
  static heightMax {768}
}

class Numbers {

  static target {__target}
  static operator {__operator}
  static width {__width}
  static height {__height}

  static start() {
    __width = Rand.int(Dimensions.widthMin, Dimensions.widthMax)
    __height = Rand.int(Dimensions.heightMin, Dimensions.heightMax)

    __operator = Rand.sample(Operators)

    __target = width + height
    if (__operator == "-") {
      __target = width - height
    }

    if (__target < Dimensions.widthMin ||
      __target > Dimensions.widthMax ||
      __target < Dimensions.heightMin ||
      __target > Dimensions.heightMax) {
      Numbers.start()
    }
  }
}

class Game {

  static init() {
    Display.init()
    Window.title = "WxH"
    Sound.play("good3")
    Font.darkmode()

    Numbers.start()
    __currentWidth = Window.width
    __currentHeight = Window.height
  }

  static update() {
    __result = Window.width + Window.height

    if (Numbers.operator == "-") {
      __result = Window.width - Window.height
    }

    if (__result == Numbers.target) {
      __tries = 0
      Sound.play("jingle1")
      Numbers.start()
    } else {
      if (__currentWidth != Window.width || __currentHeight != Window.height) {
        Sound.play(Rand.sample(Blips))
        __tries = __tries || 0
        __tries = __tries + 1
      }

      __currentWidth = Window.width
      __currentHeight = Window.height
    }
  }

  static draw(dt) {
    Canvas.cls(Palette.white)
    Font.gizmo.print("%(Window.width) %(Numbers.operator) %(Window.height) = %(Numbers.target)", 0, 5)
    Font.gizmo.print("%(__result)", 0, 20)
    Font.gizmo.print("%(__tries)", 0, 40)
  }
}
