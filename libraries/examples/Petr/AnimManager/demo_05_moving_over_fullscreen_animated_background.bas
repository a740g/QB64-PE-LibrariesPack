' demo_05_moving_over_fullscreen_animated_background.bas
' Foreground animations move over a fullscreen animated background.
' Esc = end.

'$Include:'anim_manager.bi'

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim bgAnim As Long
Dim fileName(1 To 3) As String
Dim animId(1 To 3) As Long
Dim posX(1 To 3) As Single
Dim posY(1 To 3) As Single
Dim velX(1 To 3) As Single
Dim velY(1 To 3) As Single
Dim drawW(1 To 3) As Long
Dim drawH(1 To 3) As Long
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer

screenW = 1280
screenH = 720

fileName(1) = "Biker.png"
fileName(2) = "phoenix.ani"
fileName(3) = "BALLOON.FLC"

posX(1) = 80: posY(1) = 110: velX(1) = 2.10: velY(1) = 1.00: drawW(1) = 180: drawH(1) = 180
posX(2) = 900: posY(2) = 120: velX(2) = -2.40: velY(2) = 1.80: drawW(2) = 180: drawH(2) = 180
posX(3) = 280: posY(3) = 340: velX(3) = 1.60: velY(3) = -1.60: drawW(3) = 320: drawH(3) = 220

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 05 - moving foreground over fullscreen animated background"

bgAnim = AnimOpen("elephant.png")
If bgAnim >= 0 Then AnimSetLoop bgAnim, ANIM_LOOP_FOREVER: AnimStart bgAnim

For i = 1 To 3
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    If bgAnim >= 0 Then AnimUpdate bgAnim
    For i = 1 To 3
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    Cls , _RGB32(127)
    If bgAnim >= 0 Then DrawAnimFit bgAnim, 0, 0, screenW, screenH

    Line (0, 0)-(screenW - 1, 64), _RGBA32(0, 0, 0, 180), BF
    _PrintString (18, 18), "Demo 05: animated fullscreen background + moving foreground objects"
    _PrintString (18, 40), "Background: elephant.png    Esc = end"

    For i = 1 To 3
        posX(i) = posX(i) + velX(i)
        posY(i) = posY(i) + velY(i)

        If posX(i) < 10 Then posX(i) = 10: velX(i) = -velX(i)
        If posY(i) < 74 Then posY(i) = 74: velY(i) = -velY(i)
        If posX(i) + drawW(i) > screenW - 10 Then posX(i) = screenW - 10 - drawW(i): velX(i) = -velX(i)
        If posY(i) + drawH(i) > screenH - 10 Then posY(i) = screenH - 10 - drawH(i): velY(i) = -velY(i)

        Line (Int(posX(i)) - 2, Int(posY(i)) - 20)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGBA32(0, 0, 0, 140), BF
        Line (Int(posX(i)) - 2, Int(posY(i)) - 20)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGB32(255, 255, 255), B
        _PrintString (Int(posX(i)) + 8, Int(posY(i)) - 14), fileName(i)
        If animId(i) >= 0 Then DrawAnimFit animId(i), Int(posX(i)), Int(posY(i)), drawW(i), drawH(i)
    Next i

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
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
