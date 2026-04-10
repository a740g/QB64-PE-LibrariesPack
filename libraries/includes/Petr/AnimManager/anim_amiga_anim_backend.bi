$INCLUDEONCE

$IF VERSION < 4.3.0 THEN
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$END IF


' =========================================================
' Commented source copy for the Amiga ANIM backend.
' Explanatory comments were added in English without altering executable code.
' =========================================================
' AMIGA ANIM backend prepared for unified Anim... dispatcher
' Public names use AmgAnim... prefix.

' Constant: AMG_ANIM_FMT_ANIM is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_FMT_ANIM = 1

' Constant: AMG_ANIM_LOOP_FILE_DEFAULT is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_LOOP_FILE_DEFAULT = -2
' Constant: AMG_ANIM_LOOP_FOREVER is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_LOOP_FOREVER = -1
' Constant: AMG_ANIM_LOOP_ONCE is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_LOOP_ONCE = 0
' Constant: AMG_ANIM_DEFAULT_FIRST_DELAY_TICKS is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_DEFAULT_FIRST_DELAY_TICKS = 12
' Constant: AMG_ANIM_SNAPSHOT_INTERVAL is a Amiga ANIM/IFF constant used while parsing classic chunked animation data.
Const AMG_ANIM_SNAPSHOT_INTERVAL = 8

' Record layout: AmgAnimRGB8 groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimRGB8
    ' Field: r stores the color component or packed color helper used during image conversion.
    r As _Unsigned _Byte
    ' Field: g stores the color component or packed color helper used during image conversion.
    g As _Unsigned _Byte
    ' Field: b stores the color component or packed color helper used during image conversion.
    b As _Unsigned _Byte
End Type

' Record layout: AmgAnimIffChunkInfo groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimIffChunkInfo
    ' Field: id stores the working value for id.
    id As String * 4
    ' Field: size stores the size value for the current block, buffer, or file.
    size As _Unsigned Long
    ' Field: dataOfs stores the buffer that holds raw, packed, or decoded byte data.
    dataOfs As _Unsigned _Integer64
    ' Field: nextOfs stores the working value for next ofs.
    nextOfs As _Unsigned _Integer64
End Type

' Record layout: AmgAnimIlbmInfo groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimIlbmInfo
    ' Field: w stores the working value for w.
    w As Long
    ' Field: h stores the working value for h.
    h As Long
    ' Field: x stores the horizontal pixel or coordinate index.
    x As Long
    ' Field: y stores the vertical pixel or coordinate index.
    y As Long
    ' Field: nPlanes stores the working value for n planes.
    nPlanes As Long
    ' Field: masking stores the working value for masking.
    masking As Long
    ' Field: compression stores the working value for compression.
    compression As Long
    ' Field: transparentColor stores the column index or color-related value.
    transparentColor As Long
    ' Field: xAspect stores the working value for x aspect.
    xAspect As Long
    ' Field: yAspect stores the working value for y aspect.
    yAspect As Long
    ' Field: pageWidth stores the width value used by this routine.
    pageWidth As Long
    ' Field: pageHeight stores the height value used by this routine.
    pageHeight As Long
    ' Field: rowBytes stores the row pointer, row buffer, or row index used for image processing.
    rowBytes As Long
    ' Field: planeSize stores the working value for plane size.
    planeSize As Long
    ' Field: hasBMHD stores the Boolean-like flag used by the current routine.
    hasBMHD As Long
End Type

' Record layout: AmgAnimAnhdInfo groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimAnhdInfo
    ' Field: operation stores the working value for operation.
    operation As Long
    ' Field: mask stores the working value for mask.
    mask As Long
    ' Field: w stores the working value for w.
    w As Long
    ' Field: h stores the working value for h.
    h As Long
    ' Field: x stores the horizontal pixel or coordinate index.
    x As Long
    ' Field: y stores the vertical pixel or coordinate index.
    y As Long
    ' Field: abstime stores the time-related value used by the current routine.
    abstime As _Unsigned Long
    ' Field: reltime stores the time-related value used by the current routine.
    reltime As _Unsigned Long
    ' Field: interleave stores the working value for interleave.
    interleave As Long
    ' Field: bits stores the working value for bits.
    bits As _Unsigned Long
    ' Field: valid stores the working value for valid.
    valid As Long
