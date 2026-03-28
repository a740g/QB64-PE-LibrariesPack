'$Include:'anim_apng_backend.bi'
'$Include:'anim_gif89a_backend.bi'
'$Include:'anim_flic_backend_buffered.bi'
'$Include:'anim_webp_backend.bi'



' =========================================================
' Unified animation dispatcher for QB64PE
' Final project manager module using $INCLUDE backends.
' Public API prefix: Anim...
' =========================================================

' ---------------------------------------------------------
' Public format identifiers
' ---------------------------------------------------------
Const ANIM_FMT_NONE = 0
Const ANIM_FMT_APNG = 1
Const ANIM_FMT_GIF89A = 2
Const ANIM_FMT_FLI = 3
Const ANIM_FMT_FLC = 4
Const ANIM_FMT_WEBP = 5

Const ANIM_LOOP_FILE_DEFAULT = -2
Const ANIM_LOOP_FOREVER = -1
Const ANIM_LOOP_ONCE = 0

' ---------------------------------------------------------
' Public unified store
' ---------------------------------------------------------
Type AnimStore
    Used As Integer
    FormatId As Long
    BackendId As Long
    WidthPx As Long
    HeightPx As Long
    FrameCount As Long
    CurrentFrame As Long
    Playing As Integer
    LoopMode As Long
End Type

ReDim Shared AnimItems(0) As AnimStore
ReDim Shared AnimFileNames(0) As String
ReDim Shared AnimErrorTexts(0) As String

' ---------------------------------------------------------
' Backend includes
' ---------------------------------------------------------


' ---------------------------------------------------------
' Notes
' ---------------------------------------------------------
' AnimDrawWindow stretches to the target box without keeping aspect ratio.
' AnimDraw draws in native size.
' AnimUpdate or AnimUpdateAll must be called from the main loop.
' AnimSaveFrame(animId, frameIndex) creates a default PNG file name.
' AnimSaveFrameTo(animId, frameIndex, fileName) uses the explicit output name.






