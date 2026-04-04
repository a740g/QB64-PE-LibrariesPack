' demo_08_manual_seek_and_step.bas
' Manual playback / seek / cache test.
' Controls:
'   Space = pause/resume
'   Left/Right = one frame backward/forward
'   Home = first frame
'   End = last frame
'   1 = seek to 1000 ms
'   2 = seek to 2000 ms
'   C = toggle cache mode STREAM / PRELOAD_ALL
'   S = stop
'   P = play / resume
'   Esc = end

'$Include:'anim_manager.bi'

Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim animId As Long
Dim keyCode As Long
Dim quitFlag As Integer
Dim formatText As String
Dim cacheText As String
Dim infoText As String
Dim frameIndex As Long
Dim cacheMode As Long

screenW = 1280
screenH = 720

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 08 - manual seek and cache test"

animId = AnimOpen("BALLOON.FLC")
If animId >= 0 Then
    AnimSetLoop animId, ANIM_LOOP_FOREVER
    AnimSetCacheMode animId, ANIM_CACHE_PRELOAD_ALL
    AnimStart animId
End If

Do
    keyCode = _KeyHit
    Select Case keyCode
        Case 27
            quitFlag = -1

        Case 32
            If animId >= 0 Then
                If AnimIsPlaying(animId) Then
                    AnimPause animId
                Else
                    AnimResume animId
                End If
            End If

        Case 19200
            If animId >= 0 Then AnimPause animId: N = AnimStepBackward(animId)

        Case 19712
            If animId >= 0 Then AnimPause animId: N = AnimStepForward(animId)

        Case 18176
            If animId >= 0 Then AnimPause animId: N = AnimSeek(animId, 0)

        Case 20224
            If animId >= 0 Then AnimPause animId: N = AnimSeek(animId, AnimLen(animId) - 1)

        Case 49
            If animId >= 0 Then AnimPause animId: N = AnimSeekTime(animId, 1000)

        Case 50
            If animId >= 0 Then AnimPause animId: N = AnimSeekTime(animId, 2000)

        Case 67, 99
            If animId >= 0 Then
                cacheMode = AnimGetCacheMode(animId)
                If cacheMode = ANIM_CACHE_PRELOAD_ALL Then
                    AnimSetCacheMode animId, ANIM_CACHE_STREAM
                Else
                    AnimSetCacheMode animId, ANIM_CACHE_PRELOAD_ALL
                End If
            End If

        Case 83, 115
            If animId >= 0 Then AnimStop animId

        Case 80, 112
            If animId >= 0 Then AnimStart animId
    End Select

    If animId >= 0 Then AnimUpdate animId

    Cls , _RGB32(10, 12, 18)
    _PrintString (20, 18), "Demo 08: manual seek / pause / step / cache mode"
    _PrintString (20, 40), "Asset: BALLOON.FLC"

    Line (30, 90)-(850, 650), _RGB32(18, 22, 30), BF
    Line (30, 90)-(850, 650), _RGB32(140, 180, 230), B

    If animId >= 0 Then
        DrawAnimFit animId, 40, 100, 800, 540
        frameIndex = AnimGetPos(animId)
        FormatNameText AnimFormat(animId), formatText
        CacheNameText AnimGetCacheMode(animId), cacheText

        _PrintString (900, 120), "Format: " + formatText
        _PrintString (900, 150), "Frame: " + LTrim$(Str$(frameIndex)) + " / " + LTrim$(Str$(AnimLen(animId)))
        _PrintString (900, 180), "Width x Height: " + LTrim$(Str$(AnimWidth(animId))) + " x " + LTrim$(Str$(AnimHeight(animId)))
        _PrintString (900, 210), "Playing: " + LTrim$(Str$(AnimIsPlaying(animId)))
        _PrintString (900, 240), "Cached: " + LTrim$(Str$(AnimIsCached(animId)))
        _PrintString (900, 270), "Cache mode: " + cacheText
        infoText = AnimError(animId)
        If Len(infoText) = 0 Then infoText = "(no error)"
        _PrintString (900, 300), "Error: " + infoText
    Else
        _PrintString (900, 120), "BALLOON.FLC could not be opened."
    End If

    _PrintString (900, 380), "Space  pause/resume"
    _PrintString (900, 405), "Left   step backward"
    _PrintString (900, 430), "Right  step forward"
    _PrintString (900, 455), "Home   first frame"
    _PrintString (900, 480), "End    last frame"
    _PrintString (900, 505), "1 / 2  seek to 1000 / 2000 ms"
    _PrintString (900, 530), "C      toggle cache mode"
    _PrintString (900, 555), "S / P  stop / play"
    _PrintString (900, 580), "Esc    end"

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then Screen 0: _FreeImage screenImage: screenImage = 0
End

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

Sub CacheNameText (cacheMode As Long, textValue As String)
    textValue = "UNKNOWN"

    Select Case cacheMode
        Case ANIM_CACHE_STREAM
            textValue = "STREAM"
        Case ANIM_CACHE_PRELOAD_ALL
            textValue = "PRELOAD_ALL"
        Case ANIM_CACHE_WINDOW
            textValue = "WINDOW"
        Case ANIM_CACHE_AUTO
            textValue = "AUTO"
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
