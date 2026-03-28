



'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim bgId As Long
Dim midId As Long
Dim topId As Long
Dim quitFlag As Integer
Dim keyCode As Long
Dim tickValue As Double
Dim boxX As Long
Dim boxY As Long
Dim moveX As Long
Dim moveY As Long
Dim speedX As Long
Dim speedY As Long
Dim topX As Long
Dim topY As Long
Dim panelW As Long
Dim panelH As Long
Dim textValue As String

screenImage = _NewImage(1280, 720, 32)
Screen screenImage
_Title "Anim manager demo 05 - overlay"

Cls , _RGB32(0, 0, 0)

bgId = AnimOpen("AUTOGDE.FLC")
midId = AnimOpen("APPLE.FLI")
topId = AnimOpen("BALLOON.FLC")

If bgId < 0 Or midId < 0 Or topId < 0 Then
    Print "Can't open AUTOGDE.FLC, APPLE.FLI nebo BALLOON.FLC"
    End
End If

AnimSetLoop bgId, ANIM_LOOP_FOREVER
AnimSetLoop midId, ANIM_LOOP_FOREVER
AnimSetLoop topId, ANIM_LOOP_FOREVER
AnimStart bgId
AnimStart midId
AnimStart topId

panelW = 320
panelH = 240
boxX = 80
boxY = 80
moveX = boxX
moveY = boxY
speedX = 3
speedY = 2
topX = 1280 - 260
topY = 40

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1
    If keyCode = Asc("R") Or keyCode = Asc("r") Then
        AnimStart bgId
        AnimStart midId
        AnimStart topId
    End If

    AnimUpdate bgId
    AnimUpdate midId
    AnimUpdate topId

    moveX = moveX + speedX
    moveY = moveY + speedY

    If moveX < 20 Then speedX = -speedX
    If moveY < 80 Then speedY = -speedY
    If moveX + panelW > 1260 Then speedX = -speedX
    If moveY + panelH > 700 Then speedY = -speedY

    tickValue = Timer
    topX = 900 + Int(Sin(tickValue * .9) * 140)
    topY = 60 + Int(Cos(tickValue * 1.2) * 40)

    Cls , _RGB32(0, 0, 0)
    AnimDrawWindow 0, 0, 1279, 719, bgId

    Line (moveX - 2, moveY - 2)-(moveX + panelW + 1, moveY + panelH + 1), _RGB32(255, 220, 80), B
    DrawAnimFit midId, moveX, moveY, panelW, panelH

    Line (topX - 2, topY - 2)-(topX + 255, topY + 191), _RGB32(120, 220, 255), B
    DrawAnimFit topId, topX, topY, 256, 192

    _PrintString (20, 18), "Demo 05: One animatgion as background and next two as overlay"
    _PrintString (20, 40), "AUTOGDE.FLC + APPLE.FLI + BALLOON.FLC"
    textValue = "Frames: bg=" + LTrim$(Str$(AnimGetPos(bgId))) + "  mid=" + LTrim$(Str$(AnimGetPos(midId))) + "  top=" + LTrim$(Str$(AnimGetPos(topId)))
    _PrintString (20, 62), textValue
    _PrintString (20, 684), "R = restart all   Esc = end"

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
End

Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
    Dim srcW As Long
    Dim srcH As Long
    Dim drawW As Long
    Dim drawH As Long
    Dim drawX As Long
    Dim drawY As Long
    Dim scaleX As Double
    Dim scaleY As Double
    Dim scaleValue As Double

    If AnimValid(animId) = 0 Then Exit Sub

    srcW = AnimWidth(animId)
    srcH = AnimHeight(animId)
    If srcW <= 0 Or srcH <= 0 Then Exit Sub
    If boxW <= 0 Or boxH <= 0 Then Exit Sub

    scaleX = boxW / srcW
    scaleY = boxH / srcH

    If scaleX < scaleY Then
        scaleValue = scaleX
    Else
        scaleValue = scaleY
    End If

    If scaleValue <= 0 Then Exit Sub

    drawW = CLng(srcW * scaleValue)
    drawH = CLng(srcH * scaleValue)
    If drawW < 1 Then drawW = 1
    If drawH < 1 Then drawH = 1

    drawX = boxX + (boxW - drawW) \ 2
    drawY = boxY + (boxH - drawH) \ 2

    AnimDrawWindow drawX, drawY, drawX + drawW - 1, drawY + drawH - 1, animId
End Sub

'$Include:'anim_manager.bm'

