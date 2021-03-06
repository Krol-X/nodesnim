# author: Ethosa
## This uses for create hero with physics.

import
  ../thirdparty/opengl,

  ../core/vector2,
  ../core/rect2,
  ../core/anchor,
  ../core/input,
  ../core/enums,

  ../nodes/node,
  node2d,
  collision_shape2d


type
  KinematicBody2DObj* = object of Node2DObj
    has_collision*: bool
    collision_node*: CollisionShape2DRef
  KinematicBody2DRef* = ref KinematicBody2DObj


proc KinematicBody2D*(name: string = "KinematicBody2D"): KinematicBody2DRef =
  ## Creates a new KinematicBody2D.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var node = KinematicBody2D("KinematicBody2D")
  nodepattern(KinematicBody2DRef)
  node2dpattern()
  result.has_collision = false
  result.kind = KINEMATIC_BODY_2D_NODE


method addChild*(self: KinematicBody2DRef, other: CollisionShape2DRef) {.base.} =
  ## Adss collision to the KinematicBody2D.
  ## This method should be called one time.
  self.children.add(other)
  other.parent = self
  self.has_collision = true
  self.collision_node = other


method getCollideCount*(self: KinematicBody2DRef): int {.base.} =
  ## Checks collision count.
  result = 0
  if self.has_collision:
    var scene = self.getRootNode()
    self.calcGlobalPosition()
    self.collision_node.calcGlobalPosition()

    for node in scene.getChildIter():
      if node.kind == COLLISION_SHAPE_2D_NODE:
        if node == self.collision_node:
          continue
        if self.collision_node.isCollide(node.CollisionShape2DRef):
          inc result


method draw*(self: KinematicBody2DRef, w, h: GLfloat) =
  ## this method uses in the `window.nim`.
  {.warning[LockLevel]: off.}
  self.position = self.timed_position

  if self.centered:
    self.position = self.timed_position - self.rect_size*2
  else:
    self.position = self.timed_position


method duplicate*(self: KinematicBody2DRef): KinematicBody2DRef {.base.} =
  ## Duplicates KinematicBody2D and create a new KinematicBody2D pointer.
  self.deepCopy()


method isCollide*(self: KinematicBody2DRef): bool {.base.} =
  ## Checks any collision and return `true`, when collide with any collision shape.
  result = false
  if self.has_collision:
    var scene = self.getRootNode()
    self.calcGlobalPosition()
    self.collision_node.calcGlobalPosition()

    for node in scene.getChildIter():
      if node.kind == COLLISION_SHAPE_2D_NODE:
        if node == self.collision_node:
          continue
        if self.collision_node.isCollide(node.CollisionShape2DRef):
          result = true
          break


method moveAndCollide*(self: KinematicBody2DRef, vel: Vector2Ref) {.base.} =
  ## Moves and checks collision
  ##
  ## Arguments:
  ## - `vel` is a velocity vector.
  self.move(vel)
  self.calcGlobalPosition()
  if self.has_collision:
    var scene = self.getRootNode()
    self.collision_node.calcGlobalPosition()

    for node in scene.getChildIter():
      if node.kind == COLLISION_SHAPE_2D_NODE:
        if node == self.collision_node:
          continue
        if self.collision_node.isCollide(node.CollisionShape2DRef):
          self.move(-vel.x, 0)
          self.calcGlobalPosition()
          self.collision_node.calcGlobalPosition()

          if self.collision_node.isCollide(node.CollisionShape2DRef):
            self.move(vel.x, -vel.y)
            self.calcGlobalPosition()
            self.collision_node.calcGlobalPosition()

          if self.collision_node.isCollide(node.CollisionShape2DRef):
            self.move(-vel.x, 0)
            self.calcGlobalPosition()
            self.collision_node.calcGlobalPosition()