End Type

' Record layout: AmgAnimFrameInfo groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimFrameInfo
    ' Field: fileOfs stores the working value for file ofs.
    fileOfs As _Unsigned _Integer64
    ' Field: formSize stores the working value for form size.
    formSize As _Unsigned Long

    ' Field: hasBMHD stores the Boolean-like flag used by the current routine.
    hasBMHD As Long
    ' Field: hasCMAP stores the Boolean-like flag used by the current routine.
    hasCMAP As Long
    ' Field: hasBODY stores the Boolean-like flag used by the current routine.
    hasBODY As Long
    ' Field: hasANHD stores the Boolean-like flag used by the current routine.
    hasANHD As Long
    ' Field: hasDLTA stores the Boolean-like flag used by the current routine.
    hasDLTA As Long

    ' Field: bmhdOfs stores the working value for bmhd ofs.
    bmhdOfs As _Unsigned _Integer64
    ' Field: cmapOfs stores the working value for cmap ofs.
    cmapOfs As _Unsigned _Integer64
    ' Field: cmapSize stores the working value for cmap size.
    cmapSize As _Unsigned Long
    ' Field: bodyOfs stores the working value for body ofs.
    bodyOfs As _Unsigned _Integer64
    ' Field: bodySize stores the working value for body size.
    bodySize As _Unsigned Long
    ' Field: anhdOfs stores the working value for anhd ofs.
    anhdOfs As _Unsigned _Integer64
    ' Field: dltaOfs stores the working value for dlta ofs.
    dltaOfs As _Unsigned _Integer64
    ' Field: dltaSize stores the working value for dlta size.
    dltaSize As _Unsigned Long

    ' Field: opCode stores the working value for op code.
    opCode As Long
    ' Field: reltime stores the time-related value used by the current routine.
    reltime As _Unsigned Long
    ' Field: interleave stores the working value for interleave.
    interleave As Long
    ' Field: anhdBits stores the working value for anhd bits.
    anhdBits As _Unsigned Long
End Type

' Record layout: AmgAnimInfo groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimInfo
    ' Field: frameCount stores the total number of frames available for the current animation.
    frameCount As Long
    ' Field: w stores the working value for w.
    w As Long
    ' Field: h stores the working value for h.
    h As Long
    ' Field: nPlanes stores the working value for n planes.
    nPlanes As Long
    ' Field: rowBytes stores the row pointer, row buffer, or row index used for image processing.
    rowBytes As Long
    ' Field: planeSize stores the working value for plane size.
    planeSize As Long
    ' Field: compression stores the working value for compression.
    compression As Long
    ' Field: camg stores the working value for camg.
    camg As _Unsigned Long
    ' Field: isHAM stores the Boolean-like flag used by the current routine.
    isHAM As Long
    ' Field: firstFrameReady stores the working value for first frame ready.
    firstFrameReady As Long
End Type

' Record layout: AmgAnimSnapshotStore groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimSnapshotStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: FrameIndex stores the index variable used to address the current item.
    FrameIndex As Long
    ' Field: ShownIsA stores the working value for shown is a.
    ShownIsA As Long
End Type

