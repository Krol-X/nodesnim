# author: Ethosa
## Number counter box.
import
  ../thirdparty/opengl,

  ../core/vector2,
  ../core/rect2,
  ../core/anchor,
  ../core/input,
  ../core/enums,
  ../core/color,

  ../nodes/node,
  ../nodes/canvas,
  control,
  label


type
  CounterObj* = object of ControlRef
    as_int*: bool  ## if true, then use integer representation.
    min_value*, value*, max_value*: float
    label*: LabelRef
  CounterRef* = ref CounterObj


proc Counter*(name: string = "Counter"): CounterRef =
  ## Creates a new Counter.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var c = Counter("Counter")
  nodepattern(CounterRef)
  controlpattern()
  result.rect_size.x = 90
  result.rect_size.y = 25
  result.min_value = 0
  result.value = 0
  result.max_value = 10
  result.as_int = true
  result.label = Label()
  result.label.mousemode = MOUSEMODE_IGNORE
  result.label.parent = result
  result.background_color = Color(0x212121ff)
  result.kind = COUNTER_NODE


method changeValue*(self: CounterRef, value: float) {.base.} =
  ## Changes value, if it more than `min_value` and less than `max_value`.
  if value > self.max_value:
    self.value = self.max_value
  elif value < self.min_value:
    self.value = self.min_value
  else:
    self.value = value


method draw*(self: CounterRef, w, h: GLfloat) =
  ## This uses in the `window.nim`.
  let
    x = -w/2 + self.global_position.x
    y = h/2 - self.global_position.y

  glColor4f(self.background_color.r, self.background_color.g, self.background_color.b, self.background_color.a)
  glRectf(x, y, x+self.rect_size.x, y-self.rect_size.y)

  self.label.calcGlobalPosition()
  self.label.resize(self.rect_size.x - 40, self.rect_size.y)
  self.label.setTextAlign(0.5, 0.5, 0.5, 0.5)
  if self.as_int:
    self.label.setText($self.value.int)
  else:
    self.label.setText($self.value)
  self.label.draw(w, h)

  glColor4f(1f, 1f, 1f, 1f)

  glBegin(GL_TRIANGLES)
  # First button
  glVertex2f(x + self.rect_size.x - 20, y - 8)
  glVertex2f(x + self.rect_size.x - 10, y)
  glVertex2f(x + self.rect_size.x, y - 8)

  # Second button
  glVertex2f(x + self.rect_size.x - 20, y - self.rect_size.y + 8)
  glVertex2f(x + self.rect_size.x - 10, y - self.rect_size.y)
  glVertex2f(x + self.rect_size.x, y - self.rect_size.y + 8)
  glEnd()

  # Press
  if self.pressed:
    self.on_press(self, last_event.x, last_event.y)


method duplicate*(self: CounterRef): CounterRef {.base.} =
  ## Duplicates Counter object and create a new Counter.
  self.deepCopy()


method handle*(self: CounterRef, event: InputEvent, mouse_on: var NodeRef) =
  procCall self.ControlRef.handle(event, mouse_on)

  let
    first_button = Rect2(
      self.global_position.x + self.rect_size.x - 20, self.global_position.y,
      20, 8).contains(last_event.x, last_event.y)
    second_button = Rect2(
      self.global_position.x + self.rect_size.x - 20, self.global_position.y + self.rect_size.y-8,
      20, 8).contains(last_event.x, last_event.y)

  if first_button and self.pressed:
    self.changeValue(self.value+1)
  elif second_button and self.pressed:
    self.changeValue(self.value-1)

  elif self.pressed:
    if self.as_int:
      self.changeValue(self.value - event.xrel)
    else:
      self.changeValue(self.value - event.xrel*0.01)

method setMaxValue*(self: CounterRef, value: float) {.base.} =
  ## Changes max value, if it more then current `value`.
  if value > self.value:
    self.max_value = value

method setMinValue*(self: CounterRef, value: float) {.base.} =
  ## Changes max value, if it less then current `value`.
  if value < self.value:
    self.min_value = value
