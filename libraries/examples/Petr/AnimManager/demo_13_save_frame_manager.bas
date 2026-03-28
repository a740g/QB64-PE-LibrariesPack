
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animId As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim saveOk As Integer
Dim fileName As String
Dim statusText As String
Dim lastSaved As String
Dim boxX As Long
Dim boxY As Long
Dim boxW As Long
Dim boxH As Long
Dim currentFrame As Long

screenImage = _NewImage(960, 700, 32)
Screen screenImage
_Title "Anim manager demo 13 - save current frame"

animId = AnimOpen("AUTOGDE.FLC")
If animId < 0 Then
    Print "Can not load AUTOGDE.FLC"
    End
End If

AnimSetLoop animId, ANIM_LOOP_FOREVER
AnimStart animId

boxW = 760
boxH = 480
boxX = 100
boxY = 120

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    If keyCode = Asc("S") Or keyCode = Asc("s") Then
        currentFrame = AnimGetPos(animId)
        fileName = "capture_" + LTrim$(Str$(currentFrame)) + ".png"
        saveOk = AnimSaveFrameTo(animId, currentFrame, fileName)
        If saveOk Then
            lastSaved = fileName
        Else
            lastSaved = "Error savig file"
        End If
    End If

    If keyCode = Asc("R") Or keyCode = Asc("r") Then
        AnimStart animId
    End If

    AnimUpdate animId

    Cls , _RGB32(14, 16, 24)
    Line (boxX - 2, boxY - 2)-(boxX + boxW + 1, boxY + boxH + 1), _RGB32(90, 120, 170), B
    DrawAnimFit animId, boxX, boxY, boxW, boxH

    _PrintString (36, 24), "Demo 13: save actual frame using Anim manager"
    _PrintString (36, 48), "File: AUTOGDE.FLC"
    statusText = "Actual frame: " + LTrim$(Str$(AnimGetPos(animId))) + "   S = save PNG   R = restart   Esc = End"
    _PrintString (36, 72), statusText
    _PrintString (36, 620), "Last output: " + lastSaved
    _PrintString (36, 644), "PNG is saved to actual program folder."

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
