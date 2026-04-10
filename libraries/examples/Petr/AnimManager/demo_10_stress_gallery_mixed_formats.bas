$If VERSION < 4.3.0 Then
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$End If

$UseLibrary:'Petr/AnimManager'

' demo_10_stress_gallery_mixed_formats.bas
' Stress test: many items open at once, mixed formats, mixed cache modes.
' Esc = end.



Dim screenImage As Long
Dim screenW As Long
Dim screenH As Long
Dim fileName(1 To 9) As String
Dim animId(1 To 9) As Long
Dim boxX(1 To 9) As Long
Dim boxY(1 To 9) As Long
Dim boxW(1 To 9) As Long
Dim boxH(1 To 9) As Long
Dim cacheMode(1 To 9) As Long
Dim cacheText As String
Dim i As Long
Dim keyCode As Long
Dim quitFlag As Integer

screenW = 1440
screenH = 860

fileName(1) = "Biker.png"
fileName(2) = "Animals.gif"
fileName(3) = "APPLE.FLI"
fileName(4) = "BALLOON.FLC"
fileName(5) = "drum.ani"
fileName(6) = "phoenix.ani"
fileName(7) = "3Globes.anim"
fileName(8) = "Windmill.png"
fileName(9) = "G-avatar.gif"

boxX(1) = 20: boxY(1) = 90: boxW(1) = 430: boxH(1) = 220
boxX(2) = 500: boxY(2) = 90: boxW(2) = 430: boxH(2) = 220
boxX(3) = 980: boxY(3) = 90: boxW(3) = 430: boxH(3) = 220
boxX(4) = 20: boxY(4) = 350: boxW(4) = 430: boxH(4) = 220
boxX(5) = 500: boxY(5) = 350: boxW(5) = 430: boxH(5) = 220
boxX(6) = 980: boxY(6) = 350: boxW(6) = 430: boxH(6) = 220
boxX(7) = 20: boxY(7) = 610: boxW(7) = 430: boxH(7) = 220
boxX(8) = 500: boxY(8) = 610: boxW(8) = 430: boxH(8) = 220
boxX(9) = 980: boxY(9) = 610: boxW(9) = 430: boxH(9) = 220

cacheMode(1) = ANIM_CACHE_STREAM
cacheMode(2) = ANIM_CACHE_PRELOAD_ALL
cacheMode(3) = ANIM_CACHE_AUTO
cacheMode(4) = ANIM_CACHE_STREAM
cacheMode(5) = ANIM_CACHE_PRELOAD_ALL
cacheMode(6) = ANIM_CACHE_AUTO
cacheMode(7) = ANIM_CACHE_STREAM
cacheMode(8) = ANIM_CACHE_PRELOAD_ALL
cacheMode(9) = ANIM_CACHE_AUTO

screenImage = _NewImage(screenW, screenH, 32)
Screen screenImage
_Title "Demo 10 - stress gallery mixed formats"

AnimSetCacheBudgetMB 512
Print "Caching ANIM animations..."
For i = 1 To 9
    animId(i) = AnimOpen(fileName(i))
    If animId(i) >= 0 Then
        AnimSetLoop animId(i), ANIM_LOOP_FOREVER
        AnimSetCacheMode animId(i), cacheMode(i)
        AnimStart animId(i)
    End If
Next i

Do
    keyCode = _KeyHit
    If keyCode = 27 Then quitFlag = -1

    For i = 1 To 9
        If animId(i) >= 0 Then AnimUpdate animId(i)
    Next i

    Cls , _RGB32(10, 12, 18)
    _PrintString (20, 18), "Demo 10: stress gallery with mixed formats and cache modes"
    _PrintString (20, 40), "Global cache budget: " + LTrim$(Str$(AnimGetCacheBudgetMB)) + " MB    Esc = end"

    For i = 1 To 9
        Line (boxX(i) - 2, boxY(i) - 24)-(boxX(i) + boxW(i) + 1, boxY(i) + boxH(i) + 1), _RGB32(65, 82, 120), BF
        Line (boxX(i) - 2, boxY(i) - 24)-(boxX(i) + boxW(i) + 1, boxY(i) + boxH(i) + 1), _RGB32(250, 250, 255), B
        Line (boxX(i), boxY(i))-(boxX(i) + boxW(i) - 1, boxY(i) + boxH(i) - 1), _RGB32(16, 18, 28), BF
        Line (boxX(i), boxY(i))-(boxX(i) + boxW(i) - 1, boxY(i) + boxH(i) - 1), _RGB32(130, 170, 220), B

        _PrintString (boxX(i) + 8, boxY(i) - 16), fileName(i)
        If animId(i) >= 0 Then
            DrawAnimFit animId(i), boxX(i) + 8, boxY(i) + 32, boxW(i) - 16, boxH(i) - 48
            CacheNameText AnimGetCacheMode(animId(i)), cacheText
            _PrintString (boxX(i) + 8, boxY(i) + boxH(i) - 30), "cache=" + cacheText + "  ready=" + LTrim$(Str$(AnimIsCached(animId(i))))
        Else
            _PrintString (boxX(i) + 8, boxY(i) + 8), "Open failed"
        End If
    Next i

    _Display
    _Limit 60
Loop Until quitFlag

AnimFreeAll
If screenImage <= -2 Then _FreeImage screenImage: screenImage = 0
End

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
    drawY = boxY + (boxH - 40 - drawH) \ 2

    AnimDrawWindow drawX, drawY, drawX + drawW - 1, drawY + drawH - 1, animId
End Sub


