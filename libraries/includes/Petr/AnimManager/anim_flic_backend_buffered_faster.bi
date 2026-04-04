' =========================================================
' Commented source copy for the FLIC/FLC backend.
' Explanatory comments were added in English without altering executable code.
' =========================================================
' + "' =========================================================
' FLIC / FLI / FLC multi-instance backend module for QB64PE
' Include-friendly: no demo code, no SCREEN, no END, no input loop.
' Public API prefix: Flic...
'
' Design note:
' Each opened animation keeps its own decode state, palette, pixel buffer
' and frame index. Playback therefore advances frame-by-frame for every
' instance independently and does not rebuild from frame 0 on every draw.
' =========================================================

' =========================================================
' Constants
' =========================================================
' Constant: FRAME_MAGIC is a named constant for frame magic.
Const FRAME_MAGIC& = 61946

' Constant: CHUNK_COLOR_256 is a named constant for chunk color 256.
Const CHUNK_COLOR_256& = 4
' Constant: CHUNK_DELTA_FLC is a named constant for chunk delta FLC.
Const CHUNK_DELTA_FLC& = 7
' Constant: CHUNK_COLOR_64 is a named constant for chunk color 64.
Const CHUNK_COLOR_64& = 11
' Constant: CHUNK_DELTA_FLI is a named constant for chunk delta FLI.
Const CHUNK_DELTA_FLI& = 12
' Constant: CHUNK_BLACK is a named constant for chunk black.
Const CHUNK_BLACK& = 13
' Constant: CHUNK_BYTE_RUN is a named constant for chunk byte run.
Const CHUNK_BYTE_RUN& = 15
' Constant: CHUNK_COPY is a named constant for chunk copy.
Const CHUNK_COPY& = 16
' Constant: CHUNK_PSTAMP is a named constant for chunk pstamp.
Const CHUNK_PSTAMP& = 18
' Constant: FRAME_HEADER_SIZE is a named constant for frame header size.
Const FRAME_HEADER_SIZE& = 16

' Constant: DELTA_OPCODE_PACKET is a named constant for delta opcode packet.
Const DELTA_OPCODE_PACKET& = 0
' Constant: DELTA_OPCODE_LASTPIXEL is a named constant for delta opcode lastpixel.
Const DELTA_OPCODE_LASTPIXEL& = 32768
' Constant: DELTA_OPCODE_LINESKIP is a named constant for delta opcode lineskip.
Const DELTA_OPCODE_LINESKIP& = 49152
' Constant: DELTA_OPCODE_MASK is a named constant for delta opcode mask.
Const DELTA_OPCODE_MASK& = 49152
' Constant: DELTA_PACKET_MASK is a named constant for delta packet mask.
Const DELTA_PACKET_MASK& = 16383

' Constant: FLI_MAGIC is a FLIC/FLC-specific constant used while parsing or decoding Autodesk animation data.
Const FLI_MAGIC& = 44817
' Constant: FLC_MAGIC is a FLIC/FLC-specific constant used while parsing or decoding Autodesk animation data.
Const FLC_MAGIC& = 44818

' Constant: ANIM_FORMAT_NONE is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANIM_FORMAT_NONE& = 0
' Constant: ANIM_FORMAT_FLI is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANIM_FORMAT_FLI& = 1
' Constant: ANIM_FORMAT_FLC is a ANI/RIFF constant used while parsing Windows animated cursor files.
Const ANIM_FORMAT_FLC& = 2
' Constant: FLIC_SNAPSHOT_INTERVAL is a FLIC/FLC-specific constant used while parsing or decoding Autodesk animation data.
Const FLIC_SNAPSHOT_INTERVAL& = 8

' =========================================================
' Types
' =========================================================
' Record layout: RGBColorType groups related fields used by the FLIC/FLC backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type RGBColorType
    ' Field: R stores the color component or packed color helper used during image conversion.
    R As _Unsigned _Byte
    ' Field: G stores the color component or packed color helper used during image conversion.
    G As _Unsigned _Byte
    ' Field: B stores the color component or packed color helper used during image conversion.
    B As _Unsigned _Byte
End Type

' Record layout: FLICHeaderType groups related fields used by the FLIC/FLC backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type FLICHeaderType
    ' Field: FileSize stores the working value for file size.
    FileSize As _Unsigned Long
    ' Field: Magic stores the working value for magic.
    Magic As Long
    ' Field: Frames stores the dynamic array that stores per-frame data or cached frame metadata.
    Frames As Long
    ' Field: Width stores the width value used by this routine.
    Width As Long
    ' Field: Height stores the height value used by this routine.
    Height As Long
    ' Field: Depth stores the working value for depth.
    Depth As Long
    ' Field: Flags stores the working value for flags.
    Flags As Long
    ' Field: SpeedMS stores the time value measured in milliseconds.
    SpeedMS As _Unsigned Long
    ' Field: OfFrame1 stores the working value for of frame 1.
    OfFrame1 As _Unsigned Long
    ' Field: OfFrame2 stores the working value for of frame 2.
    OfFrame2 As _Unsigned Long
