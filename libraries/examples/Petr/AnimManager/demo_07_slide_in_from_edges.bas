' demo_07_slide_in_from_edges.bas
' Animations enter from screen edges and stop at fixed target boxes.
' Press R to restart the entry animation.
' Esc = end.

'$Include:'anim_manager.bi'

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
Declare Sub RestartScene (screenW As Long, screenH As Long, curX() As Single, curY() As Single, targetX() As Long, targetY() As Long, speedValue() As Single)
Declare Sub MoveTowardTarget (indexValue As Long, curX() As Single, curY() As Single, targetX() As Long, targetY() As Long, speedValue() As Single, arrived() As Integer)

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim fileName(1 To 4) As String
Dim animId(1 To 4) As Long
Dim curX(1 To 4) As Single
Dim curY(1 To 4) As Single
Dim targetX(1 To 4) As Long
Dim targetY(1 To 4) As Long
Dim drawW(1 To 4) As Long
Dim drawH(1 To 4) As Long
Dim speedValue(1 To 4) As Single
Dim arrived(1 To 4) As Integer
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim allArrived As Integer

screenW = 1360
screenH = 760

fileName(1) = "APPLE.FLI"
fileName(2) = "Biker.png"
fileName(3) = "drum.ani"
fileName(4) = "ANT_WALK.ANIM"

drawW(1) = 260: drawH(1) = 190: targetX(1) = 110: targetY(1) = 120: speedValue(1) = 7.0
drawW(2) = 220: drawH(2) = 220: targetX(2) = 980: targetY(2) = 100: speedValue(2) = 8.5
drawW(3) = 180: drawH(3) = 180: targetX(3) = 160: targetY(3) = 500: speedValue(3) = 7.6
drawW(4) = 360: drawH(4) = 240: targetX(4) = 760: targetY(4) = 420: speedValue(4) = 9.0

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 07 - slide in from edges"
Print "Please wait, caching ANIM animation"
For i = 1 To 4
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimStart animId(i)
    End If
Next i

RestartScene screenW, screenH, curX(), curY(), targetX(), targetY(), speedValue()

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1
    If keyCode = 82 Or keyCode = 114 Then RestartScene screenW, screenH, curX(), curY(), targetX(), targetY(), speedValue()

    For i = 1 To 4
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    Cls , _RGB32(16, 18, 26)
    _PrintString (20, 18), "Demo 07: slide in from left / right / top / bottom"
    _PrintString (20, 40), "R = restart entry animation    Esc = end"

    allArrived = -1
    For i = 1 To 4
        MoveTowardTarget i, curX(), curY(), targetX(), targetY(), speedValue(), arrived()
        If arrived(i) = 0 Then allArrived = 0

        Line (Int(curX(i)) - 2, Int(curY(i)) - 20)-(Int(curX(i)) + drawW(i) + 1, Int(curY(i)) + drawH(i) + 1), _RGBA32(0, 0, 0, 120), BF
        Line (Int(curX(i)) - 2, Int(curY(i)) - 20)-(Int(curX(i)) + drawW(i) + 1, Int(curY(i)) + drawH(i) + 1), _RGB32(255, 255, 255), B
        _PrintString (Int(curX(i)) + 8, Int(curY(i)) - 14), fileName(i)
        If animId(i) >= 0 Then DrawAnimFit animId(i), Int(curX(i)), Int(curY(i)), drawW(i), drawH(i)
    Next i

    If allArrived Then
        _PrintString (20, 708), "All items reached their targets. Press R to repeat."
    End If

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub RestartScene (screenW As Long, screenH As Long, curX() As Single, curY() As Single, targetX() As Long, targetY() As Long, speedValue() As Single)
    curX(1) = -320: curY(1) = targetY(1)
    curX(2) = screenW + 320: curY(2) = targetY(2)
    curX(3) = targetX(3): curY(3) = -260
    curX(4) = targetX(4): curY(4) = screenH + 260

    speedValue(1) = 7.0
    speedValue(2) = 8.5
    speedValue(3) = 7.6
    speedValue(4) = 9.0
End Sub

Sub MoveTowardTarget (indexValue As Long, curX() As Single, curY() As Single, targetX() As Long, targetY() As Long, speedValue() As Single, arrived() As Integer)
    Dim dx As Single
    Dim dy As Single

    arrived(indexValue) = 0
    dx = targetX(indexValue) - curX(indexValue)
    dy = targetY(indexValue) - curY(indexValue)

    If Abs(dx) <= speedValue(indexValue) And Abs(dy) <= speedValue(indexValue) Then
        curX(indexValue) = targetX(indexValue)
        curY(indexValue) = targetY(indexValue)
        arrived(indexValue) = -1
        Exit Sub
    End If

    If dx > speedValue(indexValue) Then
        curX(indexValue) = curX(indexValue) + speedValue(indexValue)
    ElseIf dx < -speedValue(indexValue) Then
        curX(indexValue) = curX(indexValue) - speedValue(indexValue)
    Else
        curX(indexValue) = targetX(indexValue)
    End If

    If dy > speedValue(indexValue) Then
        curY(indexValue) = curY(indexValue) + speedValue(indexValue)
    ElseIf dy < -speedValue(indexValue) Then
        curY(indexValue) = curY(indexValue) - speedValue(indexValue)
    Else
        curY(indexValue) = targetY(indexValue)
    End If
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