' Record layout: AmgAnimStore groups related fields used by the Amiga ANIM backend.
' Keeping the data in one TYPE lets the module store one structured record per active object.
Type AmgAnimStore
    ' Field: Used stores the flag telling whether the current slot or record is in use.
    Used As Integer
    ' Field: WidthPx stores the decoded image width in pixels.
    WidthPx As Long
    ' Field: HeightPx stores the decoded image height in pixels.
    HeightPx As Long
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
    ' Field: NextTick stores the absolute timer target for the next frame advance.
    NextTick As Double
    ' Field: RemainingDelay stores the time still left before the next frame should be shown.
    RemainingDelay As Double
    ' Field: LastRawTimer stores the raw timer snapshot used to measure elapsed playback time.
    LastRawTimer As Double
    ' Field: CanvasImage stores the QB64 image handle used to store or draw decoded pixels.
    CanvasImage As Long
    ' Field: RenderedFrame stores the working value for rendered frame.
    RenderedFrame As Long
    ' Field: FileDataStart stores the buffer that holds raw, packed, or decoded byte data.
    FileDataStart As Long
    ' Field: FileDataSize stores the buffer that holds raw, packed, or decoded byte data.
    FileDataSize As Long
    ' Field: NPlanes stores the working value for n planes.
    NPlanes As Long
    ' Field: RowBytes stores the row pointer, row buffer, or row index used for image processing.
    RowBytes As Long
    ' Field: PlaneSize stores the working value for plane size.
    PlaneSize As Long
    ' Field: Compression stores the working value for compression.
    Compression As Long
    ' Field: Camg stores the working value for camg.
    Camg As _Unsigned Long
    ' Field: IsHam stores the Boolean-like flag used by the current routine.
    IsHam As Long
    ' Field: PalCount stores the count used to size or iterate the current data set.
    PalCount As Long
    ' Field: PalStart stores the working value for pal start.
    PalStart As Long
    ' Field: WorkBaseStart stores the working value for work base start.
    WorkBaseStart As Long
    ' Field: WorkAStart stores the working value for work a start.
    WorkAStart As Long
    ' Field: WorkBStart stores the working value for work b start.
    WorkBStart As Long
    ' Field: ChunkyStart stores the working value for chunky start.
    ChunkyStart As Long
    ' Field: PixelsStart stores the working value for pixels start.
    PixelsStart As Long
    ' Field: DecodedFrame stores the working value for decoded frame.
    DecodedFrame As Long
    ' Field: ShownIsA stores the working value for shown is a.
    ShownIsA As Long
    ' Field: WorkReady stores the working value for work ready.
    WorkReady As Integer
    ' Field: SnapshotMetaStart stores the working value for snapshot meta start.
    SnapshotMetaStart As Long
    ' Field: SnapshotCount stores the count used to size or iterate the current data set.
    SnapshotCount As Long
    ' Field: SnapshotInterval stores the working value for snapshot interval.
    SnapshotInterval As Long
    ' Field: SnapshotPlanarAStart stores the working value for snapshot planar a start.
    SnapshotPlanarAStart As Long
    ' Field: SnapshotPlanarBStart stores the working value for snapshot planar b start.
    SnapshotPlanarBStart As Long
    ' Field: SnapshotPaletteStart stores the palette storage or palette index used during indexed-color decoding.
    SnapshotPaletteStart As Long
End Type

' Shared dynamic array: AmgAnimItems is resized here to hold the dynamic table that stores one record per live object handled by this module.
ReDim Shared AmgAnimItems(0) As AmgAnimStore
' Shared dynamic array: AmgAnimFrames is resized here to hold the dynamic array that stores per-frame data or cached frame metadata.
ReDim Shared AmgAnimFrames(0) As AmgAnimFrameInfo
' Shared dynamic array: AmgAnimFileNames is resized here to hold the parallel array that remembers the source filename for each active entry.
ReDim Shared AmgAnimFileNames(0) As String
' Shared dynamic array: AmgAnimErrorTexts is resized here to hold the text storage for the last human-readable error message.
ReDim Shared AmgAnimErrorTexts(0) As String
' Shared variable: AmgAnimFrameCountUsed stores the total number of frames available for the current animation.
Dim Shared AmgAnimFrameCountUsed As Long

' Shared dynamic array: AmgAnimSnapshotMeta is resized here to hold the working value for Amiga animation snapshot meta.
ReDim Shared AmgAnimSnapshotMeta(0) As AmgAnimSnapshotStore
' Shared variable: AmgAnimSnapshotMetaUsed stores the flag telling whether the current slot or record is in use.
Dim Shared AmgAnimSnapshotMetaUsed As Long

' Shared dynamic array: amg_anim_buf is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared amg_anim_buf(0) As _Unsigned _Byte
' Shared variable: amg_anim_file_size stores the working value for Amiga animation file size.
Dim Shared amg_anim_file_size As _Unsigned Long

' Shared dynamic array: amg_anim_data_pool is resized here to hold the buffer that holds raw, packed, or decoded byte data.
ReDim Shared amg_anim_data_pool(0) As _Unsigned _Byte
' Shared variable: amg_anim_data_pool_used stores the flag telling whether the current slot or record is in use.
Dim Shared amg_anim_data_pool_used As Long

