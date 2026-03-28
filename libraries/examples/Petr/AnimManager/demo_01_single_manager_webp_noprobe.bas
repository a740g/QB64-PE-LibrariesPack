Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animId As Long
Dim quitFlag As Integer
Dim keyCode As Long
Dim boxX As Long
Dim boxY As Long
Dim boxW As Long
Dim boxH As Long
Dim statusText As String
Dim pausedFlag As Integer

screenImage = _NewImage(800, 600, 32)
Screen screenImage
_Title "Anim manager demo 01 - single WebP"

Cls , _RGB32(10, 12, 18)

animId = AnimOpen("001.webp")

If animId < 0 Then
    Print "Can not open 001.webp"
    Print AnimError(animId)
    End
End If


AnimSetLoop animId, ANIM_LOOP_FOREVER
AnimStart animId

boxW = AnimWidth(animId)
boxH = AnimHeight(animId)
boxX = (800 - boxW) \ 2
boxY = (600 - boxH) \ 2 - 20
If boxY < 70 Then boxY = 70

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    If keyCode = 32 Then
        If pausedFlag Then
            AnimResume animId
            pausedFlag = 0
        Else
            AnimPause animId
            pausedFlag = -1
        End If
    End If

    If keyCode = Asc("R") Or keyCode = Asc("r") Then
        AnimStart animId
        pausedFlag = 0
    End If

    AnimUpdate animId

    Cls , _RGB32(10, 12, 18)
    Line (boxX - 8, boxY - 8)-(boxX + boxW + 7, boxY + boxH + 7), _RGB32(90, 110, 150), B
    AnimDraw boxX, boxY, animId

    _PrintString (24, 18), "Demo 01: Single animation in Anim manager"
    _PrintString (24, 40), "File: 001.webp"
    statusText = "Size: " + LTrim$(Str$(AnimWidth(animId))) + " x " + LTrim$(Str$(AnimHeight(animId))) + "   Total Frames: " + LTrim$(Str$(AnimLen(animId)))
    _PrintString (24, 62), statusText

    If pausedFlag Then
        statusText = "Actual frame: " + LTrim$(Str$(AnimGetPos(animId))) + "   Space = resume   R = restart   Esc = end"
    Else
        statusText = "Actual frame: " + LTrim$(Str$(AnimGetPos(animId))) + "   Space = pause   R = restart   Esc = end"
    End If
    _PrintString (24, 84), statusText

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
