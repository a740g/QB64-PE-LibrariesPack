$INCLUDEONCE

$IF VERSION < 4.3.0 THEN
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$END IF


' =========================================================
' Commented source copy for the Windows ANI backend.
' Explanatory comments were added in English without altering executable code.
' =========================================================
' ANI cursor backend for RIFF ACON files
' Public names use Ani... prefix.

' Constant: ANI_LOOP_FILE_DEFAULT is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANI_LOOP_FILE_DEFAULT = -2
' Constant: ANI_LOOP_FOREVER is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANI_LOOP_FOREVER = -1
' Constant: ANI_LOOP_ONCE is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANI_LOOP_ONCE = 0

' Record layout: AniFrameStore groups related fields used by the Windows ANI backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AniFrameStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: ImageHandle stores the QB64 image handle used to store or draw decoded pixels.
    ImageHandle As Long
    ' Field: HotX stores the working value for hot x.
    HotX As Long
    ' Field: HotY stores the working value for hot y.
    HotY As Long
End Type

' Record layout: AniStepStore groups related fields used by the Windows ANI backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AniStepStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FrameIndex stores the index variable used to address the current item.
    FrameIndex As Long
    ' Field: DelayJif stores the frame delay or timing value.
    DelayJif As Long
End Type

' Record layout: AniStore groups related fields used by the Windows ANI backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AniStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: FrameStart stores the working value for frame start.
    FrameStart As Long
    ' Field: UniqueFrameCount stores the total number of frames available for the current animation.
    UniqueFrameCount As Long
    ' Field: StepStart stores the working value for step start.
    StepStart As Long
    ' Field: StepCount stores the count used to size or iterate the current data set.
    StepCount As Long
    ' Field: CurrentFrame stores the zero-based frame index currently selected for display or playback.
    CurrentFrame As Long
    ' Field: Playing stores the flag telling whether playback is currently running.
    Playing As Integer
    ' Field: Paused stores the flag telling whether playback is temporarily paused.
    Paused As Integer
    ' Field: LoopMode stores the loop policy that controls whether playback stops or repeats.
    LoopMode As Long
    ' Field: NextTick stores the absolute timer target for the next frame advance.
    NextTick As Double
    ' Field: RemainingDelay stores the time still left before the next frame should be shown.
    RemainingDelay As Double
    ' Field: LastRawTimer stores the raw timer snapshot used to measure elapsed playback time.
    LastRawTimer As Double
    ' Field: LoopIteration stores the counter of completed playback loops.
    LoopIteration As Long
End Type

' Shared dynamic array: AniFrames is resized here to hold the dynamic array that stores per-frame data or cached frame metadata.
ReDim Shared AniFrames(0) As AniFrameStore
' Shared dynamic array: AniSteps is resized here to hold the working value for ANI steps.
ReDim Shared AniSteps(0) As AniStepStore
' Shared dynamic array: AniItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared AniItems(0) As AniStore
' Shared dynamic array: AniErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared AniErrorTexts(0) As String
' Shared variable: AniItemCapacity stores the working value for ANI item capacity.
Dim Shared AniItemCapacity As Long
' Shared variable: AniFrameCapacity stores the working value for ANI frame capacity.
Dim Shared AniFrameCapacity As Long
' Shared variable: AniStepCapacity stores the working value for ANI step capacity.
Dim Shared AniStepCapacity As Long

' Purpose: Seek to a specific ANI frame or time position.
' Parameters: aniId = working value for ANI id; frameIndex = index variable used to address the current item.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.
DECLARE FUNCTION AniSeekFrame% (aniId As Long, frameIndex As Long)
