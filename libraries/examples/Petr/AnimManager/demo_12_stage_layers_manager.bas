
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animBg As Long
Dim animLeft As Long
Dim animCenter As Long
Dim animRight As Long
Dim animBottom As Long
Dim keyCode As Long
Dim quitFlag As Integer

screenImage = _NewImage(1366, 768, 32)
Screen screenImage
_Title "Anim manager demo 12 - stage layers"


animBg = AnimOpen("BALLOON.FLC")
animLeft = AnimOpen("APPLE.FLI")
animCenter = AnimOpen("AUTOGDE.FLC")
animRight = AnimOpen("Rotating_earth_animated.gif")
animBottom = AnimOpen("test.FLC")

If animBg >= 0 Then AnimSetLoop animBg, ANIM_LOOP_FOREVER: AnimStart animBg
If animLeft >= 0 Then AnimSetLoop animLeft, ANIM_LOOP_FOREVER: AnimStart animLeft
If animCenter >= 0 Then AnimSetLoop animCenter, ANIM_LOOP_FOREVER: AnimStart animCenter
If animRight >= 0 Then AnimSetLoop animRight, ANIM_LOOP_FOREVER: AnimStart animRight
If animBottom >= 0 Then AnimSetLoop animBottom, ANIM_LOOP_FOREVER: AnimStart animBottom

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    AnimUpdateAll

    Cls , _RGB32(5, 6, 8)

    If animBg >= 0 Then
        AnimDrawWindow 0, 0, 1365, 767, animBg
    End If

    Line (18, 18)-(1348, 750), _RGB32(255, 255, 255), B
    _PrintString (32, 28), "Demo 12: One animation as scene + more layers above him"

    Line (40, 90)-(330, 310), _RGB32(255, 220, 80), B
    If animLeft >= 0 Then DrawAnimFit animLeft, 42, 92, 286, 216

    Line (388, 110)-(978, 520), _RGB32(80, 255, 220), B
    If animCenter >= 0 Then DrawAnimFit animCenter, 390, 112, 586, 406

    Line (1036, 100)-(1326, 320), _RGB32(255, 120, 120), B
    If animRight >= 0 Then DrawAnimFit animRight, 1038, 102, 286, 216

    Line (430, 560)-(936, 730), _RGB32(180, 180, 255), B
    If animBottom >= 0 Then AnimDrawWindow 432, 562, 933, 727, animBottom

    _PrintString (54, 318), "APPLE.FLI"
    _PrintString (620, 528), "AUTOGDE.FLC"
    _PrintString (1070, 328), "Rotating_earth_animated.gif"
    _PrintString (640, 736), "test.FLC"
    _PrintString (32, 730), "Esc = end"

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