End Type

' Record layout: FlicStore groups related fields used by the FLIC/FLC backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type FlicStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FormatType stores the working value for format type.
    FormatType As Long
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
    ' Field: FrameCount stores the total number of frames available for the current animation.
    FrameCount As Long
    ' Field: DefaultDelayMS stores the frame delay or timing value.
    DefaultDelayMS As _Unsigned Long
    ' Field: CurrentFrame stores the zero-based frame index currently selected for display or playback.
    CurrentFrame As Long
    ' Field: DecodedFrame stores the working value for decoded frame.
    DecodedFrame As Long
    ' Field: Playing stores the flag telling whether playback is currently running.
    Playing As Integer
    ' Field: Paused stores the flag telling whether playback is temporarily paused.
    Paused As Integer
    ' Field: Looping stores the working value for looping.
    Looping As Integer
    ' Field: LastTick stores the working value for last tick.
    LastTick As Double
    ' Field: NextTick stores the absolute timer target for the next frame advance.
    NextTick As Double
    ' Field: RemainingDelay stores the time still left before the next frame should be shown.
    RemainingDelay As Double
    ' Field: LastRawTimer stores the raw timer snapshot used to measure elapsed playback time.
    LastRawTimer As Double
    ' Field: CanvasImage stores the QB64 image handle used to store or draw decoded pixels.
    CanvasImage As Long
    ' Field: ImageDirty stores the working value for image dirty.
    ImageDirty As Integer
    ' Field: PaletteDirty stores the palette storage or palette index used during indexed-color decoding.
    PaletteDirty As Integer
    ' Field: DirtyValid stores the working value for dirty valid.
    DirtyValid As Integer
    ' Field: DirtyLeft stores the working value for dirty left.
    DirtyLeft As Long
    ' Field: DirtyTop stores the working value for dirty top.
    DirtyTop As Long
    ' Field: DirtyRight stores the working value for dirty right.
    DirtyRight As Long
    ' Field: DirtyBottom stores the working value for dirty bottom.
    DirtyBottom As Long
    ' Field: HeaderData stores the buffer that holds raw, packed, or decoded byte data.
    HeaderData As FLICHeaderType
    ' Field: FileDataStart stores the buffer that holds raw, packed, or decoded byte data.
    FileDataStart As Long
    ' Field: FileDataSize stores the buffer that holds raw, packed, or decoded byte data.
    FileDataSize As _Integer64
    ' Field: PixelStart stores the working value for pixel start.
    PixelStart As Long
    ' Field: PixelCount stores the count used to size or iterate the current data set.
    PixelCount As Long
    ' Field: FrameInfoStart stores the working value for frame info start.
    FrameInfoStart As Long
    ' Field: HasRingFrame stores the Boolean-like flag used by the current routine.
    HasRingFrame As Integer
    ' Field: RingFrameOffset64 stores the working value for ring frame offset 64.
    RingFrameOffset64 As _Integer64
    ' Field: RingFrameSize64 stores the working value for ring frame size 64.
    RingFrameSize64 As _Integer64
    ' Field: SnapshotMetaStart stores the working value for snapshot meta start.
    SnapshotMetaStart As Long
    ' Field: SnapshotCount stores the count used to size or iterate the current data set.
    SnapshotCount As Long
    ' Field: SnapshotInterval stores the working value for snapshot interval.
    SnapshotInterval As Long
End Type

' Record layout: FlicSnapshotStore groups related fields used by the FLIC/FLC backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type FlicSnapshotStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FrameIndex stores the index variable used to address the current item.
    FrameIndex As Long
    ' Field: PixelStart stores the working value for pixel start.
    PixelStart As Long
    ' Field: PaletteIndex stores the index variable used to address the current item.
    PaletteIndex As Long
End Type

' =========================================================
' Shared store for opened animations
' =========================================================
' Shared dynamic array: FlicItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared FlicItems(0) As FlicStore
' Shared dynamic array: FlicFileNames is resized here to hold the parallel array that remembers the source filename for each active entry.
ReDim Shared FlicFileNames(0) As String
' Shared dynamic array: FlicErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared FlicErrorTexts(0) As String

