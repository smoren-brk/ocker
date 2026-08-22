package query

import "core:fmt"
import "core:strings"

Query_Spec :: map[string]string

Spec_Error :: enum {
    None,
    Empty_Spec,
    Invalid_Spec,
    Invalid_Value,
    Size_Error,
    Type_Error
}

assemble :: proc (spec: Query_Spec) -> (string, Spec_Error) {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)
    strings.write_rune(&builder, '?')

    first := true
    for key, value in spec {
        if !first {
            strings.write_rune(&builder, '&')
        }
        first = false

        parameter := fmt.aprintf("%s=%s")
        strings.write_string(&builder, parameter)
    }

    query := strings.to_string(builder)

    return query, .None
}

