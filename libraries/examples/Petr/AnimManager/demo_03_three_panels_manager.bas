

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animId(0 To 2) As Long
Dim fileName(0 To 2) As String
Dim quitFlag As Integer
Dim keyCode As Long
Dim padX As Long
Dim padY As Long
Dim gapX As Long
Dim panelW As Long
Dim panelH As Long
Dim xPos(0 To 2) As Long
Dim drawY As Long
Dim i As Long
Dim textValue As String

fileName(0) = "APPLE.FLI"
fileName(1) = "DOLPHIN.FLI"
fileName(2) = "BALLOON.FLC"

screenImage = _NewImage(1366, 768, 32)
Screen screenImage
_Title "Anim manager demo 03 - three anims"

Cls , _RGB32(12, 12, 16)

For i = 0 To 2
    animId(i) = AnimOpen(fileName(i))
    If animId(i) < 0 Then
        Print "Can't open: "; fileName(i)
        End
    End If
    AnimSetLoop animId(i), ANIM_LOOP_FOREVER
    AnimStart animId(i)
Next i

padX = 18
gapX = 18
padY = 110
panelW = (1366 - padX * 2 - gapX * 2) \ 3
panelH = 768 - padY - 26
drawY = padY
xPos(0) = padX
xPos(1) = padX + panelW + gapX
xPos(2) = padX + (panelW + gapX) * 2

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 0 To 2
        AnimUpdate animId(i)
    Next i

    Cls , _RGB32(12, 12, 16)

    For i = 0 To 2
        Line (xPos(i) - 4, drawY - 4)-(xPos(i) + panelW + 3, drawY + panelH + 3), _RGB32(80, 95, 140), B
        DrawAnimFit animId(i), xPos(i), drawY, panelW, panelH
        _PrintString (xPos(i), 82), fileName(i)
        textValue = "Frame " + LTrim$(Str$(AnimGetPos(animId(i)))) + "/" + LTrim$(Str$(AnimLen(animId(i)) - 1))
        _PrintString (xPos(i), 100), textValue
    Next i

    _PrintString (18, 18), "Demo 03: Three anims in Anim manager"
    _PrintString (18, 40), "FLI + FLI + FLC in one run"
    _PrintString (18, 60), "Esc = end"

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
