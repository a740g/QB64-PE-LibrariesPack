$If VERSION < 4.3.0 Then
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$End If

$UseLibrary:'Petr/AnimManager'




'need WebP support? Look here: https://github.com/QB64Petr/AnimManager/tree/Anim_manager_library_source

' Variable: screenImage stores the QB64 image handle used to store or draw decoded pixels.
Dim screenImage As Long
' Array: fileNames stores the parallel array that remembers the source filename for each active entry.
Dim fileNames(1 To 4) As String
' Array: animIds stores the working value for animation ids.
Dim animIds(1 To 4) As Long
' Array: posX stores the working value for pos x.
Dim posX(1 To 4) As Single
' Array: posY stores the working value for pos y.
Dim posY(1 To 4) As Single
' Array: velX stores the working value for vel x.
Dim velX(1 To 4) As Single
' Array: velY stores the working value for vel y.
Dim velY(1 To 4) As Single
' Array: drawW stores the working value for draw w.
Dim drawW(1 To 4) As Long
' Array: drawH stores the working value for draw h.
Dim drawH(1 To 4) As Long
' Variable: i stores the general-purpose loop index.
Dim i As Long
' Variable: keyCode stores the working value for key code.
Dim keyCode As Long
' Variable: quitFlag stores the working value for quit flag.
Dim quitFlag As Integer
' Variable: screenW stores the working value for screen w.
Dim screenW As Long
' Variable: screenH stores the working value for screen h.
Dim screenH As Long
' Variable: labelY stores the working value for label y.
Dim labelY As Long

fileNames(1) = "phoenix1.ani"
fileNames(2) = "valkyrie.anim"
fileNames(3) = "Belinda.fli"
fileNames(4) = "aaaa.gif"

screenW = 1280
screenH = 720

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Anim manager demo 11 - bouncing windows"


' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
' The loop order matters because later statements expect the data to be visited sequentially.
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

' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
' The loop order matters because later statements expect the data to be visited sequentially.
For i = 1 To 4
    drawW(i) = 260
    drawH(i) = 180
Next i

' Loop purpose: repeat this block until an internal exit condition decides that the current stage is complete.
Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    Cls , _RGB32(8, 10, 14)
    _PrintString (20, 20), "Demo 11: bouncing animated windows in Anim manager"
    _PrintString (20, 42), "Esc = end"

    ' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
    ' The loop order matters because later statements expect the data to be visited sequentially.
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

' Purpose: Routine for the demo program: handle draw animation fit.
' Parameters: animId = working value for animation id; boxX = working value for box x; boxY = working value for box y; boxW = working value for box w; boxH = working value for box h.
Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
    ' Variable: srcW stores the working value for src w.
    Dim srcW As Long
    ' Variable: srcH stores the working value for src h.
    Dim srcH As Long
    ' Variable: drawW stores the working value for draw w.
    Dim drawW As Long
    ' Variable: drawH stores the working value for draw h.
    Dim drawH As Long
    ' Variable: drawX stores the working value for draw x.
    Dim drawX As Long
    ' Variable: drawY stores the working value for draw y.
    Dim drawY As Long
    ' Variable: scaleX stores the working value for scale x.
    Dim scaleX As Double
    ' Variable: scaleY stores the working value for scale y.
    Dim scaleY As Double
    ' Variable: scaleValue stores the working value for scale value.
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


