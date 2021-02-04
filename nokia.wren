import "graphics" for Canvas, Color, ImageData, Drawable
import "audio" for AudioEngine
import "dome" for Window

/*
Based on Nokia Jam specs
https://itch.io/jam/nokiajam3
*/

class Palette {

  static none { Color.none }

  static black {
    if (!__black) {
      __black = Color.hex("#43523d")
    }
    return __black
  }

  static white {
    if (!__white) {
      __white = Color.hex("#c7f0d8")
    }
    return __white
  }

  static all {
    if (!__all) {
      __all = [black, white]
    }
    return __all
  }
}

/**
Based on the Nokia 3310 specs _(88 x 48)_
*/

class Display {
  static portrait {Portrait}
  static landscape {Landscape}
  static default {Portrait}
  static scale {8}
  static init() {
    Canvas.resize(Display.default.width, Display.default.height)
    Window.resize(Canvas.width * Display.scale, Canvas.height * Display.scale)
  }
}

class FPS {
  // 8 frames per second
  static val {8}

  static fps {
    if (!__fps || __fps > 60) {
      __fps = 0
    }
    return __fps
  }

  static fps = (value) {
    __fps = 0
    if (value < Num.largest - 1) {
      __fps = value
    }
  }

  static canUpdate() {
    fps = fps + 1
    return (fps % FPS.val == 0)
  }
}

class Resolution {

  width {_width}
  height {_height}

  construct new(w, h) {
    _width = w
    _height = h
  }
}

class Portrait is Resolution {

  static size {
    if (!__size) {
      __size = Resolution.new(88, 48)
    }
    return __size
  }

  static width {size.width}
  static height {size.height}
}

class Landscape is Resolution {

  static size {
    if (!__size) {
      __size = Resolution.new(48, 88)
    }
    return __size
  }

  static width {size.width}
  static height {size.height}
}

class Tile is Drawable {
  x {_x}
  y {_y}
  width {_width}
  height {_height}
  image {_image}
  index {_index}
  isEmpty {
    if (!_isEmpty) {
      _isEmpty = false
    }
    return _isEmpty
  }

  construct new(image, x, y, w, h, index) {
    _image = image
    _x = x
    _y = y
    _width = w
    _height = h
    _index = index
  }

  construct new(image, x, y, w, h, index, empty) {
    _image = image
    _x = x
    _y = y
    _width = w
    _height = h
    _isEmpty = empty
  }

  static load(image, width, height) {
    var tiles = []
    var index = 0
    for(y in 0...(image.height / height)) {
      for (x in 0...(image.width / width)) {
        var tile = Tile.new(image, x * width, y * height, width, height, index)
        tiles.add(tile)
        index = index + 1
      }
    }
    return tiles
  }

  draw(x, y) {
    if (!isEmpty) {
      image.drawArea(this.x, this.y, this.width, this.height, x, y)
    }
  }
}

class Font {

  name {_name}
  tiles {_tiles}
  tiles = (value) {
    _tiles = value
  }

  width {_width}
  height {_height}

  chars {_chars}

  toMap {{
    "name": name,
    "width": width,
    "height": height,
    "chars": chars
  }}

  toString {toMap.toString}

  static dark {0}
  static light {1}
  static mode {
    if (!__mode) {
      __mode = Font.light
    }
    return __mode
  }

  static togglemode() {
    __mode = mode == Font.light ? Font.dark : Font.light
  }

  static darkmode() {
    __mode = Font.dark
  }

  static lightmode() {
    __mode = Font.light
  }

  static classic {mode == Font.light ? Classic.light() : Classic.dark()}
  static gizmo {mode == Font.light ? Gizmo.light() : Gizmo.dark()}

  static classicLight {Classic.light()}
  static classicDark {Classic.dark()}

  static gizmoLight {Gizmo.light()}
  static gizmoDark {Gizmo.dark()}

  static default {Font.classic}

  static print(tiles, chars, text, x, y, kerning) {
    var index = -1
    var spacing = 0

    text.each{|char|
      index = chars.indexOf(char)
      if (index && index > -1) {
        if (tiles && tiles[index] && tiles[index] is Drawable) {
          tiles[index].draw(x + spacing, y)
          spacing = spacing + kerning
        }
      }
    }
    return spacing
  }
}

