' =========================================================
' Commented source copy for the GIF89A backend.
' Explanatory comments were added in English without altering executable code.
' =========================================================
' GIF89a backend prepared for unified Anim... dispatcher
' Demo code removed. Public names use Gif89a... prefix.

' Constant: GIF89A_FMT_GIF87A is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_FMT_GIF87A = 1
' Constant: GIF89A_FMT_GIF89A is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_FMT_GIF89A = 2

' Constant: GIF89A_LOOP_FILE_DEFAULT is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_LOOP_FILE_DEFAULT = -2
' Constant: GIF89A_LOOP_FOREVER is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_LOOP_FOREVER = -1
' Constant: GIF89A_LOOP_ONCE is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_LOOP_ONCE = 0
' Constant: GIF89A_SNAPSHOT_INTERVAL is a GIF-specific constant used while parsing or decoding GIF89A data.
Const GIF89A_SNAPSHOT_INTERVAL& = 8

' Record layout: Gif89aFrameStore groups related fields used by the GIF89A backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type Gif89aFrameStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: LeftPx stores the working value for left px.
    LeftPx As Long
    ' Field: TopPx stores the working value for top px.
    TopPx As Long
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: DelayCs stores the frame delay or timing value.
    DelayCs As Integer
    ' Field: Disposal stores the working value for disposal.
    Disposal As Integer
    ' Field: TransparentFlag stores the working value for transparent flag.
    TransparentFlag As Integer
    ' Field: TransparentIndex stores the index variable used to address the current item.
    TransparentIndex As Integer
    ' Field: Interlaced stores the working value for interlaced.
    Interlaced As Integer
    ' Field: LocalTableFlag stores the working value for local table flag.
    LocalTableFlag As Integer
    ' Field: LocalTableCount stores the count used to size or iterate the current data set.
    LocalTableCount As Long
    ' Field: LocalTableOfs stores the working value for local table ofs.
    LocalTableOfs As Long
    ' Field: LzwMinCodeSize stores the working value for LZW min code size.
    LzwMinCodeSize As Integer
    ' Field: ImageDataOfs stores the buffer that holds raw, packed, or decoded byte data.
    ImageDataOfs As Long
End Type

' Record layout: Gif89aStore groups related fields used by the GIF89A backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type Gif89aStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: Is89a stores the Boolean-like flag used by the current routine.
    Is89a As Integer
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: BackgroundIndex stores the index variable used to address the current item.
    BackgroundIndex As Integer
    ' Field: GlobalTableFlag stores the working value for global table flag.
    GlobalTableFlag As Integer
    ' Field: GlobalTableCount stores the count used to size or iterate the current data set.
    GlobalTableCount As Long
    ' Field: GlobalTableOfs stores the working value for global table ofs.
    GlobalTableOfs As Long
    ' Field: BgColor stores the column index or color-related value.
    BgColor As _Unsigned Long
    ' Field: FrameStart stores the working value for frame start.
    FrameStart As Long
    ' Field: FrameCount stores the total number of frames available for the current animation.
    FrameCount As Long
    ' Field: CurrentFrame stores the zero-based frame index currently selected for display or playback.
    CurrentFrame As Long
    ' Field: Playing stores the flag telling whether playback is currently running.
    Playing As Integer
    ' Field: Paused stores the flag telling whether playback is temporarily paused.
    Paused As Integer
    ' Field: LoopMode stores the loop policy that controls whether playback stops or repeats.
    LoopMode As Long
    ' Field: FileLoopCount stores the count used to size or iterate the current data set.
    FileLoopCount As Long
    ' Field: LoopIteration stores the counter of completed playback loops.
    LoopIteration As Long
    ' Field: NextTick stores the absolute timer target for the next frame advance.
    NextTick As Double
    ' Field: RemainingDelay stores the time still left before the next frame should be shown.
    RemainingDelay As Double
    ' Field: LastRawTimer stores the raw timer snapshot used to measure elapsed playback time.
    LastRawTimer As Double
    ' Field: CanvasHandle stores the handle used to reference an external or QB64 resource.
    CanvasHandle As Long
    ' Field: RestoreHandle stores the handle used to reference an external or QB64 resource.
    RestoreHandle As Long
    ' Field: RenderedFrame stores the working value for rendered frame.
    RenderedFrame As Long
    ' Field: SnapshotMetaStart stores the working value for snapshot meta start.
    SnapshotMetaStart As Long
    ' Field: SnapshotCount stores the count used to size or iterate the current data set.
    SnapshotCount As Long
    ' Field: SnapshotInterval stores the working value for snapshot interval.
    SnapshotInterval As Long
