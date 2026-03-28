
'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim fileNames(1 To 4) As String
Dim animIds(1 To 4) As Long
Dim posX(1 To 4) As Single
Dim posY(1 To 4) As Single
Dim velX(1 To 4) As Single
Dim velY(1 To 4) As Single
Dim drawW(1 To 4) As Long
Dim drawH(1 To 4) As Long
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim screenW As Long
Dim screenH As Long
Dim labelY As Long

fileNames(1) = "APPLE.FLI"
fileNames(2) = "gula.webp"
fileNames(3) = "Biker.png"
fileNames(4) = "G-avatar.gif"

screenW = 1280
screenH = 720

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Anim manager demo 11 - bouncing windows"


For i = 1 To 4
    animIds(i) = AnimOpen(fileNames(i))
    If animIds(i) >= 0 Then
        AnimSetLoop animIds(i), ANIM_LOOP_FOREVER
        AnimStart animIds(i)
    End If
Next i

posX(1) = 30: posY(1) = 80: velX(1) = 2.2: velY(1) = 1.4
posX(2) = 420: posY(2) = 120: velX(2) = -1.7: velY(2) = 1.9
posX(3) = 780: posY(3) = 260: velX(3) = 2.4: velY(3) = -1.2
posX(4) = 900: posY(4) = 60: velX(4) = -2.0: velY(4) = 1.5

For i = 1 To 4
    drawW(i) = 260
    drawH(i) = 180
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    Cls , _RGB32(8, 10, 14)
    _PrintString (20, 20), "Demo 11: bouncing animated windows in Anim manager"
    _PrintString (20, 42), "Esc = end"

    For i = 1 To 4
        If animIds(i) >= 0 Then AnimUpdate animIds(i)

        posX(i) = posX(i) + velX(i)
        posY(i) = posY(i) + velY(i)

        If posX(i) < 10 Then posX(i) = 10: velX(i) = -velX(i)
        If posY(i) < 70 Then posY(i) = 70: velY(i) = -velY(i)
        If posX(i) + drawW(i) > screenW - 10 Then posX(i) = screenW - 10 - drawW(i): velX(i) = -velX(i)
        If posY(i) + drawH(i) > screenH - 10 Then posY(i) = screenH - 10 - drawH(i): velY(i) = -velY(i)

        Line (Int(posX(i)) - 2, Int(posY(i)) - 24)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGB32(100, 130, 180), BF
        Line (Int(posX(i)) - 2, Int(posY(i)) - 24)-(Int(posX(i)) + drawW(i) + 1, Int(posY(i)) + drawH(i) + 1), _RGB32(255, 255, 255), B
        _PrintString (Int(posX(i)) + 8, Int(posY(i)) - 18), fileNames(i)

        If animIds(i) >= 0 Then
            DrawAnimFit animIds(i), Int(posX(i)), Int(posY(i)), drawW(i), drawH(i)
        End If

        labelY = Int(posY(i)) + drawH(i) + 6
        If animIds(i) >= 0 Then
            _PrintString (Int(posX(i)), labelY), "frame " + LTrim$(Str$(AnimGetPos(animIds(i))))
        End If
    Next i

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
