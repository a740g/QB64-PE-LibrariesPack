$IF VERSION < 4.3.0 THEN
    $ERROR "The Libraries Pack add-on needs at least QB64-PE v4.3.0"
$END IF

$USELIBRARY:'Petr/AnimManager'

'--- Find the root of the program's source folder.
DIM AS STRING sep, root, qbfo, filename, oldDir
oldDir = _CWD$
$IF WIN THEN
    sep$ = "\"
$ELSE
    sep$ = "/"
$END IF
filename$ = MID$(COMMAND$(0), _INSTRREV(COMMAND$(0), sep$) + 1)
filename$ = MID$(filename$, 1, LEN(filename$) - 4) + ".bas"

IF _FILEEXISTS(filename$) THEN
    root$ = ""
ELSEIF _FILEEXISTS("qb64pe.exe") _ORELSE _FILEEXISTS("qb64pe") THEN
    root$ = "libraries\examples\Petr\AnimManager\"
    CHDIR root$
ELSE
    qbfo$ = _SELECTFOLDERDIALOG$("Please locate your QB64-PE main folder...")
    IF LEN(qbfo$) > 0 _ANDALSO (_FILEEXISTS(qbfo$ + "\qb64pe.exe") _ORELSE _FILEEXISTS(qbfo$ + "\qb64pe")) THEN
        root$ = qbfo$ + "\libraries\examples\Petr\AnimManager\"
    ELSE
        PRINT
        PRINT "ERROR: Can't locate the program's source folder, please run again"
        PRINT "       and select your QB64-PE folder when ask for it."
        END
    END IF
END IF
'-----


'need WebP support? Look here: https://github.com/QB64Petr/AnimManager/tree/Anim_manager_library_source

' Variable: screenImage stores the QB64 image handle used to store or draw decoded pixels.
DIM screenImage AS LONG
' Array: fileNames stores the parallel array that remembers the source filename for each active entry.
DIM fileNames(1 TO 4) AS STRING
' Array: animIds stores the working value for animation ids.
DIM animIds(1 TO 4) AS LONG
' Array: posX stores the working value for pos x.
DIM posX(1 TO 4) AS SINGLE
' Array: posY stores the working value for pos y.
DIM posY(1 TO 4) AS SINGLE
' Array: velX stores the working value for vel x.
DIM velX(1 TO 4) AS SINGLE
' Array: velY stores the working value for vel y.
DIM velY(1 TO 4) AS SINGLE
' Array: drawW stores the working value for draw w.
DIM drawW(1 TO 4) AS LONG
' Array: drawH stores the working value for draw h.
DIM drawH(1 TO 4) AS LONG
' Variable: i stores the general-purpose loop index.
DIM i AS LONG
' Variable: keyCode stores the working value for key code.
DIM keyCode AS LONG
' Variable: quitFlag stores the working value for quit flag.
DIM quitFlag AS INTEGER
' Variable: screenW stores the working value for screen w.
DIM screenW AS LONG
' Variable: screenH stores the working value for screen h.
DIM screenH AS LONG
' Variable: labelY stores the working value for label y.
DIM labelY AS LONG

fileNames(1) = "phoenix1.ani"
fileNames(2) = "valkyrie.anim"
fileNames(3) = "Belinda.fli"
fileNames(4) = "aaaa.gif"

screenW = 1280
screenH = 720

screenImage = _NEWIMAGE(screenW, screenH, 32)
SCREEN screenImage
_TITLE "Anim manager demo 11 - bouncing windows"


' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
' The loop order matters because later statements expect the data to be visited sequentially.
FOR i = 1 TO 4
    animIds(i) = AnimOpen(fileNames(i))
    IF animIds(i) >= 0 THEN
        AnimSetLoop animIds(i), ANIM_LOOP_FOREVER
        AnimStart animIds(i)
    END IF
NEXT i

posX(1) = 30: posY(1) = 80: velX(1) = 2.2: velY(1) = 1.4
posX(2) = 420: posY(2) = 120: velX(2) = -1.7: velY(2) = 1.9
posX(3) = 780: posY(3) = 260: velX(3) = 2.4: velY(3) = -1.2
posX(4) = 900: posY(4) = 60: velX(4) = -2.0: velY(4) = 1.5

' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
' The loop order matters because later statements expect the data to be visited sequentially.
FOR i = 1 TO 4
    drawW(i) = 260
    drawH(i) = 180
NEXT i

