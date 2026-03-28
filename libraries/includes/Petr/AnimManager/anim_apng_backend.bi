' APNG backend prepared for unified Anim... dispatcher
' Demo code removed. Public names use Apng... prefix.

Const APNG_FMT_PNG = 1
Const APNG_FMT_APNG = 2

Const APNG_LOOP_FILE_DEFAULT = -2
Const APNG_LOOP_FOREVER = -1
Const APNG_LOOP_ONCE = 0


Type ApngFrameStore
    Used As Integer
    WidthPx As Long
    HeightPx As Long
    XOffset As Long
    YOffset As Long
    DelayNum As Integer
    DelayDen As Integer
    DisposeOp As Integer
    BlendOp As Integer
End Type

Type ApngStore
    Used As Integer
    IsAnimated As Integer
    WidthPx As Long
    HeightPx As Long
    FrameStart As Long
    FrameCount As Long
    PlayCount As Long
    DefaultImageIncluded As Integer
    CurrentFrame As Long
    Playing As Integer
    Paused As Integer
    LoopMode As Long
    NextTick As Double
    CompletedLoops As Long
    CanvasHandle As Long
    BackupHandle As Long
    RenderedFrame As Long
End Type

ReDim Shared ApngFrames(0) As ApngFrameStore
ReDim Shared ApngFrameData(0) As String
ReDim Shared ApngItems(0) As ApngStore
ReDim Shared ApngHeaderChunks(0) As String
ReDim Shared ApngIhdrData(0) As String
ReDim Shared ApngErrorTexts(0) As String

