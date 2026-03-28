
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim fileNames(1 To 5) As String
Dim titles(1 To 5) As String
Dim animIds(1 To 5) As Long
Dim currentAnim As Long
Dim i As Long
Dim ok As Integer
Dim formatId As Long
Dim widthPx As Long
Dim heightPx As Long
Dim frameCount As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim boxW As Long
Dim boxH As Long
Dim boxX As Long
Dim boxY As Long
Dim statusText As String

fileNames(1) = "APPLE.FLI"
fileNames(2) = "AUTOGDE.FLC"
fileNames(3) = "BALLOON.FLC"
fileNames(4) = "DOLPHIN.FLI"
fileNames(5) = "test.FLC"

titles(1) = "1 - APPLE.FLI"
titles(2) = "2 - AUTOGDE.FLC"
titles(3) = "3 - BALLOON.FLC"
titles(4) = "4 - DOLPHIN.FLI"
titles(5) = "5 - test.FLC"

screenImage = _NewImage(1000, 700, 32)
Screen screenImage
_Title "Anim manager demo 07 - launcher menu"


For i = 1 To 5
    AnimProbe fileNames(i), ok, formatId, widthPx, heightPx, frameCount
    If ok Then
        animIds(i) = AnimOpen(fileNames(i))
        If animIds(i) >= 0 Then
            AnimSetLoop animIds(i), ANIM_LOOP_FOREVER
            AnimStart animIds(i)
        End If
    Else
        animIds(i) = -1
    End If
Next i

currentAnim = 1
If animIds(currentAnim) < 0 Then
    For i = 1 To 5
        If animIds(i) >= 0 Then
            currentAnim = i
            Exit For
        End If
    Next i
End If

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1
    If keyCode >= Asc("1") And keyCode <= Asc("5") Then
        currentAnim = keyCode - Asc("0")
    End If

    AnimUpdateAll

    Cls , _RGB32(18, 20, 30)

    Line (20, 20)-(270, 680), _RGB32(70, 90, 130), B
    _PrintString (40, 36), "Demo 07: select animation"
    _PrintString (40, 64), "Press key 1 to 5"
    _PrintString (40, 86), "Esc = end"

    For i = 1 To 5
        If i = currentAnim Then
            Line (34, 130 + (i - 1) * 80)-(256, 176 + (i - 1) * 80), _RGB32(70, 110, 170), BF
        Else
            Line (34, 130 + (i - 1) * 80)-(256, 176 + (i - 1) * 80), _RGB32(40, 50, 70), BF
        End If
        _PrintString (48, 145 + (i - 1) * 80), titles(i)
        If animIds(i) >= 0 Then
            statusText = "OK  " + LTrim$(Str$(AnimWidth(animIds(i)))) + "x" + LTrim$(Str$(AnimHeight(animIds(i))))
        Else
            statusText = "Can't open file"
        End If
        _PrintString (48, 162 + (i - 1) * 80), statusText
    Next i

    Line (300, 20)-(980, 680), _RGB32(70, 90, 130), B

    If currentAnim >= 1 And currentAnim <= 5 Then
        If animIds(currentAnim) >= 0 Then
            boxW = AnimWidth(animIds(currentAnim))
            boxH = AnimHeight(animIds(currentAnim))
            boxX = 300 + (680 - boxW) \ 2
            boxY = 20 + (660 - boxH) \ 2
            If boxX < 310 Then boxX = 310
            If boxY < 40 Then boxY = 40
            AnimDraw boxX, boxY, animIds(currentAnim)
            statusText = "Active: " + fileNames(currentAnim) + "   frame " + LTrim$(Str$(AnimGetPos(animIds(currentAnim))))
            _PrintString (320, 40), statusText
        Else
            _PrintString (330, 100), "Can't open active file."
        End If
    End If

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

