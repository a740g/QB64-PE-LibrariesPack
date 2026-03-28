
'$Include:'anim_manager.bi'

Const INSTANCE_COUNT = 9

Dim screenImage As Long
Dim animId(0 To INSTANCE_COUNT - 1) As Long
Dim fileName(0 To 4) As String
Dim drawX(0 To INSTANCE_COUNT - 1) As Long
Dim drawY(0 To INSTANCE_COUNT - 1) As Long
Dim drawW(0 To INSTANCE_COUNT - 1) As Long
Dim drawH(0 To INSTANCE_COUNT - 1) As Long
Dim i As Long
Dim fileIndex As Long
Dim quitFlag As Integer
Dim keyCode As Long
Dim textValue As String

fileName(0) = "APPLE.FLI"
fileName(1) = "DOLPHIN.FLI"
fileName(2) = "AUTOGDE.FLC"
fileName(3) = "BALLOON.FLC"
fileName(4) = "test.FLC"

screenImage = _NewImage(1440, 900, 32)
Screen screenImage
_Title "Anim manager demo 06 - stress test"

Cls , _RGB32(10, 12, 16)

For i = 0 To INSTANCE_COUNT - 1
    fileIndex = i Mod 5
    animId(i) = AnimOpen(fileName(fileIndex))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

For i = 0 To INSTANCE_COUNT - 1
    drawW(i) = 440
    drawH(i) = 220
Next i

drawX(0) = 20: drawY(0) = 70
drawX(1) = 500: drawY(1) = 70
drawX(2) = 980: drawY(2) = 70
drawX(3) = 20: drawY(3) = 320
drawX(4) = 500: drawY(4) = 320
drawX(5) = 980: drawY(5) = 320
drawX(6) = 20: drawY(6) = 570
drawX(7) = 500: drawY(7) = 570
drawX(8) = 980: drawY(8) = 570

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 0 To INSTANCE_COUNT - 1
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    Cls , _RGB32(10, 12, 16)
    _PrintString (20, 18), "Demo 06: more instance at once in Anim manager"
    _PrintString (20, 40), "This indicator is good for checking stability and smoothness."
    _PrintString (20, 860), "Esc = konec"

    For i = 0 To INSTANCE_COUNT - 1
        Line (drawX(i) - 2, drawY(i) - 2)-(drawX(i) + drawW(i) + 1, drawY(i) + drawH(i) + 1), _RGB32(70, 90, 120), B
        If animId(i) >= 0 Then
            DrawAnimFit animId(i), drawX(i), drawY(i), drawW(i), drawH(i)
            textValue = fileName(i Mod 5) + "   frame " + LTrim$(Str$(AnimGetPos(animId(i))))
            _PrintString (drawX(i), drawY(i) + drawH(i) + 6), textValue
        Else
            _PrintString (drawX(i), drawY(i) + 12), "Can't open file"
        End If
    Next i

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