class Classic is Font {

  name {_name}
  tiles {_tiles}
  tiles = (value) {
    _tiles = value
  }

  width {_width}
  height {_height}

  chars {_chars}

  construct new() {
    _name = "Classic"
    _width = 7
    _height = 8
    _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 $€£¥¤+-*/=\%\"'#@&_(),.;:?!\\|{}<>[]'^~"
  }

  static dark() {
    if (!__dark) {
      var font = Classic.new()
      var image = ImageData.loadFromFile("res/fonts/dark/classic.png")
      font.tiles = Tile.load(image, font.width, font.height)
      __dark = font
    }
    return __dark
  }

  static light() {
    if (!__light) {
      var font = Classic.new()
      var image = ImageData.loadFromFile("res/fonts/light/classic.png")
      font.tiles = Tile.load(image, font.width, font.height)
      __light = font
    }
    return __light
  }

  print(text, x, y) {
    // default kerning 8 pixels
    return Font.print(_tiles, _chars, text, x, y, 8)
  }
}

class Gizmo is Font {

  name {_name}
  tiles {_tiles}
  tiles = (value) {
    _tiles = value
  }

  width {_width}
  height {_height}

  chars {_chars}

  construct new() {
    _name = "Gizmo"
    _width = 5
    _height = 5
    _chars = "!\"#$\%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ "
  }

  static dark() {
    if (!__dark) {
      var font = Gizmo.new()

      var image = ImageData.loadFromFile("res/fonts/dark/gizmo.png")
      var tiles = Tile.load(image, font.width, font.height)

      // Add mising space
      var last = tiles[-1]

      var empty = Tile.new(image,
        last.x * font.width,
        last.y * font.height,
        font.width,
        font.height,
        last.index + 1,
        true)

      tiles.add(empty)

      font.tiles = tiles

      __dark = font
    }

    return __dark
  }

  static light() {
    if (!__light) {
      var font = Gizmo.new()

      var image = ImageData.loadFromFile("res/fonts/light/gizmo.png")
      var tiles = Tile.load(image, font.width, font.height)

      // Add mising space
      var last = tiles[-1]
      var empty = Tile.new(image,
        last.x * font.width,
        last.y * font.height,
        font.width,
        font.height,
        last.index + 1,
        true)

      tiles.add(empty)

      font.tiles = tiles

      __light = font
    }

    return __light
  }

  print(text, x, y) {
    // default kerning 5 pixels
    return Font.print(this.tiles, _chars, text, x, y, 5)
  }
}

// Monophoic sound. Only one channel
class Sound {
  static files {
    if (!__files) {
      __files = []
    }
    return __files
  }

  static play(name) {
    if (!files.contains(name)) {
      files.add(name)
      AudioEngine.load(name, "res/sounds/%(name).wav")
    }
    AudioEngine.stopAllChannels()
    return AudioEngine.play(name)
  }
}

// All keys available in a Nokia 3310
class Keys {
  static num1 {"1"}
  static num2 {"2"}
  static num3 {"3"}
  static num4 {"4"}
  static num5 {"5"}
  static num6 {"6"}
  static num7 {"7"}
  static num8 {"8"}
  static num9 {"9"}
  static num0 {"10"}
  static asterisk {"*"}
  static hashtag {"#"}
  static power {"Escape"}
  static navi {"Return"}
  static scrollleft {"Left Shift"}
  static scrollright {"Right Shift"}
  static c {"Backspace"}
}

// Recommended Key mapping to a normal Keyboard
class Keymap {
  static num1 {"a"}

  static num2 {"Up"}
  static up {num2}

  static num3 {"s"}
  static num4 {"Left"}
  static left {num4}

  static num5 {"d"}

  static num6 {"Right"}
  static right {num6}

  static num7 {"z"}
  static btn1 {num7}

  static num8 {"Down"}
  static down {num8}

  static num9 {"x"}
  static btn2 {num9}

  static num0 {"c"}
  static asterisk {"q"}
  static hashtag {"e"}

  static power {"Escape"}
  static navi {"Return"}
  static scrollleft {"Left Shift"}
  static scrollright {"Left Ctrl"}
  static c {"Backspace"}
}