' Shared dynamic array: amg_anim_planar_pool is resized here to hold the working value for Amiga animation planar pool.
ReDim Shared amg_anim_planar_pool(0) As _Unsigned _Byte
' Shared variable: amg_anim_planar_pool_used stores the flag telling whether the current slot or record is in use.
Dim Shared amg_anim_planar_pool_used As Long

' Shared dynamic array: amg_anim_chunky_pool is resized here to hold the working value for Amiga animation chunky pool.
ReDim Shared amg_anim_chunky_pool(0) As _Unsigned _Byte
' Shared variable: amg_anim_chunky_pool_used stores the flag telling whether the current slot or record is in use.
Dim Shared amg_anim_chunky_pool_used As Long

' Shared dynamic array: amg_anim_pixels_pool is resized here to hold the working value for Amiga animation pixels pool.
ReDim Shared amg_anim_pixels_pool(0) As _Unsigned Long
' Shared variable: amg_anim_pixels_pool_used stores the flag telling whether the current slot or record is in use.
Dim Shared amg_anim_pixels_pool_used As Long

' Shared dynamic array: amg_anim_palette_pool is resized here to hold the palette storage or palette index used during indexed-color decoding.
ReDim Shared amg_anim_palette_pool(0) As AmgAnimRGB8
' Shared variable: amg_anim_palette_pool_used stores the flag telling whether the current slot or record is in use.
Dim Shared amg_anim_palette_pool_used As Long

' Shared dynamic array: amg_anim_scratch_planar_base is resized here to hold the working value for Amiga animation scratch planar base.
ReDim Shared amg_anim_scratch_planar_base(0) As _Unsigned _Byte
' Shared dynamic array: amg_anim_scratch_planar_a is resized here to hold the working value for Amiga animation scratch planar a.
ReDim Shared amg_anim_scratch_planar_a(0) As _Unsigned _Byte
' Shared dynamic array: amg_anim_scratch_planar_b is resized here to hold the working value for Amiga animation scratch planar b.
ReDim Shared amg_anim_scratch_planar_b(0) As _Unsigned _Byte
' Shared dynamic array: amg_anim_scratch_chunky is resized here to hold the working value for Amiga animation scratch chunky.
ReDim Shared amg_anim_scratch_chunky(0) As _Unsigned _Byte
' Shared dynamic array: amg_anim_scratch_pixels is resized here to hold the working value for Amiga animation scratch pixels.
ReDim Shared amg_anim_scratch_pixels(0) As _Unsigned Long
' Shared dynamic array: amg_anim_scratch_pal is resized here to hold the working value for Amiga animation scratch pal.
ReDim Shared amg_anim_scratch_pal(0) As AmgAnimRGB8
' Shared variable: amg_anim_scratch_planar_size stores the working value for Amiga animation scratch planar size.
Dim Shared amg_anim_scratch_planar_size As Long
' Shared variable: amg_anim_scratch_chunky_size stores the working value for Amiga animation scratch chunky size.
Dim Shared amg_anim_scratch_chunky_size As Long
' Shared variable: amg_anim_scratch_pal_size stores the working value for Amiga animation scratch pal size.
Dim Shared amg_anim_scratch_pal_size As Long
' Shared variable: amg_anim_scratch_pixels_size stores the working value for Amiga animation scratch pixels size.
Dim Shared amg_anim_scratch_pixels_size As Long

' Shared variable: amg_anim_active_mode stores the working value for Amiga animation active mode.
Dim Shared amg_anim_active_mode As Long
' Shared variable: amg_anim_active_pool_ofs stores the working value for Amiga animation active pool ofs.
Dim Shared amg_anim_active_pool_ofs As Long
' Shared variable: amg_anim_active_pool_size stores the working value for Amiga animation active pool size.
Dim Shared amg_anim_active_pool_size As Long
' Shared variable: amg_anim_scratch_owner stores the working value for Amiga animation scratch owner.
Dim Shared amg_anim_scratch_owner As Long
' Shared variable: amg_anim_scratch_owner_valid stores the working value for Amiga animation scratch owner valid.
Dim Shared amg_anim_scratch_owner_valid As Long
