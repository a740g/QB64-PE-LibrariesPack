
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim bgImage As Long
Dim bgLoaded As Integer
Dim bgName As String
Dim animBack As Long
Dim animLeft As Long
Dim animRight As Long
Dim keyCode As Long
Dim quitFlag As Integer

screenImage = _NewImage(1280, 720, 32)
Screen screenImage
_Title "Anim manager demo 09 - PNG background + overlay"


bgName = "Windmill.png"
bgImage = _LoadImage(bgName, 32)
If bgImage >= -2 Then
    bgLoaded = -1
Else
    bgName = "Biker.png"
    bgImage = _LoadImage(bgName, 32)
    If bgImage >= -2 Then bgLoaded = -1
End If

animBack = AnimOpen("AUTOGDE.FLC")
animLeft = AnimOpen("APPLE.FLI")
animRight = AnimOpen("test.FLC")

If animBack >= 0 Then AnimSetLoop animBack, ANIM_LOOP_FOREVER: AnimStart animBack
If animLeft >= 0 Then AnimSetLoop animLeft, ANIM_LOOP_FOREVER: AnimStart animLeft
If animRight >= 0 Then AnimSetLoop animRight, ANIM_LOOP_FOREVER: AnimStart animRight

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    AnimUpdateAll

    If bgLoaded Then
        _PutImage (0, 0)-(1279, 719), bgImage, 0
    Else
        Cls , _RGB32(20, 24, 32)
    End If

    Line (40, 40)-(1240, 680), _RGB32(255, 255, 255), B
    _PrintString (56, 54), "Demo 09: static PNG background + 3 layers in Anim manager"
    If bgLoaded Then
        _PrintString (56, 76), "Background: " + bgName
    Else
        _PrintString (56, 76), "Background: Can not load none PNG"
    End If

    If animBack >= 0 Then
        Line (180, 120)-(1099, 579), _RGB32(40, 40, 40), BF
        AnimDrawWindow 180, 120, 1099, 579, animBack
    End If

    Line (110, 170)-(430, 410), _RGB32(255, 220, 80), B
    If animLeft >= 0 Then DrawAnimFit animLeft, 112, 172, 316, 236

    Line (850, 210)-(1170, 450), _RGB32(90, 240, 255), B
    If animRight >= 0 Then DrawAnimFit animRight, 852, 212, 316, 236

    _PrintString (120, 420), "APPLE.FLI"
    _PrintString (860, 460), "test.FLC"
    _PrintString (500, 600), "AUTOGDE.FLC as main layer"
    _PrintString (56, 650), "Esc = end"

    _Display
    _Limit 60
Loop Until quitFlag

If bgLoaded Then _FreeImage bgImage
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

