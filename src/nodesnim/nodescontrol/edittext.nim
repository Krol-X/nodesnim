# author: Ethosa
## It provides primitive text input.
import
  strutils,
  ../thirdparty/opengl,
  ../thirdparty/opengl/glut,

  ../core/vector2,
  ../core/rect2,
  ../core/anchor,
  ../core/input,
  ../core/enums,
  ../core/color,

  ../nodes/node,
  control


type
  EditTextObj* = object of ControlRef
    blit_caret*: bool
    blit_speed*: float
    blit_time*: float
    caret_position*: int
    font*: pointer          ## Glut font data.
    spacing*: float         ## Font spacing.
    size*: float            ## Font size.
    text*: string           ## EditText text.
    hint_text*: string
    color*: ColorRef        ## Text color.
    hint_color*: ColorRef   ## Hint color.
    caret_color*: ColorRef
    text_align*: AnchorRef  ## Text align.
    on_edit*: proc(pressed_key: string): void  ## This called when user press any key.
  EditTextRef* = ref EditTextObj


proc EditText*(name: string = "EditText"): EditTextRef =
  ## Creates a new EditText.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var edit = EditText("EditText")
  nodepattern(EditTextRef)
  controlpattern()
  result.rect_size.x = 64
  result.rect_size.y = 32
  result.text = ""
  result.font = GLUT_BITMAP_HELVETICA_12
  result.size = 12
  result.spacing = 2
  result.text_align = Anchor(0, 0, 0, 0)
  result.color = Color(1f, 1f, 1f)
  result.hint_color = Color(0.8, 0.8, 0.8)
  result.hint_text = "Edit text ..."
  result.caret_position = 0
  result.blit_caret = true
  result.caret_color = Color(1f, 1f, 1f, 0.7)
  result.blit_speed = 0.05
  result.blit_time = 0f
  result.on_edit = proc(key: string) = discard
  result.kind = EDIT_TEXT_NODE


method getTextSize*(self: EditTextRef): Vector2Ref {.base.} =
  ## Returns text size.
  result = Vector2()
  for line in self.text.splitLines():  # get text height
    var x: float = 0f
    for c in line:
      x += self.font.glutBitmapWidth(c.int).float
    if x > result.x:
      result.x = x
    result.y += self.spacing + self.size
  if result.y > 0:
    result.y -= self.spacing


method getLine*(self: EditTextRef): int {.base.} =
  ## Returns current caret line.
  var
    caret_pos = 0
    l = 0
  for line in self.text.splitLines():
    for c in line:
      if caret_pos == self.caret_position:
        break
      inc caret_pos
    if caret_pos == self.caret_position:
      break
    inc l
    inc caret_pos
  return l


method getCharPositionUnderMouse*(self: EditTextRef): int {.base.} =
  ## Returns char position under mouse.
  let
    size = self.getTextSize()
    pos = Vector2Ref(x: last_event.x, y: last_event.y) - self.global_position
  if pos.y > size.y:
    return self.text.len()
  else:
    var
      res = Vector2()
      caret_pos = 0
      current_pos = 0
    for line in self.text.splitLines():  # get text height
      var x: float = 0f
      current_pos = 0
      res.y += self.spacing + self.size
      for c in line:
        x += self.font.glutBitmapWidth(c.int).float
        inc caret_pos
        inc current_pos
        if res.y >= pos.y:
          if current_pos < line.len() and x <= pos.x:
            continue
          return caret_pos
      inc caret_pos
      if x > res.x:
        res.x = x


method getCharUnderMouse*(self: EditTextRef): char {.base.} =
  ## Returns char under mouse
  return self.text[self.getCharPositionUnderMouse()]


method getWordPositionUnderMouse*(self: EditTextRef): tuple[startpos, endpos: int] {.base.} =
  ## Returns words under mouse.
  ## Returns (-1, -1), if under mouse no founds words.
  var caret = self.getCharPositionUnderMouse()
  if caret == self.text.len():
    return (-1, -1)

  if self.text.len() > 0 and self.text[caret] != ' ':
    # Left
    var i = caret
    while self.text[i] != ' ':
      dec i
      if i < 0:
        break
    if i > 0:
      if self.text[i] == ' ':
        i += 1
      result.startpos = i
    else:
      result.startpos = 0
    # Right
    i = caret
    while self.text[i] != ' ':
      inc i
      if i > self.text.len()-1:
        break
    if i < self.text.len():
      if self.text[i] == ' ':
        i -= 1
      result.endpos = i
    else:
      result.endpos = self.text.len()-1
  else:
    return (-1, -1)


method getWordUnderMouse*(self: EditTextRef): string {.base.} =
  ## Returns words under mouse.
  let (s, e) = self.getWordPositionUnderMouse()
  if self.text.len() > 0 and s > -1:
    return self.text[s..e]


