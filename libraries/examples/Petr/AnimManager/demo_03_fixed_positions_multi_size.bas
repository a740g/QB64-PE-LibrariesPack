' demo_03_fixed_positions_multi_size.bas
' Several animations at fixed positions, each with a different size.
' They do not overlap on purpose.
' Esc = end.

'$Include:'anim_manager.bi'


Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim animId(1 To 6) As Long
Dim fileName(1 To 6) As String
Dim boxX(1 To 6) As Long
Dim boxY(1 To 6) As Long
Dim boxW(1 To 6) As Long
Dim boxH(1 To 6) As Long
Dim i As Long
Dim quitFlag As Integer
Dim keyCode As Long

screenW = 1360
screenH = 760

fileName(1) = "Biker.png"
fileName(2) = "Windmill.png"
fileName(3) = "Animals.gif"
fileName(4) = "BALLOON.FLC"
fileName(5) = "phoenix.ani"
fileName(6) = "3Globes.anim"

boxX(1) = 20: boxY(1) = 80: boxW(1) = 180: boxH(1) = 180
boxX(2) = 230: boxY(2) = 80: boxW(2) = 260: boxH(2) = 260
boxX(3) = 520: boxY(3) = 80: boxW(3) = 320: boxH(3) = 240
boxX(4) = 870: boxY(4) = 80: boxW(4) = 460: boxH(4) = 300
boxX(5) = 40: boxY(5) = 390: boxW(5) = 260: boxH(5) = 300
boxX(6) = 340: boxY(6) = 430: boxW(6) = 940: boxH(6) = 260

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 03 - fixed positions, different sizes"
Print "Plase wait, caching ANIM animation"
For i = 1 To 6
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 1 To 6
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    Cls , _RGB32(14, 16, 24)
    _PrintString (20, 18), "Demo 03: fixed layout with different draw sizes"
    _PrintString (20, 40), "This is mainly a scaling / non-overlap layout test. Esc = end"

    For i = 1 To 6
        DrawPanel boxX(i), boxY(i), boxW(i), boxH(i), fileName(i)
        If animId(i) >= 0 Then
            DrawAnimFit animId(i), boxX(i) + 8, boxY(i) + 8, boxW(i) - 16, boxH(i) - 16
        Else
            _PrintString (boxX(i) + 12, boxY(i) + 16), "Open failed"
        End If
    Next i

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub DrawPanel (x As Long, y As Long, w As Long, h As Long, caption As String)
    Line (x - 2, y - 24)-(x + w + 1, y + h + 1), _RGB32(70, 90, 130), BF
    Line (x - 2, y - 24)-(x + w + 1, y + h + 1), _RGB32(250, 250, 255), B
    Line (x, y)-(x + w - 1, y + h - 1), _RGB32(9, 12, 18), BF
    Line (x, y)-(x + w - 1, y + h - 1), _RGB32(130, 170, 220), B
    _PrintString (x + 8, y - 16), caption + "   " + LTrim$(Str$(w)) + "x" + LTrim$(Str$(h))
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
