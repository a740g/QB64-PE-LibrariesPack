' demo_04_moving_on_static_background.bas
' Multiple animations moving with different speeds over a static generated background.
' Esc = end.

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim fileName(1 To 4) As String
Dim animId(1 To 4) As Long
Dim posX(1 To 4) As Single
Dim posY(1 To 4) As Single
Dim velX(1 To 4) As Single
Dim velY(1 To 4) As Single
Dim drawW(1 To 4) As Long
Dim drawH(1 To 4) As Long
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim tickValue As Double

screenW = 1280
screenH = 720

fileName(1) = "APPLE.FLI"
fileName(2) = "Animals.gif"
fileName(3) = "drum.ani"
fileName(4) = "3Globes.anim"

posX(1) = 40: posY(1) = 120: velX(1) = 2.20: velY(1) = 1.30: drawW(1) = 230: drawH(1) = 170
posX(2) = 620: posY(2) = 140: velX(2) = -1.80: velY(2) = 2.10: drawW(2) = 260: drawH(2) = 180
posX(3) = 900: posY(3) = 320: velX(3) = -2.40: velY(3) = -1.50: drawW(3) = 170: drawH(3) = 170
posX(4) = 240: posY(4) = 360: velX(4) = 1.50: velY(4) = -1.90: drawW(4) = 260: drawH(4) = 200

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 04 - moving animations on static background"
Print "Plase wait, caching ANIM animation"
For i = 1 To 4
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 1 To 4
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    tickValue = Timer
    DrawStaticBackground screenW, screenH, tickValue
    _PrintString (20, 16), "Demo 04: moving animations on a static generated background"
    _PrintString (20, 38), "Different velocities + bounce logic. Esc = end"

    For i = 1 To 4
        posX(i) = posX(i) + velX(i)
        posY(i) = posY(i) + velY(i)

        If posX(i) < 12 Then posX(i) = 12: velX(i) = -velX(i)
        If posY(i) < 72 Then posY(i) = 72: velY(i) = -velY(i)
        If posX(i) + drawW(i) > screenW - 12 Then posX(i) = screenW - 12 - drawW(i): velX(i) = -velX(i)
        If posY(i) + drawH(i) > screenH - 12 Then posY(i) = screenH - 12 - drawH(i): velY(i) = -velY(i)

        Line (Int(posX(i)) - 2, Int(posY(i)) - 20)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGBA32(0, 0, 0, 130), BF
        Line (Int(posX(i)) - 2, Int(posY(i)) - 20)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGB32(240, 240, 255), B
        _PrintString (Int(posX(i)) + 8, Int(posY(i)) - 14), fileName(i)
        If animId(i) >= 0 Then
            DrawAnimFit animId(i), Int(posX(i)), Int(posY(i)), drawW(i), drawH(i)
        End If
    Next i

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub DrawStaticBackground (screenW As Long, screenH As Long, tickValue As Double)
    Dim i As Long
    Dim hillY As Long
    Dim lineY As Long
    Dim pulseValue As Long

    Cls , _RGB32(20, 24, 34)

    For i = 0 To screenH Step 32
        lineY = i
        Line (0, lineY)-(screenW - 1, lineY), _RGB32(28, 34, 46)
    Next i

    For i = 0 To screenW Step 32
        Line (i, 0)-(i, screenH - 1), _RGB32(24, 30, 42)
    Next i

    pulseValue = 40 + CLng((Sin(tickValue * 1.4) + 1) * 20)
    Line (0, screenH - 140)-(screenW - 1, screenH - 1), _RGB32(18, 36, 18), BF

    For i = 0 To screenW - 1 Step 8
        hillY = screenH - 210 + CLng(Sin((i / 90#) + tickValue * 0.3) * 22)
        Line (i, hillY)-(i, screenH - 140), _RGB32(40, 90 + pulseValue, 60)
    Next i

    Circle (screenW - 170, 120), 56, _RGB32(230, 230, 160)
    Paint (screenW - 170, 120), _RGB32(200, 200, 120), _RGB32(230, 230, 160)
End Sub

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