End Type

' Record layout: Gif89aSnapshotStore groups related fields used by the GIF89A backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type Gif89aSnapshotStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FrameIndex stores the index variable used to address the current item.
    FrameIndex As Long
    ' Field: CanvasHandle stores the handle used to reference an external or QB64 resource.
    CanvasHandle As Long
    ' Field: RestoreHandle stores the handle used to reference an external or QB64 resource.
    RestoreHandle As Long
End Type

' Shared dynamic array: Gif89aFrames is resized here to hold the dynamic array that stores per-frame data or cached frame metadata.
ReDim Shared Gif89aFrames(0) As Gif89aFrameStore
' Shared dynamic array: Gif89aItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared Gif89aItems(0) As Gif89aStore
' Shared dynamic array: Gif89aRawData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared Gif89aRawData(0) As String
' Shared dynamic array: Gif89aErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared Gif89aErrorTexts(0) As String
' Shared dynamic array: Gif89aDecodePrefix is resized here to hold the working value for GIF89A decode prefix.
ReDim Shared Gif89aDecodePrefix(0) As Long
' Shared dynamic array: Gif89aDecodeSuffix is resized here to hold the working value for GIF89A decode suffix.
ReDim Shared Gif89aDecodeSuffix(0) As Integer
' Shared dynamic array: Gif89aDecodeStack is resized here to hold the working value for GIF89A decode stack.
ReDim Shared Gif89aDecodeStack(0) As Integer
' Shared dynamic array: Gif89aFrameIndexScratch is resized here to hold the working value for GIF89A frame index scratch.
ReDim Shared Gif89aFrameIndexScratch(0) As Integer
' Shared dynamic array: Gif89aDrawIndexScratch is resized here to hold the working value for GIF89A draw index scratch.
ReDim Shared Gif89aDrawIndexScratch(0) As Integer
' Shared dynamic array: Gif89aPaletteRgbaScratch is resized here to hold the palette storage or palette index used during indexed-color decoding.
ReDim Shared Gif89aPaletteRgbaScratch(0) As _Unsigned Long
' Shared dynamic array: Gif89aSnapshotMeta is resized here to hold the working value for GIF89A snapshot meta.
ReDim Shared Gif89aSnapshotMeta(0) As Gif89aSnapshotStore
' Shared variable: Gif89aFrameTail stores the working value for GIF89A frame tail.
Dim Shared Gif89aFrameTail As Long
' Shared variable: Gif89aSnapshotMetaNext stores the working value for GIF89A snapshot meta next.
Dim Shared Gif89aSnapshotMetaNext As Long
' Shared variable: Gif89aSnapshotMetaCapacity stores the working value for GIF89A snapshot meta capacity.
Dim Shared Gif89aSnapshotMetaCapacity As Long



' Purpose: Seek to a specific GIF89A frame or time position.
' Parameters: gifId = working value for GIF id; frameIndex = index variable used to address the current item.
' Return value: the function result follows the success/failure or data-return convention used by this module.
' Declaration only: the executable body is implemented later in the matching .bm module.
DECLARE FUNCTION Gif89aSeekFrame% (gifId As Long, frameIndex As Long)
