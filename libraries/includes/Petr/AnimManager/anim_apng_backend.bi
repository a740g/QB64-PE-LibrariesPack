$INCLUDEONCE

$IF VERSION < 4.3.0 THEN
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$END IF

' =========================================================
' Commented source copy for the APNG backend.
' Explanatory comments were added in English without altering executable code.
' =========================================================
' APNG backend prepared for unified Anim... dispatcher
' Demo code removed. Public names use Apng... prefix.

' Constant: APNG_FMT_PNG is a APNG/PNG-specific constant used while parsing or decoding chunked image data.
Const APNG_FMT_PNG = 1
' Constant: APNG_FMT_APNG is a APNG/PNG-specific constant used while parsing or decoding chunked image data.
Const APNG_FMT_APNG = 2

' Constant: APNG_LOOP_FILE_DEFAULT is a APNG/PNG-specific constant used while parsing or decoding chunked image data.
Const APNG_LOOP_FILE_DEFAULT = -2
' Constant: APNG_LOOP_FOREVER is a APNG/PNG-specific constant used while parsing or decoding chunked image data.
Const APNG_LOOP_FOREVER = -1
' Constant: APNG_LOOP_ONCE is a APNG/PNG-specific constant used while parsing or decoding chunked image data.
Const APNG_LOOP_ONCE = 0


' Record layout: ApngFrameStore groups related fields used by the APNG backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type ApngFrameStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: XOffset stores the working value for x offset.
    XOffset As Long
    ' Field: YOffset stores the working value for y offset.
    YOffset As Long
    ' Field: DelayNum stores the frame delay or timing value.
    DelayNum As Integer
    ' Field: DelayDen stores the frame delay or timing value.
    DelayDen As Integer
    ' Field: DisposeOp stores the working value for dispose op.
    DisposeOp As Integer
    ' Field: BlendOp stores the working value for blend op.
    BlendOp As Integer
    ' Field: ImageHandle stores the QB64 image handle used to store or draw decoded pixels.
    ImageHandle As Long
End Type

' Record layout: ApngStore groups related fields used by the APNG backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type ApngStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: IsAnimated stores the Boolean-like flag used by the current routine.
    IsAnimated As Integer
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: FrameStart stores the working value for frame start.
    FrameStart As Long
    ' Field: FrameCount stores the total number of frames available for the current animation.
    FrameCount As Long
    ' Field: PlayCount stores the count used to size or iterate the current data set.
    PlayCount As Long
    ' Field: DefaultImageIncluded stores the working value for default image included.
    DefaultImageIncluded As Integer
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
    ' Field: CompletedLoops stores the working value for completed loops.
    CompletedLoops As Long
    ' Field: CanvasHandle stores the handle used to reference an external or QB64 resource.
    CanvasHandle As Long
    ' Field: BackupHandle stores the handle used to reference an external or QB64 resource.
    BackupHandle As Long
    ' Field: RenderedFrame stores the working value for rendered frame.
    RenderedFrame As Long
End Type

' Shared dynamic array: ApngFrames is resized here to hold the dynamic array that stores per-frame data or cached frame metadata.
ReDim Shared ApngFrames(0) As ApngFrameStore
' Shared dynamic array: ApngFrameData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared ApngFrameData(0) As String
' Shared dynamic array: ApngItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared ApngItems(0) As ApngStore
' Shared dynamic array: ApngHeaderChunks is resized here to hold the working value for APNG header chunks.
ReDim Shared ApngHeaderChunks(0) As String
' Shared dynamic array: ApngIhdrData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared ApngIhdrData(0) As String
' Shared dynamic array: ApngErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared ApngErrorTexts(0) As String


' Shared variable: ApngItemCapacity stores the working value for APNG item capacity.
Dim Shared ApngItemCapacity As Long
' Shared variable: ApngFrameCapacity stores the working value for APNG frame capacity.
Dim Shared ApngFrameCapacity As Long
' Shared variable: ApngFrameTail stores the working value for APNG frame tail.
Dim Shared ApngFrameTail As Long

' Purpose: Seek to a specific APNG frame or time position.
' Parameters: apngId = working value for APNG id; frameIndex = index variable used to address the current item.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.
DECLARE FUNCTION ApngSeekFrame% (apngId As Long, frameIndex As Long)
