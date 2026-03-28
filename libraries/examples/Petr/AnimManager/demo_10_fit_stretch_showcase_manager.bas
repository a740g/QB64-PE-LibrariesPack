
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animA As Long
Dim animB As Long
Dim animC As Long
Dim animD As Long
Dim keyCode As Long
Dim quitFlag As Integer

screenImage = _NewImage(1200, 900, 32)
Screen screenImage
_Title "Anim manager demo 10 - draw / fit / stretch"


animA = AnimOpen("Animals.gif")
animB = AnimOpen("AUTOGDE.FLC")
animC = AnimOpen("Windmill.png")
animD = AnimOpen("tyger.webp")

If animA >= 0 Then AnimSetLoop animA, ANIM_LOOP_FOREVER: AnimStart animA
If animB >= 0 Then AnimSetLoop animB, ANIM_LOOP_FOREVER: AnimStart animB
If animC >= 0 Then AnimSetLoop animC, ANIM_LOOP_FOREVER: AnimStart animC
If animD >= 0 Then AnimSetLoop animD, ANIM_LOOP_FOREVER: AnimStart animD

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    AnimUpdateAll

    Cls , _RGB32(10, 12, 16)

    Line (20, 20)-(580, 430), _RGB32(90, 120, 170), B
    _PrintString (36, 34), "1) AnimDraw - original size"
    If animA >= 0 Then AnimDraw 60, 80, animA

    Line (620, 20)-(1180, 430), _RGB32(90, 120, 170), B
    _PrintString (636, 34), "2) DrawAnimFit + AnimDrawWindow"
    If animB >= 0 Then DrawAnimFit animB, 660, 80, 480, 300

    Line (20, 470)-(580, 880), _RGB32(90, 120, 170), B
    _PrintString (36, 484), "3) AnimDrawWindow - fit to box"
    If animC >= 0 Then AnimDrawWindow 60, 540, 539, 819, animC

    Line (620, 470)-(1180, 880), _RGB32(90, 120, 170), B
    _PrintString (636, 484), "4) DrawAnimFit in a narrow panel"
    If animD >= 0 Then DrawAnimFit animD, 760, 520, 280, 320

    _PrintString (36, 850), "Esc = end"

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
