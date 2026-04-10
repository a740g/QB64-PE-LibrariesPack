$If VERSION < 4.3.0 Then
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$End If

$UseLibrary:'Petr/AnimManager'


' demo_06_sinus_wave_parade.bas
' Multiple animations travel horizontally while following sine-wave vertical motion.
' Esc = end.



Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
Declare Sub DrawWaveBackground (screenW As Long, screenH As Long, phaseSec As Double)

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim fileName(1 To 5) As String
Dim animId(1 To 5) As Long
Dim posX(1 To 5) As Single
Dim baseY(1 To 5) As Single
Dim speedValue(1 To 5) As Single
Dim amplitudeValue(1 To 5) As Single
Dim phaseOffset(1 To 5) As Single
Dim drawW(1 To 5) As Long
Dim drawH(1 To 5) As Long
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim phaseSec As Double
Dim yNow As Long

screenW = 1360
screenH = 760

fileName(1) = "Belinda.fli"
fileName(2) = "test.FLC"
fileName(3) = "valkyrie.anim"
fileName(4) = "drum.ani"
fileName(5) = "G-avatar.gif"

posX(1) = 0: baseY(1) = 110: speedValue(1) = 2.1: amplitudeValue(1) = 26: phaseOffset(1) = 0.0: drawW(1) = 220: drawH(1) = 160
posX(2) = 260: baseY(2) = 220: speedValue(2) = 1.7: amplitudeValue(2) = 34: phaseOffset(2) = 0.8: drawW(2) = 150: drawH(2) = 150
posX(3) = 560: baseY(3) = 340: speedValue(3) = 1.4: amplitudeValue(3) = 42: phaseOffset(3) = 1.4: drawW(3) = 240: drawH(3) = 180
posX(4) = 860: baseY(4) = 500: speedValue(4) = 2.6: amplitudeValue(4) = 30: phaseOffset(4) = 2.1: drawW(4) = 170: drawH(4) = 170
posX(5) = 1100: baseY(5) = 610: speedValue(5) = 1.2: amplitudeValue(5) = 24: phaseOffset(5) = 2.7: drawW(5) = 220: drawH(5) = 200

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 06 - sinus wave parade"

For i = 1 To 5
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 1 To 5
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    phaseSec = Timer
    DrawWaveBackground screenW, screenH, phaseSec
    _PrintString (20, 18), "Demo 06: sinus-wave movement"
    _PrintString (20, 40), "Several formats follow different amplitudes and speeds. Esc = end"

    For i = 1 To 5
        posX(i) = posX(i) + speedValue(i)
        If posX(i) > screenW + 20 Then posX(i) = -drawW(i) - 20

        yNow = CLng(baseY(i) + Sin(phaseSec * 2.2 + phaseOffset(i) + (posX(i) / 180#)) * amplitudeValue(i))

        Line (Int(posX(i)) - 2, yNow - 20)-(Int(posX(i)) + drawW(i) + 1, yNow + drawH(i) + 1), _RGBA32(0, 0, 0, 120), BF
        Line (Int(posX(i)) - 2, yNow - 20)-(Int(posX(i)) + drawW(i) + 1, yNow + drawH(i) + 1), _RGB32(235, 235, 255), B
        _PrintString (Int(posX(i)) + 8, yNow - 14), fileName(i)
        If animId(i) >= 0 Then DrawAnimFit animId(i), Int(posX(i)), yNow, drawW(i), drawH(i)
    Next i

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub DrawWaveBackground (screenW As Long, screenH As Long, phaseSec As Double)
    Dim i As Long
    Dim yLine As Long
    Dim waveY As Long

    Cls , _RGB32(12, 16, 28)

    For i = 0 To screenH - 1 Step 28
        yLine = i
        Line (0, yLine)-(screenW - 1, yLine), _RGB32(18, 26, 44)
    Next i

    For i = 0 To screenW - 1 Step 8
        waveY = 90 + CLng(Sin((i / 70#) + phaseSec * 2) * 18)
        Line (i, waveY)-(i, waveY + 2), _RGB32(110, 140, 230)
        waveY = 260 + CLng(Sin((i / 90#) + phaseSec * 1.5 + 0.8) * 24)
        Line (i, waveY)-(i, waveY + 2), _RGB32(160, 190, 255)
        waveY = 450 + CLng(Sin((i / 120#) + phaseSec * 1.2 + 1.5) * 28)
        Line (i, waveY)-(i, waveY + 2), _RGB32(110, 150, 200)
    Next i
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


