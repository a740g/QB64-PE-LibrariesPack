' demo_09_probe_preview_save_frames.bas
' Probe metadata for several files, preview one selected item, and save its current frame.
' Controls:
'   Up/Down = change selection
'   S = save current frame to saved_preview_frame.png
'   O = reopen selected item
'   Esc = end

'$Include:'anim_manager.bi'

Declare Sub DrawAnimFit (animId As Long, boxX As Long, boxY As Long, boxW As Long, boxH As Long)
Declare Sub FormatNameText (formatId As Long, textValue As String)
Declare Sub OpenSelectedPreview (selectedIndex As Long, previewId As Long, fileName() As String)
Declare Sub ProbeAllFiles (fileName() As String, okFlag() As Integer, formatId() As Long, widthPx() As Long, heightPx() As Long, frameCount() As Long)

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim fileName(1 To 8) As String
Dim okFlag(1 To 8) As Integer
Dim formatId(1 To 8) As Long
Dim widthPx(1 To 8) As Long
Dim heightPx(1 To 8) As Long
Dim frameCount(1 To 8) As Long
Dim previewId As Long
Dim selectedIndex As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim i As Long
Dim formatText As String
Dim saveName As String
Dim infoText As String

screenW = 1360
screenH = 780

fileName(1) = "APPLE.FLI"
fileName(2) = "BALLOON.FLC"
fileName(3) = "Animals.gif"
fileName(4) = "Biker.png"
fileName(5) = "Windmill.png"
fileName(6) = "drum.ani"
fileName(7) = "phoenix1.ani"
fileName(8) = "3Globes.anim"

ProbeAllFiles fileName(), okFlag(), formatId(), widthPx(), heightPx(), frameCount()

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 09 - probe, preview, save frame"

selectedIndex = 1
previewId = -1
OpenSelectedPreview selectedIndex, previewId, fileName()

Do
    keyCode = _KeyHit
    Select Case keyCode
        Case 27
            quitFlag = -1

        Case 18432
            If selectedIndex > 1 Then
                selectedIndex = selectedIndex - 1
                OpenSelectedPreview selectedIndex, previewId, fileName()
            End If

        Case 20480
            If selectedIndex < 8 Then
                selectedIndex = selectedIndex + 1
                OpenSelectedPreview selectedIndex, previewId, fileName()
            End If

        Case 79, 111
            OpenSelectedPreview selectedIndex, previewId, fileName()

        Case 83, 115
            If previewId >= 0 Then
                saveName = "saved_preview_frame.png"
                N = AnimSaveFrameTo(previewId, AnimGetPos(previewId), saveName)
            End If
    End Select

    If previewId >= 0 Then AnimUpdate previewId

    Cls , _RGB32(12, 14, 22)
    _PrintString (20, 18), "Demo 09: probe + preview + save current frame"
    _PrintString (20, 40), "Up/Down = select    O = reopen    S = save frame to saved_preview_frame.png    Esc = end"

    Line (20, 80)-(640, 740), _RGB32(18, 22, 30), BF
    Line (20, 80)-(640, 740), _RGB32(140, 180, 230), B

    _PrintString (38, 94), "Probe results"
    For i = 1 To 8
        FormatNameText formatId(i), formatText
        If i = selectedIndex Then
            Line (28, 118 + (i - 1) * 72)-(632, 176 + (i - 1) * 72), _RGB32(44, 58, 84), BF
            Line (28, 118 + (i - 1) * 72)-(632, 176 + (i - 1) * 72), _RGB32(255, 255, 255), B
        End If

        _PrintString (40, 124 + (i - 1) * 72), fileName(i)
        _PrintString (40, 146 + (i - 1) * 72), "ok=" + LTrim$(Str$(okFlag(i))) + "  fmt=" + formatText
        _PrintString (40, 168 + (i - 1) * 72), "size " + LTrim$(Str$(widthPx(i))) + "x" + LTrim$(Str$(heightPx(i))) + "   frames " + LTrim$(Str$(frameCount(i)))
    Next i

    Line (700, 80)-(1320, 560), _RGB32(18, 22, 30), BF
    Line (700, 80)-(1320, 560), _RGB32(140, 180, 230), B
    _PrintString (718, 94), "Preview"

    If previewId >= 0 Then
        DrawAnimFit previewId, 712, 110, 596, 430
        FormatNameText AnimFormat(previewId), formatText
        infoText = "current frame " + LTrim$(Str$(AnimGetPos(previewId))) + " / " + LTrim$(Str$(AnimLen(previewId)))
        _PrintString (718, 580), "Selected: " + fileName(selectedIndex)
        _PrintString (718, 604), "Format: " + formatText
        _PrintString (718, 628), infoText
        _PrintString (718, 652), "Error: " + AnimError(previewId)
    Else
        _PrintString (718, 580), "Open failed for selected item."
    End If

    _Display
    _Limit 60
Loop Until quitFlag

If previewId >= 0 Then AnimFree previewId
AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

Sub OpenSelectedPreview (selectedIndex As Long, previewId As Long, fileName() As String)
    If previewId >= 0 Then
        AnimFree previewId
        previewId = -1
    End If

    previewId = AnimOpen(fileName(selectedIndex))
    If previewId >= 0 Then
        AnimSetLoop previewId, ANIM_LOOP_FOREVER
        AnimStart previewId
    End If
End Sub

Sub ProbeAllFiles (fileName() As String, okFlag() As Integer, formatId() As Long, widthPx() As Long, heightPx() As Long, frameCount() As Long)
    Dim i As Long

    For i = LBound(fileName) To UBound(fileName)
        AnimProbe fileName(i), okFlag(i), formatId(i), widthPx(i), heightPx(i), frameCount(i)
    Next i
End Sub

Sub FormatNameText (formatId As Long, textValue As String)
    textValue = "UNKNOWN"

    Select Case formatId
        Case ANIM_FMT_APNG
            textValue = "APNG"
        Case ANIM_FMT_GIF89A
            textValue = "GIF89a"
        Case ANIM_FMT_FLI
            textValue = "FLI"
        Case ANIM_FMT_FLC
            textValue = "FLC"
        Case ANIM_FMT_AMIGA_ANIM
            textValue = "AMIGA ANIM"
        Case ANIM_FMT_ANI
            textValue = "ANI"
    End Select
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
