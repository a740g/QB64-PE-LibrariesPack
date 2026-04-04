' demo_01_side_by_side_file_vs_program.bas
' Left: file animation from the library package.
' Right: generated procedural animation.
' Esc = end.

'$Include:'anim_manager.bi'

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
Declare Sub DrawProgramScene (boxX As Long, boxY As Long, boxW As Long, boxH As Long, phaseSec As Double)
Declare Sub DrawFramePanel (x As Long, y As Long, w As Long, h As Long, caption As String)

Dim screenImage As Long
Dim animId As Long
Dim quitFlag As Integer
Dim keyCode As Long
Dim screenW As Long
Dim screenH As Long
Dim leftX As Long
Dim leftY As Long
Dim leftW As Long
Dim leftH As Long
Dim rightX As Long
Dim rightY As Long
Dim rightW As Long
Dim rightH As Long
Dim phaseSec As Double
Dim infoText As String

screenW = 1280
screenH = 720
leftX = 24
leftY = 90
leftW = 580
leftH = 580
rightX = 676
rightY = 90
rightW = 580
rightH = 580

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 01 - side by side file vs programmed animation"

animId = AnimOpen("APPLE.FLI")
If animId >= 0 Then
    AnimSetLoop animId, ANIM_LOOP_FOREVER
    AnimStart animId
End If

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    If animId >= 0 Then AnimUpdate animId

    Cls , _RGB32(8, 10, 18)
    _PrintString (24, 20), "Demo 01: file animation on the left, generated animation on the right"
    _PrintString (24, 42), "Asset: APPLE.FLI    Esc = end"

    DrawFramePanel leftX, leftY, leftW, leftH, "File animation: APPLE.FLI"
    DrawFramePanel rightX, rightY, rightW, rightH, "Generated animation"

    If animId >= 0 Then
        DrawAnimFit animId, leftX + 10, leftY + 10, leftW - 20, leftH - 20
        infoText = "frame " + LTrim$(Str$(AnimGetPos(animId))) + " / " + LTrim$(Str$(AnimLen(animId)))
        _PrintString (leftX + 12, leftY + leftH + 8), infoText
    Else
        _PrintString (leftX + 12, leftY + 18), "APPLE.FLI could not be opened."
    End If

    phaseSec = Timer
    DrawProgramScene rightX + 10, rightY + 10, rightW - 20, rightH - 20, phaseSec
    _PrintString (rightX + 12, rightY + rightH + 8), "Procedural scene driven by TIMER"

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub DrawFramePanel (x As Long, y As Long, w As Long, h As Long, caption As String)
    Line (x - 2, y - 26)-(x + w + 1, y + h + 1), _RGB32(75, 95, 130), BF
    Line (x - 2, y - 26)-(x + w + 1, y + h + 1), _RGB32(240, 240, 255), B
    Line (x, y)-(x + w - 1, y + h - 1), _RGB32(18, 22, 30), BF
    Line (x, y)-(x + w - 1, y + h - 1), _RGB32(120, 150, 210), B
    _PrintString (x + 8, y - 18), caption
End Sub

Sub DrawProgramScene (boxX As Long, boxY As Long, boxW As Long, boxH As Long, phaseSec As Double)
    Dim centerX As Long
    Dim centerY As Long
    Dim radiusA As Double
    Dim radiusB As Double
    Dim i As Long
    Dim px As Long
    Dim py As Long
    Dim ringColor As _Unsigned Long
    Dim phaseA As Double
    Dim starX As Long
    Dim starY As Long
    Dim boxRight As Long
    Dim boxBottom As Long
    Dim pulseSize As Long
    Dim shipX As Long
    Dim shipY As Long
    Dim waveY As Long
    Dim piValue As Double

    centerX = boxX + boxW \ 2
    centerY = boxY + boxH \ 2
    radiusA = boxW * 0.32
    radiusB = boxH * 0.28
    boxRight = boxX + boxW - 1
    boxBottom = boxY + boxH - 1
    piValue = Atn(1) * 4

    Line (boxX, boxY)-(boxRight, boxBottom), _RGB32(8, 10, 18), BF

    For i = 0 To 60
        starX = boxX + ((i * 37) Mod boxW)
        starY = boxY + ((i * 53 + Int(phaseSec * 40)) Mod boxH)
        PSet (starX, starY), _RGB32(180, 180, 220)
    Next i

    For i = 0 To 11
        phaseA = phaseSec * 1.2 + i * (piValue / 6)
        px = centerX + CLng(Cos(phaseA) * radiusA)
        py = centerY + CLng(Sin(phaseA * 1.5) * radiusB)
        ringColor = _RGB32(100 + (i * 12), 110 + (i * 10), 230)
        Circle (px, py), 18 + (i Mod 3) * 4, ringColor
        Paint (px, py), _RGB32(20 + i * 8, 20 + i * 5, 70 + i * 10), ringColor
    Next i

    pulseSize = 34 + CLng((Sin(phaseSec * 3.2) + 1) * 18)
    Line (centerX - pulseSize, centerY - pulseSize)-(centerX + pulseSize, centerY + pulseSize), _RGB32(255, 210, 40), B

    shipX = boxX + 40 + ((CLng(phaseSec * 180) Mod (boxW - 80)))
    waveY = boxY + boxH \ 2 + CLng(Sin(phaseSec * 4) * (boxH * 0.2))
    shipY = waveY
    Line (shipX - 26, shipY + 6)-(shipX + 26, shipY + 6), _RGB32(240, 240, 255)
    Line (shipX - 18, shipY - 8)-(shipX + 18, shipY - 8), _RGB32(240, 240, 255)
    Line (shipX - 18, shipY - 8)-(shipX - 26, shipY + 6), _RGB32(240, 240, 255)
    Line (shipX + 18, shipY - 8)-(shipX + 26, shipY + 6), _RGB32(240, 240, 255)
    Circle (shipX, shipY - 2), 8, _RGB32(100, 220, 255)
    Paint (shipX, shipY - 2), _RGB32(40, 120, 180), _RGB32(100, 220, 255)
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
