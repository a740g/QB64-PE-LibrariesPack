

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim animA As Long
Dim animB As Long
Dim quitFlag As Integer
Dim keyCode As Long
Dim padX As Long
Dim padY As Long
Dim panelW As Long
Dim panelH As Long
Dim leftX As Long
Dim rightX As Long
Dim drawY As Long
Dim textValue As String

screenImage = _NewImage(1280, 720, 32)
Screen screenImage
_Title "Anim manager demo 02 - two animations"

Cls , _RGB32(14, 16, 24)

animA = AnimOpen("APPLE.FLI")
animB = AnimOpen("DOLPHIN.FLI")

If animA < 0 Or animB < 0 Then
    Print "Can't open APPLE.FLI nebo DOLPHIN.FLI"
    End
End If

AnimSetLoop animA, ANIM_LOOP_FOREVER
AnimSetLoop animB, ANIM_LOOP_FOREVER
AnimStart animA
AnimStart animB

padX = 24
padY = 110
panelW = (1280 - padX * 3) \ 2
panelH = 720 - padY - 28
leftX = padX
rightX = padX * 2 + panelW
drawY = padY

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1
    If keyCode = Asc("1") Then AnimStart animA
    If keyCode = Asc("2") Then AnimStart animB

    AnimUpdate animA
    AnimUpdate animB

    Cls , _RGB32(14, 16, 24)

    Line (leftX - 4, drawY - 4)-(leftX + panelW + 3, drawY + panelH + 3), _RGB32(70, 90, 130), B
    Line (rightX - 4, drawY - 4)-(rightX + panelW + 3, drawY + panelH + 3), _RGB32(70, 90, 130), B

    DrawAnimFit animA, leftX, drawY, panelW, panelH
    DrawAnimFit animB, rightX, drawY, panelW, panelH

    _PrintString (24, 18), "Demo 02: two animas in Anim manager"
    _PrintString (24, 42), "Left: APPLE.FLI        Right: DOLPHIN.FLI"
    textValue = "1 = restart left   2 = restart right   Esc = konec"
    _PrintString (24, 66), textValue
    textValue = "Frame left: " + LTrim$(Str$(AnimGetPos(animA))) + " / " + LTrim$(Str$(AnimLen(animA) - 1))
    _PrintString (24, 90), textValue
    textValue = "Frame right: " + LTrim$(Str$(AnimGetPos(animB))) + " / " + LTrim$(Str$(AnimLen(animB) - 1))
    _PrintString (640, 90), textValue

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

