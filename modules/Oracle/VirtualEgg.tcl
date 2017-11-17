proc bind {args} {
}

proc putlog {text} {
}

proc puthelp {text} {
}

proc putloglev {text} {
}

proc setudef {args} {
}

proc rand {max} {
    set maxFactor [expr [expr $max + 1]]
    set value [expr int([expr rand() * 100])]
    set value [expr [expr $value % $maxFactor]]
return $value
}

proc md5 {text} {
    return ::md5::md5 text
}

proc unixtime {} {
    return [clock milliseconds]
}
