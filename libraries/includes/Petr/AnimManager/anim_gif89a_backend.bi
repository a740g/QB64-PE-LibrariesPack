' GIF89a backend prepared for unified Anim... dispatcher
' Demo code removed. Public names use Gif89a... prefix.

Const GIF89A_FMT_GIF87A = 1
Const GIF89A_FMT_GIF89A = 2

Const GIF89A_LOOP_FILE_DEFAULT = -2
Const GIF89A_LOOP_FOREVER = -1
Const GIF89A_LOOP_ONCE = 0

Type Gif89aFrameStore
    Used As Integer
    LeftPx As Long
    TopPx As Long
    WidthPx As Long
    HeightPx As Long
    DelayCs As Integer
    Disposal As Integer
    TransparentFlag As Integer
    TransparentIndex As Integer
    Interlaced As Integer
    LocalTableFlag As Integer
    LocalTableCount As Long
    LocalTableOfs As Long
    LzwMinCodeSize As Integer
    ImageDataOfs As Long
End Type

Type Gif89aStore
    Used As Integer
    Is89a As Integer
    WidthPx As Long
    HeightPx As Long
    BackgroundIndex As Integer
    GlobalTableFlag As Integer
    GlobalTableCount As Long
    GlobalTableOfs As Long
    BgColor As _Unsigned Long
    FrameStart As Long
    FrameCount As Long
    CurrentFrame As Long
    Playing As Integer
    Paused As Integer
    LoopMode As Long
    FileLoopCount As Long
    LoopIteration As Long
    NextTick As Double
    RemainingDelay As Double
    LastRawTimer As Double
    CanvasHandle As Long
    RestoreHandle As Long
    RenderedFrame As Long
End Type

ReDim Shared Gif89aFrames(0) As Gif89aFrameStore
ReDim Shared Gif89aItems(0) As Gif89aStore
ReDim Shared Gif89aRawData(0) As String
ReDim Shared Gif89aErrorTexts(0) As String


