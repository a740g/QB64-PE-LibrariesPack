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
Const FRAME_MAGIC& = 61946

Const CHUNK_COLOR_256& = 4
Const CHUNK_DELTA_FLC& = 7
Const CHUNK_COLOR_64& = 11
Const CHUNK_DELTA_FLI& = 12
Const CHUNK_BLACK& = 13
Const CHUNK_BYTE_RUN& = 15
Const CHUNK_COPY& = 16
Const CHUNK_PSTAMP& = 18
Const FRAME_HEADER_SIZE& = 16

Const DELTA_OPCODE_PACKET& = 0
Const DELTA_OPCODE_LASTPIXEL& = 32768
Const DELTA_OPCODE_LINESKIP& = 49152
Const DELTA_OPCODE_MASK& = 49152
Const DELTA_PACKET_MASK& = 16383

Const FLI_MAGIC& = 44817
Const FLC_MAGIC& = 44818

Const ANIM_FORMAT_NONE& = 0
Const ANIM_FORMAT_FLI& = 1
Const ANIM_FORMAT_FLC& = 2

' =========================================================
' Types
' =========================================================
Type RGBColorType
    R As _Unsigned _Byte
    G As _Unsigned _Byte
    B As _Unsigned _Byte
End Type

Type FLICHeaderType
    FileSize As _Unsigned Long
    Magic As Long
    Frames As Long
    Width As Long
    Height As Long
    Depth As Long
    Flags As Long
    SpeedMS As _Unsigned Long
    OfFrame1 As _Unsigned Long
    OfFrame2 As _Unsigned Long
End Type

Type FlicStore
    Used As Integer
    FormatType As Long
    WidthPx As Long
    HeightPx As Long
    FrameCount As Long
    DefaultDelayMS As _Unsigned Long
    CurrentFrame As Long
    DecodedFrame As Long
    Playing As Integer
    Paused As Integer
    Looping As Integer
    LastTick As Double
    NextTick As Double
    CanvasImage As Long
    ImageDirty As Integer
    PaletteDirty As Integer
    DirtyValid As Integer
    DirtyLeft As Long
    DirtyTop As Long
    DirtyRight As Long
    DirtyBottom As Long
    FileNum As Integer
    HeaderData As FLICHeaderType
    PixelStart As Long
    PixelCount As Long
    FrameInfoStart As Long
    HasRingFrame As Integer
    RingFrameOffset64 As _Integer64
    RingFrameSize64 As _Integer64
End Type

' =========================================================
' Shared store for opened animations
' =========================================================
ReDim Shared FlicItems(0) As FlicStore
ReDim Shared FlicFileNames(0) As String
ReDim Shared FlicErrorTexts(0) As String

' =========================================================
' Shared decoded state pools
' =========================================================
ReDim Shared FlicPaletteData(0 To 255, 0 To 0) As RGBColorType
ReDim Shared FlicPalette32Data(0 To 255, 0 To 0) As _Unsigned Long
ReDim Shared FlicPixelData(0) As _Unsigned _Byte
ReDim Shared FlicFrameOffsets64(0) As _Integer64

' =========================================================
' Shared frame decode buffer
' =========================================================
ReDim Shared FlicFrameData(0) As _Unsigned _Byte
Dim Shared FlicFrameDataCapacity As Long
Dim Shared FlicFrameDataPos As Long
Dim Shared FlicFrameDataLimit As Long

' =========================================================
' Internal decode context selector for helper routines
' =========================================================
Dim Shared FlicDecodeContextId As Long
Dim Shared FlicPixelDataNext As Long
Dim Shared FlicFrameOffsetsNext As Long
