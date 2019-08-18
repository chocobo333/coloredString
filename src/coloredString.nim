# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.


## Module that outputs colored string to standard output (terminal).

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
        Magenda
        Cyan
        White
    rgb = (int8, int8, int8)
    Color {.union.} = object
        rgb: rgb
        colorCode: int8
        num: ColorNum
    ColoredString = object
        data: string
        modification: Modification
        colorMode: ColorMode
        color: Color

proc `$`*(self: ColoredString): string =
    if ord(self.modification) != 0:
        result &= "\e[" & $ord(self.modification) & "m"
    case self.colorMode:
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

template colorNum*(a: untyped) =
    result = colorString(self)
    result.colorMode = ColorMode.ColorNum
    result.color.num = ColorNum.a

proc red*[T: HasString](self: T): ColoredString =
    colorNum(Red)

proc green*[T: HasString](self: T): ColoredString =
    colorNum(Green)

proc blue*[T: HasString](self: T): ColoredString =
    colorNum(Blue)

proc bold*[T: HasString](self: T): ColoredString =
    result = colorString(self)
    result.modification = Modification.Bold