' Loop purpose: repeat this block until an internal exit condition decides that the current stage is complete.
DO
    keyCode = _KEYHIT
    IF keyCode = 27 THEN quitFlag = -1

    CLS , _RGB32(8, 10, 14)
    _PRINTSTRING (20, 20), "Demo 11: bouncing animated windows in Anim manager"
    _PRINTSTRING (20, 42), "Esc = end"

    ' Loop purpose: use i as a counter/index while the routine processes a repeated set of values.
    ' The loop order matters because later statements expect the data to be visited sequentially.
    FOR i = 1 TO 4
        IF animIds(i) >= 0 THEN AnimUpdate animIds(i)

        posX(i) = posX(i) + velX(i)
        posY(i) = posY(i) + velY(i)

        IF posX(i) < 10 THEN posX(i) = 10: velX(i) = -velX(i)
        IF posY(i) < 70 THEN posY(i) = 70: velY(i) = -velY(i)
        IF posX(i) + drawW(i) > screenW - 10 THEN posX(i) = screenW - 10 - drawW(i): velX(i) = -velX(i)
        IF posY(i) + drawH(i) > screenH - 10 THEN posY(i) = screenH - 10 - drawH(i): velY(i) = -velY(i)

        LINE (INT(posX(i)) - 2, INT(posY(i)) - 24)-(INT(posX(i)) + drawW(i) + 1, INT(posY(i)) + drawH(i) + 1), _RGB32(100, 130, 180), BF
        LINE (INT(posX(i)) - 2, INT(posY(i)) - 24)-(INT(posX(i)) + drawW(i) + 1, INT(posY(i)) + drawH(i) + 1), _RGB32(255, 255, 255), B
        _PRINTSTRING (INT(posX(i)) + 8, INT(posY(i)) - 18), fileNames(i)

        IF animIds(i) >= 0 THEN
            DrawAnimFit animIds(i), INT(posX(i)), INT(posY(i)), drawW(i), drawH(i)
        END IF

        labelY = INT(posY(i)) + drawH(i) + 6
        IF animIds(i) >= 0 THEN
            _PRINTSTRING (INT(posX(i)), labelY), "frame " + LTRIM$(STR$(AnimGetPos(animIds(i))))
        END IF
    NEXT i

    _DISPLAY
    _LIMIT 60
LOOP UNTIL quitFlag
AnimFreeAll
CHDIR oldDir
END

' Purpose: Routine for the demo program: handle draw animation fit.
' Parameters: animId = working value for animation id; boxX = working value for box x; boxY = working value for box y; boxW = working value for box w; boxH = working value for box h.
SUB DrawAnimFit (animId AS LONG, boxX AS LONG, boxY AS LONG, boxW AS LONG, boxH AS LONG)
    ' Variable: srcW stores the working value for src w.
    DIM srcW AS LONG
    ' Variable: srcH stores the working value for src h.
    DIM srcH AS LONG
    ' Variable: drawW stores the working value for draw w.
    DIM drawW AS LONG
    ' Variable: drawH stores the working value for draw h.
    DIM drawH AS LONG
    ' Variable: drawX stores the working value for draw x.
    DIM drawX AS LONG
    ' Variable: drawY stores the working value for draw y.
    DIM drawY AS LONG
    ' Variable: scaleX stores the working value for scale x.
    DIM scaleX AS DOUBLE
    ' Variable: scaleY stores the working value for scale y.
    DIM scaleY AS DOUBLE
    ' Variable: scaleValue stores the working value for scale value.
    DIM scaleValue AS DOUBLE

    IF AnimValid(animId) = 0 THEN EXIT SUB

    srcW = AnimWidth(animId)
    srcH = AnimHeight(animId)
    IF srcW <= 0 OR srcH <= 0 THEN EXIT SUB
    IF boxW <= 0 OR boxH <= 0 THEN EXIT SUB

    scaleX = boxW / srcW
    scaleY = boxH / srcH

    IF scaleX < scaleY THEN
        scaleValue = scaleX
    ELSE
        scaleValue = scaleY
    END IF

    IF scaleValue <= 0 THEN EXIT SUB

    drawW = CLNG(srcW * scaleValue)
    drawH = CLNG(srcH * scaleValue)
    IF drawW < 1 THEN drawW = 1
    IF drawH < 1 THEN drawH = 1

    drawX = boxX + (boxW - drawW) \ 2
    drawY = boxY + (boxH - drawH) \ 2

    AnimDrawWindow drawX, drawY, drawX + drawW - 1, drawY + drawH - 1, animId
END SUB


