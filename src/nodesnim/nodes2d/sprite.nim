# author: Ethosa
## It provides display sprites.
import
  ../thirdparty/opengl,

  ../core/vector2,
  ../core/rect2,
  ../core/anchor,
  ../core/input,
  ../core/enums,
  ../core/image,
  ../core/color,

  ../nodes/node,
  node2d


type
  SpriteObj* = object of Node2DObj
    filter*: ColorRef
    texture*: GlTextureObj
  SpriteRef* = ref SpriteObj



proc Sprite*(name: string = "Sprite"): SpriteRef =
  ## Creates a new Sprite.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var node = Sprite("Sprite")
  nodepattern(SpriteRef)
  node2dpattern()
  result.texture = GlTextureObj()
  result.filter = Color(1f, 1f, 1f)
  result.kind = SPRITE_NODE


method draw*(self: SpriteRef, w, h: GLfloat) =
  ## this method uses in the `window.nim`.
  {.warning[LockLevel]: off.}
  if self.texture.texture > 0'u32:
    self.rect_size = self.texture.size

  # Recalculate position.
  self.position = self.timed_position
  if self.centered:
    self.position = self.timed_position - self.rect_size/2
  else:
    self.position = self.timed_position

  let
    x = -w/2 + self.global_position.x
    y = h/2 - self.global_position.y

  # Draw
  if self.texture.texture > 0'u32:
    if self.centered:
      glTranslatef(x + (self.rect_size.x / 2), y - (self.rect_size.y / 2), self.z_index_global)
      self.position = self.rect_size / 2
    else:
      glTranslatef(x, y, self.z_index_global)
      self.position = Vector2()
    glRotatef(self.rotation, 0, 0, 1)
    glColor4f(self.filter.r, self.filter.g, self.filter.b, self.filter.a)

    glEnable(GL_TEXTURE_2D)
    glEnable(GL_DEPTH_TEST)
    glBindTexture(GL_TEXTURE_2D, self.texture.texture)

    glBegin(GL_QUADS)
    glTexCoord2f(0, 0)
    glVertex3f(-self.position.x, self.position.y, self.z_index_global)
    glTexCoord2f(0, 1)
    glVertex3f(-self.position.x, self.position.y - self.rect_size.y, self.z_index_global)
    glTexCoord2f(1, 1)
    glVertex3f(-self.position.x + self.rect_size.x, self.position.y - self.rect_size.y, self.z_index_global)
    glTexCoord2f(1, 0)
    glVertex3f(-self.position.x + self.rect_size.x, self.position.y, self.z_index_global)
    glEnd()
    glDisable(GL_DEPTH_TEST)
    glDisable(GL_TEXTURE_2D)
    glRotatef(-self.rotation, 0, 0, 1)
    if self.centered:
      glTranslatef(-x - (self.rect_size.x / 2), -y + (self.rect_size.y / 2), -self.z_index_global)
      self.position = self.timed_position - self.rect_size/2
    else:
      glTranslatef(-x, -y, -self.z_index_global)
      self.position = self.timed_position
  else:
    self.rect_size = Vector2()

method duplicate*(self: SpriteRef): SpriteRef {.base.} =
  ## Duplicates Sprite object and create a new Sprite.
  self.deepCopy()

method getGlobalMousePosition*(self: SpriteRef): Vector2Ref {.inline.} =
  ## Returns mouse position.
  Vector2Ref(x: last_event.x, y: last_event.y)

method loadTexture*(self: SpriteRef, file: cstring, mode = GL_RGB) {.base.} =
  ## Loads a new texture from file.
  ##
  ## Arguments:
  ## - `file` is a texture path.
  ## - `mode` is a GLenum. can be GL_RGB or GL_RGBA.
  self.texture = load(file, mode)

method setTexture*(self: SpriteRef, texture: GlTextureObj) {.base.} =
  ## Loads a new texture from file.
  ##
  ## Arguments:
  ## - `texture` is a GlTexture object.
  self.texture = texture
