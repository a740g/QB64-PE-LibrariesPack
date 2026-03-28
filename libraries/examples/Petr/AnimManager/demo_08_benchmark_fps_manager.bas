
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim fileNames(1 To 8) As String
Dim animIds(1 To 8) As Long
Dim boxX(1 To 8) As Long
Dim boxY(1 To 8) As Long
Dim boxW As Long
Dim boxH As Long
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim activeCount As Long
Dim startTick As Double
Dim fpsTick As Double
Dim fpsCounter As Long
Dim fpsValue As Long
Dim statusText As String
Dim elapsedSec As Long

fileNames(1) = "APPLE.FLI"
fileNames(2) = "AUTOGDE.FLC"
fileNames(3) = "BALLOON.FLC"
fileNames(4) = "gula.webp"
fileNames(5) = "test.FLC"
fileNames(6) = "elephant.png"
fileNames(7) = "test.webp"
fileNames(8) = "DOLPHIN.FLI"

screenImage = _NewImage(1280, 900, 32)
Screen screenImage
_Title "Anim manager demo 08 - benchmark FPS"

boxW = 300
boxH = 180

For i = 1 To 8
    animIds(i) = AnimOpen(fileNames(i))
    If animIds(i) >= 0 Then
        AnimSetLoop animIds(i), ANIM_LOOP_FOREVER
        AnimStart animIds(i)
        activeCount = activeCount + 1
    End If
Next i

boxX(1) = 20: boxY(1) = 70
boxX(2) = 335: boxY(2) = 70
boxX(3) = 650: boxY(3) = 70
boxX(4) = 965: boxY(4) = 70
boxX(5) = 20: boxY(5) = 285
boxX(6) = 335: boxY(6) = 285
boxX(7) = 650: boxY(7) = 285
boxX(8) = 965: boxY(8) = 285

fpsTick = Timer
startTick = Timer

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    AnimUpdateAll

    Cls , _RGB32(12, 16, 22)
    _PrintString (20, 20), "Demo 08: benchmark / more instance at once in Anim manager"
    statusText = "Active animations: " + LTrim$(Str$(activeCount)) + "   Esc = end"
    _PrintString (20, 42), statusText

    For i = 1 To 8
        Line (boxX(i) - 2, boxY(i) - 2)-(boxX(i) + boxW + 1, boxY(i) + boxH + 1), _RGB32(70, 90, 120), B
        If animIds(i) >= 0 Then
            DrawAnimFit animIds(i), boxX(i), boxY(i), boxW, boxH
            _PrintString (boxX(i), boxY(i) + boxH + 8), fileNames(i) + "   frame " + LTrim$(Str$(AnimGetPos(animIds(i))))
        Else
            _PrintString (boxX(i), boxY(i) + 12), "Can't open " + fileNames(i)
        End If
    Next i

    fpsCounter = fpsCounter + 1
    If Timer < fpsTick Then fpsTick = Timer
    If Timer - fpsTick >= 1 Then
        fpsValue = fpsCounter
        fpsCounter = 0
        fpsTick = Timer
    End If

    elapsedSec = Int(Timer - startTick)
    statusText = "Priblizne FPS smycky: " + LTrim$(Str$(fpsValue)) + "   Cas od startu: " + LTrim$(Str$(elapsedSec)) + " s"
    _PrintString (20, 520), statusText
    _PrintString (20, 544), "Tohle demo je vhodne pro porovnani ruznych verzi backendu a manageru."

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

