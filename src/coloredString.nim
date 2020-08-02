# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.


## This module provides a way to output decorated string to standard output (terminal) with escape sequence.

import macros
import strutils


type
    Modification {.pure.} = enum
        Nothing
        Bold
        Faint
        Italic
        Underline
        Blink
        FasterBlink
        ColorReversal
        DoNotDisplay
    ColorMode {.pure.} = enum
        Default
        Rgb
        ColorCode
        ColorNum
    ColorNum {.pure.} = enum
        Black
        Red
        Green
        Yellow
        Blue
        Magenta
        Cyan
        White
    Rgb = (int8, int8, int8)
    Color = object
        case mode: ColorMode
        of ColorMode.Default:
            nil
        of ColorMode.Rgb:
            rgb: Rgb
        of ColorMode.ColorCode:
            colorCode: int8
        of ColorMode.ColorNum:
            num: ColorNum
    ColoredString = object
        data: string
        modification: Modification
        color: Color

proc `$`*(self: ColoredString): string =
    if ord(self.modification) != 0:
        result &= "\e[" & $ord(self.modification) & "m"
    case self.color.mode:
        of ColorMode.Default:
            discard
        of ColorMode.Rgb:
            result &= "\e[38;2;" & $self.color.rgb[0] & ";" & $self.color.rgb[1] & ";" & $self.color.rgb[2] & "m"
        of ColorMode.ColorCode:
            result &= "\e[38;5;" & $self.color.colorCode & "m"
        of ColorMode.ColorNum:
            result &= "\e[3" & $ord(self.color.num) & "m"
    result &= self.data & "\e[00m"

type
    HasString = concept x
        $x is string

proc colorString(a: string): ColoredString =
    ColoredString(data: a)

proc colorString(a: ColoredString): ColoredString =
    a

proc colorString(a: HasString): ColoredString =
    ColoredString(data: $a)

template colorNum*(a: typed) =
    proc a*[T: string](self: T): ColoredString =
        result = colorString(self)
        result.color = Color(mode: ColorMode.ColorNum, num: ColorNum.a)

macro colorNum(): untyped =
    result = newStmtList()
    for e in ColorNum:
        let
            p = ident ($e).toLower
            cl = ident $e
        result.add quote do:
            proc `p`*[T: HasString](self: T): ColoredString =
                result = colorString(self)
                result.color = Color(mode: ColorMode.ColorNum, num: ColorNum.`cl`)

colorNum()

proc colorRgb*(self: HasString, r, g, b: int8): ColoredString =
    result = colorString(self)
    result.colorMode = ColorMode.Rgb
    result.color.rgb = (r, g, b)

proc rgb*[T: HasString](self: T, r, g, b: int8): ColoredString =
    result = colorString(self)
    result.color = Color(mode: ColorMode.rgb, rgb: (r, g, b))

macro modification(): untyped =
    result = newStmtList()
    for e in Modification:
        let
            p = ident ($e).toLower
            enm = ident $e
        result.add quote do:
            proc `p`*[T: HasString](self: T): ColoredString =
                result = colorString(self)
                result.modification = Modification.`enm`
modification()