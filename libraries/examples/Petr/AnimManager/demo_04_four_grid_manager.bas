

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animId(0 To 3) As Long
Dim fileName(0 To 3) As String
Dim quitFlag As Integer
Dim keyCode As Long
Dim gridX(0 To 3) As Long
Dim gridY(0 To 3) As Long
Dim panelW As Long
Dim panelH As Long
Dim i As Long

fileName(0) = "APPLE.FLI"
fileName(1) = "DOLPHIN.FLI"
fileName(2) = "AUTOGDE.FLC"
fileName(3) = "BALLOON.FLC"

screenImage = _NewImage(1280, 900, 32)
Screen screenImage
_Title "Anim manager demo 04 - grid 2x2"

Cls , _RGB32(10, 10, 14)

For i = 0 To 3
    animId(i) = AnimOpen(fileName(i))
    If animId(i) < 0 Then
        Print "Can't open "; fileName(i)
        End
    End If
    AnimSetLoop animId(i), ANIM_LOOP_FOREVER
    AnimStart animId(i)
Next i

panelW = 600
panelH = 360
gridX(0) = 24
gridY(0) = 90
gridX(1) = 656
gridY(1) = 90
gridX(2) = 24
gridY(2) = 474
gridX(3) = 656
gridY(3) = 474

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 0 To 3
        AnimUpdate animId(i)
    Next i

    Cls , _RGB32(10, 10, 14)

    For i = 0 To 3
        Line (gridX(i) - 4, gridY(i) - 4)-(gridX(i) + panelW + 3, gridY(i) + panelH + 3), _RGB32(72, 88, 126), B
        DrawAnimFit animId(i), gridX(i), gridY(i), panelW, panelH
        _PrintString (gridX(i), gridY(i) - 20), fileName(i)
    Next i

    _PrintString (24, 18), "Demo 04: four animations in grid 2x2 in Anim manager"
    _PrintString (24, 42), "APPLE.FLI, DOLPHIN.FLI, AUTOGDE.FLC, BALLOON.FLC"
    _PrintString (24, 864), "Esc = end"

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