method draw*(self: EditTextRef, w, h: GLfloat) =
  ## This method uses in the `window.nim`
  let
    x = -w/2 + self.global_position.x
    y = h/2 - self.global_position.y
    text =
      if self.text.len() > 0:
        self.text
      else:
        self.hint_text
    color =
      if self.text.len() > 0:
        self.color
      else:
        self.hint_color

  glColor4f(self.background_color.r, self.background_color.g, self.background_color.b, self.background_color.a)
  glRectf(x, y, x+self.rect_size.x, y-self.rect_size.y)
  var
    th = 0f
    char_num = 0

  for line in text.splitLines():  # get text height
    th += self.spacing + self.size
  if th != 0:
    th -= self.spacing
  var ty = y - self.rect_size.y*self.text_align.y1 + th*self.text_align.y2 - self.size

  for line in text.splitLines():
    var tw = self.font.glutBitmapLength(line).float
    # Draw text:
    var tx = x + self.rect_size.x*self.text_align.x1 - tw * self.text_align.x2
    for c in line:
      glColor4f(color.r, color.g, color.b, color.a)
      let
        cw = self.font.glutBitmapWidth(c.int).float
        right =
          if self.text_align.x2 > 0.9 and self.text_align.x1 > 0.9:
            1f
          else:
            0f
        bottom =
          if self.text_align.y2 > 0.9 and self.text_align.y1 > 0.9:
            1f
          else:
            0f
      if tx >= x and tx < x + self.rect_size.x+right and ty <= y and ty > y - self.rect_size.y+bottom:
        glRasterPos2f(tx, ty)  # set char position
        self.font.glutBitmapCharacter(c.int)  # render char

        inc char_num
        if char_num == self.caret_position and self.blit_caret and self.blit_time > 0.8 and self.focused:
          glColor4f(self.caret_color.r, self.caret_color.g, self.caret_color.b, self.caret_color.a)
          glRectf(tx+cw, ty, tx+cw+1.5, ty+self.size-2)
          if self.blit_time > 2f:
            self.blit_time = 0f
      tx += cw
    inc char_num
    ty -= self.spacing + self.size

  self.blit_time += self.blit_speed

  # Press
  if self.pressed:
    self.on_press(self, last_event.x, last_event.y)


method duplicate*(self: EditTextRef): EditTextRef {.base.} =
  ## Duplicates EditText object and create a new EditText.
  self.deepCopy()


method handle*(self: EditTextRef, event: InputEvent, mouse_on: var NodeRef) =
  ## Handles user input. Thi uses in the `window.nim`.
  procCall self.ControlRef.handle(event, mouse_on)

  when not defined(android) and not defined(ios):
    if self.hovered:  # Change cursor, if need
      glutSetCursor(GLUT_CURSOR_TEXT)
    else:
      glutSetCursor(GLUT_CURSOR_LEFT_ARROW)

  if event.kind == MOUSE and event.pressed:
    self.caret_position = self.getCharPositionUnderMouse()

  if self.focused:
    if event.kind == KEYBOARD:
      if event.key_cint == K_LEFT and self.caret_position > 0:
        self.caret_position -= 1
      elif event.key_cint == K_RIGHT and self.caret_position < self.text.len():
        self.caret_position += 1
      elif event.key in pressed_keys:  # Normal chars
        if event.key_int == 8:  # Backspace
          if self.caret_position > 1 and self.caret_position < self.text.len():
            self.text = self.text[0..self.caret_position-2] & self.text[self.caret_position..^1]
            self.caret_position -= 1
          elif self.caret_position == self.text.len() and self.caret_position > 0:
            self.text = self.text[0..^2]
            self.caret_position -= 1
          elif self.caret_position == 1:
            self.text = self.text[1..^1]
            self.caret_position -= 1

        # Other keys
        elif self.caret_position > 0 and self.caret_position < self.text.len():
          self.text = self.text[0..self.caret_position-1] & event.key & self.text[self.caret_position..^1]
          self.caret_position += 1
          self.on_edit(event.key)
        elif self.caret_position == 0:
          self.text = event.key & self.text
          self.caret_position += 1
          self.on_edit(event.key)
        elif self.caret_position == self.text.len():
          self.text &= event.key
          self.caret_position += 1
          self.on_edit(event.key)


method setTextAlign*(self: EditTextRef, align: AnchorRef) {.base.} =
  ## Changes text align.
  self.text_align = align


method setTextAlign*(self: EditTextRef, x1, y1, x2, y2: float) {.base.} =
  ## Changes text align.
  self.text_align = Anchor(x1, y1, x2, y2)


method setText*(self: EditTextRef, value: string) {.base.} =
  ## Changes EditText text.
  self.text = value
