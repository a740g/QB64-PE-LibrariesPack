$If WIN Then
    $If 32BIT Then
        Declare Dynamic Library "webpanim32"
    $Else
        Declare Dynamic Library "webpanim64"
    $End If
$Else
    Declare Dynamic Library "libwebpanim"
$End If
    Function wp_open_memory& (ByVal srcData As _Offset, ByVal srcSize As Long, handle As _Offset)
    Function wp_get_info& (ByVal handle As _Offset, width As Long, height As Long, frameCount As Long, loopCount As Long)
    Function wp_get_next_rgba& (ByVal handle As _Offset, ByVal dstRgba As _Offset, ByVal dstSize As Long, timeStampMs As Long)
    Function wp_get_next_bgra& (ByVal handle As _Offset, ByVal dstBgra As _Offset, ByVal dstSize As Long, timeStampMs As Long)
    Function wp_reset& (ByVal handle As _Offset)
    Function wp_close& (ByVal handle As _Offset)
    Function wp_get_last_error& (ByVal handle As _Offset, ByVal dstText As _Offset, ByVal dstSize As Long)
End Declare

Const WP_OK = 1
Const WP_ERROR = 0
Const WP_END = 2

Const WEBPANIM_FMT_WEBP = 5
Const WEBPANIM_LOOP_FILE_DEFAULT = -2
Const WEBPANIM_LOOP_FOREVER = -1
Const WEBPANIM_LOOP_ONCE = 0

Type WebPAnimClock
    WrapOffset As Double
    LastRaw As Double
End Type

Type WebPAnimStore
    Used As Integer
    DecHandle As _Offset
    CanvasWidth As Long
    CanvasHeight As Long
    FrameCount As Long
    FileLoopCount As Long
    LoopMode As Long
    LoopIteration As Long
    CurrentFrame As Long
    CurrentStampMs As Long
    Playing As Integer
    Paused As Integer
    HaveFrame As Integer
    FrameBytes As Long
    FrameImage As Long
    AnimationStart As Double
    PauseMoment As Double
    ClockState As WebPAnimClock
End Type

ReDim Shared WebPAnimItems(0) As WebPAnimStore
ReDim Shared WebPAnimSourceFiles(0) As String
ReDim Shared WebPAnimErrors(0) As String

