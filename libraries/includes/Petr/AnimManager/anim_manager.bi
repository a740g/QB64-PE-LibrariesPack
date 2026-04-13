'$INCLUDEONCE

$IF VERSION < 4.3.0 THEN
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$END IF

' =========================================================
' Commented source copy for the unified animation manager.
' Explanatory comments were added in English without altering executable code.
' =========================================================
'$include: 'anim_amiga_anim_backend2b.bi'
'$include: 'anim_ani_backend.bi'
'$include: 'anim_apng_backend.bi'
'$include: 'anim_flic_backend_buffered_faster.bi'
'$include: 'anim_gif89a_backend.bi'

' =========================================================
' Unified animation dispatcher for QB64PE
' Final project manager module using $INCLUDE backends.
' Public API prefix: Anim...
' =========================================================

' ---------------------------------------------------------
' Public format identifiers
' ---------------------------------------------------------
' Constant: ANIM_FMT_NONE is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_NONE = 0
' Constant: ANIM_FMT_APNG is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_APNG = 1
' Constant: ANIM_FMT_GIF89A is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_GIF89A = 2
' Constant: ANIM_FMT_FLI is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_FLI = 3
' Constant: ANIM_FMT_FLC is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_FLC = 4
' Constant: ANIM_FMT_WEBP is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_WEBP = 5 ' reserved, WebP support removed. If you need it, look to https://github.com/QB64Petr/AnimManager/tree/Anim_manager_library_source
' Constant: ANIM_FMT_AMIGA_ANIM is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_AMIGA_ANIM = 6
' Constant: ANIM_FMT_ANI is a format identifier used by the unified manager to select a backend.
Const ANIM_FMT_ANI = 7

' Constant: ANIM_LOOP_FILE_DEFAULT is a loop-mode constant used to control replay behavior.
Const ANIM_LOOP_FILE_DEFAULT = -2
' Constant: ANIM_LOOP_FOREVER is a loop-mode constant used to control replay behavior.
Const ANIM_LOOP_FOREVER = -1
' Constant: ANIM_LOOP_ONCE is a loop-mode constant used to control replay behavior.
Const ANIM_LOOP_ONCE = 0

' Constant: ANIM_CACHE_STREAM is a cache-mode constant used by the manager caching policy.
Const ANIM_CACHE_STREAM = 0
' Constant: ANIM_CACHE_PRELOAD_ALL is a cache-mode constant used by the manager caching policy.
Const ANIM_CACHE_PRELOAD_ALL = 1
' Constant: ANIM_CACHE_WINDOW is a cache-mode constant used by the manager caching policy.
Const ANIM_CACHE_WINDOW = 2
' Constant: ANIM_CACHE_AUTO is a cache-mode constant used by the manager caching policy.
Const ANIM_CACHE_AUTO = 3
' Constant: ANIM_CACHE_DEFAULT_BUDGET_MB is a default cache-budget constant expressed in megabytes.
Const ANIM_CACHE_DEFAULT_BUDGET_MB = 256

' ---------------------------------------------------------
' Public unified store
' ---------------------------------------------------------
' Record layout: AnimStore groups related fields used by the unified animation manager.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AnimStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FormatId stores the numeric identifier of the detected animation file format.
    FormatId As Long
    ' Field: BackendId stores the backend-specific handle or index used to reach the real decoder state.
    BackendId As Long
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: FrameCount stores the total number of frames available for the current animation.
    FrameCount As Long
    ' Field: CurrentFrame stores the zero-based frame index currently selected for display or playback.
    CurrentFrame As Long
    ' Field: Playing stores the flag telling whether playback is currently running.
    Playing As Integer
    ' Field: LoopMode stores the loop policy that controls whether playback stops or repeats.
    LoopMode As Long
    ' Field: CacheModeWanted stores the requested cache strategy chosen by the caller or by defaults.
    CacheModeWanted As Long
    ' Field: CacheModeActive stores the cache strategy that is actually active after validation.
    CacheModeActive As Long
    ' Field: CacheEstimatedBytes stores the estimated memory cost used to decide whether caching is practical.
    CacheEstimatedBytes As _Unsigned _Integer64
    ' Field: CacheFrameStart stores the first frame index covered by the current cache window.
    CacheFrameStart As Long
    ' Field: CacheFrameCount stores the number of frames currently covered by the current cache window.
    CacheFrameCount As Long
    ' Field: CacheReady stores the flag telling whether the current cache content is valid and usable.
    CacheReady As Integer
    ' Field: Paused stores the flag telling whether playback is temporarily paused.
    Paused As Integer
    ' Field: NextTick stores the absolute timer target for the next frame advance.
    NextTick As Double
    ' Field: RemainingDelay stores the time still left before the next frame should be shown.
    RemainingDelay As Double
    ' Field: LastRawTimer stores the raw timer snapshot used to measure elapsed playback time.
    LastRawTimer As Double
    ' Field: LoopIteration stores the counter of completed playback loops.
    LoopIteration As Long
End Type

' Record layout: AnimCacheFrameStore groups related fields used by the unified animation manager.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AnimCacheFrameStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: ImageHandle stores the QB64 image handle used to store or draw decoded pixels.
    ImageHandle As Long
    ' Field: ByteCost stores the approximate memory cost in bytes for one cached object.
    ByteCost As _Unsigned _Integer64
End Type

' Shared dynamic array: AnimItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared AnimItems(0) As AnimStore
' Shared dynamic array: AnimFileNames is resized here to hold the parallel array that remembers the source filename for each active entry.
ReDim Shared AnimFileNames(0) As String
' Shared dynamic array: AnimErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared AnimErrorTexts(0) As String
' Shared dynamic array: AnimCacheFrames is resized here to hold the dynamic array that stores per-frame data or cached frame metadata.
ReDim Shared AnimCacheFrames(0) As AnimCacheFrameStore
' Shared variable: AnimCacheBytesUsed stores the running total of cache memory currently consumed.
Dim Shared AnimCacheBytesUsed As _Unsigned _Integer64
' Shared variable: AnimCacheBytesBudget stores the memory budget that limits how much frame cache this module may keep.
Dim Shared AnimCacheBytesBudget As _Unsigned _Integer64

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
' AnimSeek/AnimSeekTime/AnimStepForward/AnimStepBackward are the first public seek API slice.


' Purpose: Move directly to a specific frame index.
' Parameters: animId = working value for animation id; frameIndex = index variable used to address the current item.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.
  
' FUNCTION AnimSeek% (animId As Long, frameIndex As Long)
' Purpose: Move playback to the frame that matches the requested time position.
' Parameters: animId = working value for animation id; timeMs = time value measured in milliseconds.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.

' FUNCTION AnimSeekTime% (animId As Long, timeMs As Double)
' Purpose: Move one frame forward without relying on normal playback timing.
' Parameters: animId = working value for animation id.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.
 
' FUNCTION AnimStepForward% (animId As Long), AnimStepBackward% (animId As Long)
' Purpose: Move one frame backward without relying on normal playback timing.
' Parameters: animId = working value for animation id.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.








