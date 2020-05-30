# author: Ethosa
## It provides a primitive vertical slider.
import
  ../thirdparty/opengl,

  ../core/vector2,
  ../core/rect2,
  ../core/anchor,
  ../core/input,
  ../core/color,
  ../core/enums,

  ../nodes/node,
  control


type
  VSliderObj* = object of ControlPtr
    max_value*, value*: uint
    progress_color*: ColorRef
    thumb_color*: ColorRef

    on_changed*: proc(new_value: uint): void
  VSliderPtr* = ptr VSliderObj

var sliders: seq[VSliderObj] = @[]

proc VSlider*(name: string = "VSlider"): VSliderPtr =
  ## Creates a new VSlider pointer.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var slider = VSlider("VSlider")
  var variable: VSliderObj
  nodepattern(VSliderObj)
  controlpattern()
  variable.background_color = Color(1f, 1f, 1f)
  variable.rect_size.x = 40
  variable.rect_size.y = 120
  variable.progress_color = Color(0.5, 0.5, 0.5)
  variable.thumb_color = Color(0.7, 0.7, 0.7)
  variable.max_value = 100
  variable.value = 0
  variable.on_changed = proc(v: uint) = discard
  variable.kind = VSLIDER_NODE
  sliders.add(variable)
  return addr sliders[^1]


method draw*(self: VSliderPtr, w, h: GLfloat) =
  ## This uses in the `window.nim`.
  self.calcGlobalPosition()
  let
    x = -w/2 + self.global_position.x
    y = h/2 - self.global_position.y

  # Background
  glColor4f(self.background_color.r, self.background_color.g, self.background_color.b, self.background_color.a)
  glRectf(x, y, x + self.rect_size.x, y - self.rect_size.y)

  # Progress
  let progress = self.rect_size.y * (self.value.float / self.max_value.float)
  glColor4f(self.progress_color.r, self.progress_color.g, self.progress_color.b, self.progress_color.a)
  glRectf(x, y - self.rect_size.y + progress, x + self.rect_size.x, y - self.rect_size.y)

  # Thumb
  glColor4f(self.thumb_color.r, self.thumb_color.g, self.thumb_color.b, self.thumb_color.a)
  glRectf(x, y - self.rect_size.y + progress + 10, x + self.rect_size.x, y - self.rect_size.y + progress - 10)

  # Press
  if self.pressed:
    self.press(last_event.x, last_event.y)

method duplicate*(self: VSliderPtr): VSliderPtr {.base.} =
  ## Duplicates VSlider object and create a new VSlider pointer.
  var obj = self[]
  sliders.add(obj)
  return addr sliders[^1]

method setMaxValue*(self: VSliderPtr, value: uint) {.base.} =
  ## Changes max value, if it not less than progress.
  if value > self.value:
    self.max_value = value
  else:
    self.max_value = self.value

method setProgress*(self: VSliderPtr, value: uint) {.base.} =
  ## Changes progress, if it not more than max value.
  if value > self.max_value:
    self.value = self.max_value
  else:
    self.value = value

method setProgressColor*(self: VSliderPtr, color: ColorRef) {.base.} =
  ## Changes progress color.
  ## For change background color use `setBackgroundColor` method.
  self.progress_color = color

method handle*(self: VSliderPtr, event: InputEvent, mouse_on: var NodePtr) =
  ## handles user input. This uses in the `window.nim`.
  procCall self.ControlPtr.handle(event, mouse_on)

  if self.focused and self.pressed:
    let
      value = normalize(((self.global_position.y + self.rect_size.y - event.y) / self.rect_size.y), 0, 1)
      progress_value = (value * self.max_value.float).uint32
    if progress_value != self.value:
      self.on_changed(progress_value)
    self.setProgress(progress_value)