' =========================================================
' Shared decoded state pools
' =========================================================
' Shared dynamic array: FlicPaletteData is resized here to hold the palette storage or palette index used during indexed-color decoding.
ReDim Shared FlicPaletteData(0 To 255, 0 To 0) As RGBColorType
' Shared dynamic array: FlicPalette32Data is resized here to hold the palette storage or palette index used during indexed-color decoding.
ReDim Shared FlicPalette32Data(0 To 255, 0 To 0) As _Unsigned Long
' Shared dynamic array: FlicPixelData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicPixelData(0) As _Unsigned _Byte
' Shared dynamic array: FlicFrameOffsets64 is resized here to hold the working value for FLIC frame offsets 64.
ReDim Shared FlicFrameOffsets64(0) As _Integer64
' Shared dynamic array: FlicRow32Data is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicRow32Data(0) As _Unsigned Long
' Shared dynamic array: FlicSnapshotMeta is resized here to hold the working value for FLIC snapshot meta.
ReDim Shared FlicSnapshotMeta(0) As FlicSnapshotStore
' Shared dynamic array: FlicSnapshotPixels is resized here to hold the working value for FLIC snapshot pixels.
ReDim Shared FlicSnapshotPixels(0) As _Unsigned _Byte
' Shared dynamic array: FlicSnapshotPalette is resized here to hold the palette storage or palette index used during indexed-color decoding.
ReDim Shared FlicSnapshotPalette(0 To 255, 0 To 0) As RGBColorType

' =========================================================
' Shared file storage and frame decode view
' =========================================================
' Shared dynamic array: FlicFileData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicFileData(0) As _Unsigned _Byte
' Shared variable: FlicFileDataNext stores the buffer that holds raw, packed, or decoded byte data.
Dim Shared FlicFileDataNext As Long
' Shared variable: FlicFileDataCapacity stores the buffer that holds raw, packed, or decoded byte data.
Dim Shared FlicFileDataCapacity As Long
' Shared variable: FlicFrameViewStart stores the working value for FLIC frame view start.
Dim Shared FlicFrameViewStart As Long
' Shared variable: FlicFrameViewPos stores the working value for FLIC frame view pos.
Dim Shared FlicFrameViewPos As Long
' Shared variable: FlicFrameViewLimit stores the working value for FLIC frame view limit.
Dim Shared FlicFrameViewLimit As Long
' Shared variable: FlicSlotCapacity stores the working value for FLIC slot capacity.
Dim Shared FlicSlotCapacity As Long

' =========================================================
' Shared scratch buffers for file IO and fast clears
' =========================================================
' Shared dynamic array: FlicIoChunkData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicIoChunkData(0) As _Unsigned _Byte
' Shared dynamic array: FlicIoTailData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicIoTailData(0) As _Unsigned _Byte
' Shared dynamic array: FlicZeroFillData is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared FlicZeroFillData(0) As _Unsigned _Byte
' Shared variable: FlicIoChunkCapacity stores the working value for FLIC io chunk capacity.
Dim Shared FlicIoChunkCapacity As Long
' Shared variable: FlicIoTailCapacity stores the working value for FLIC io tail capacity.
Dim Shared FlicIoTailCapacity As Long
' Shared variable: FlicZeroFillCapacity stores the working value for FLIC zero fill capacity.
Dim Shared FlicZeroFillCapacity As Long

' =========================================================
' Internal decode context selector for helper routines
' =========================================================
' Shared variable: FlicDecodeContextId stores the working value for FLIC decode context id.
Dim Shared FlicDecodeContextId As Long
' Shared variable: FlicPixelDataNext stores the buffer that holds raw, packed, or decoded byte data.
Dim Shared FlicPixelDataNext As Long
' Shared variable: FlicPixelDataCapacity stores the buffer that holds raw, packed, or decoded byte data.
Dim Shared FlicPixelDataCapacity As Long
' Shared variable: FlicFrameOffsetsNext stores the working value for FLIC frame offsets next.
Dim Shared FlicFrameOffsetsNext As Long
' Shared variable: FlicFrameOffsetsCapacity stores the working value for FLIC frame offsets capacity.
Dim Shared FlicFrameOffsetsCapacity As Long
' Shared variable: FlicRow32Capacity stores the row pointer, row buffer, or row index used for image processing.
Dim Shared FlicRow32Capacity As Long
' Shared variable: FlicSnapshotMetaNext stores the working value for FLIC snapshot meta next.
Dim Shared FlicSnapshotMetaNext As Long
' Shared variable: FlicSnapshotMetaCapacity stores the working value for FLIC snapshot meta capacity.
Dim Shared FlicSnapshotMetaCapacity As Long
' Shared variable: FlicSnapshotPixelsNext stores the working value for FLIC snapshot pixels next.
Dim Shared FlicSnapshotPixelsNext As Long
' Shared variable: FlicSnapshotPixelsCapacity stores the working value for FLIC snapshot pixels capacity.
Dim Shared FlicSnapshotPixelsCapacity As Long
' Shared variable: FlicSnapshotPaletteNext stores the palette storage or palette index used during indexed-color decoding.
Dim Shared FlicSnapshotPaletteNext As Long
' Shared variable: FlicSnapshotPaletteCapacity stores the palette storage or palette index used during indexed-color decoding.
Dim Shared FlicSnapshotPaletteCapacity As Long
