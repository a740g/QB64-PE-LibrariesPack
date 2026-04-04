' demo_02_animated_background_with_overlays.bas
' Fullscreen animated background plus three overlay animations.
' Esc = end.

'$Include:'anim_manager.bi'

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
Declare Sub DrawPanel (x As Long, y As Long, w As Long, h As Long, caption As String)

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim bgAnim As Long
Dim animA As Long
Dim animB As Long
Dim animC As Long
Dim quitFlag As Integer
Dim keyCode As Long

screenW = 1280
screenH = 720

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 02 - animated background with overlays"

bgAnim = AnimOpen("elephant.png")
animA = AnimOpen("drum.ani")
animB = AnimOpen("APPLE.FLI")
animC = AnimOpen("Animals.gif")

If bgAnim >= 0 Then AnimSetLoop bgAnim, ANIM_LOOP_FOREVER: AnimStart bgAnim
If animA >= 0 Then AnimSetLoop animA, ANIM_LOOP_FOREVER: AnimStart animA
If animB >= 0 Then AnimSetLoop animB, ANIM_LOOP_FOREVER: AnimStart animB
If animC >= 0 Then AnimSetLoop animC, ANIM_LOOP_FOREVER: AnimStart animC

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    If bgAnim >= 0 Then AnimUpdate bgAnim
    If animA >= 0 Then AnimUpdate animA
    If animB >= 0 Then AnimUpdate animB
    If animC >= 0 Then AnimUpdate animC

    Cls , _RGB32(0, 0, 0)

    If bgAnim >= 0 Then
        DrawAnimFit bgAnim, 0, 0, screenW, screenH
    End If

    Line (0, 0)-(screenW - 1, 64), _RGBA32(0, 0, 0, 180), BF
    _PrintString (24, 18), "Demo 02: animated background + overlays"
    _PrintString (24, 40), "Background: elephant.png    Overlays: drum.ani, APPLE.FLI, Animals.gif"

    DrawPanel 24, 92, 240, 240, "drum.ani"
    DrawPanel 340, 120, 600, 420, "APPLE.FLI"
    DrawPanel 980, 90, 260, 260, "Animals.gif"

    If animA >= 0 Then DrawAnimFit animA, 36, 104, 216, 216
    If animB >= 0 Then DrawAnimFit animB, 352, 132, 576, 396
    If animC >= 0 Then DrawAnimFit animC, 992, 102, 236, 236

    Line (36, 580)-(1244, 684), _RGBA32(0, 0, 0, 150), BF
    Line (36, 580)-(1244, 684), _RGB32(220, 220, 255), B
    _PrintString (54, 600), "This test checks layered drawing order and transparency behavior."
    _PrintString (54, 624), "The background is animated full-screen. The foreground objects must stay visible and stable."
    _PrintString (54, 648), "Esc = end"

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub DrawPanel (x As Long, y As Long, w As Long, h As Long, caption As String)
    Line (x - 2, y - 24)-(x + w + 1, y + h + 1), _RGBA32(0, 0, 0, 130), BF
    Line (x - 2, y - 24)-(x + w + 1, y + h + 1), _RGB32(230, 230, 250), B
    Line (x, y)-(x + w - 1, y + h - 1), _RGBA32(10, 10, 20, 90), BF
    Line (x, y)-(x + w - 1, y + h - 1), _RGB32(130, 170, 220), B
    _PrintString (x + 8, y - 16), caption
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
