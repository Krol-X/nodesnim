# --- Test 5. Handle Control node events. --- #
import nodesnim


Window("hello world")

var
  main = Scene("Main")

  colorrect = ColorRect()
  colorrect1 = ColorRect()

main.addChild(colorrect)
colorrect.addChild(colorrect1)


colorrect1.click =
  proc(x, y: float) =  # This called when the user clicks on the Control node (ColorRect in this case).
    colorrect1.move(3, 3)

colorrect.press =
  proc(x, y: float) =  # This called when the user holds on the mouse on the Control node.
    colorrect.color.r -= 0.001

colorrect.release =
  proc(x, y: float) =  # This called when the user no more holds on the mouse.
    colorrect.color.r = 1

colorrect.focus =
  proc() =  # This called when the Control node gets focus.
    echo "hello ^^."

colorrect.unfocus =
  proc() =  # This called when the Control node loses focus.
    echo "bye :("

colorrect1.mouse_enter =
  proc(x, y: float) =  # This called when the mouse enters the Control node.
    colorrect1.color = Color(1, 0.6, 1, 0.5)

colorrect1.mouse_exit =
  proc(x, y: float) =  # This called when the mouse exit from the Control node.
    colorrect1.color = Color(1f, 1f, 1f)


addScene(main)
setMainScene("Main")
windowLaunch()
