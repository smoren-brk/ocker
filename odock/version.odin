package odock

import "core:fmt"

Component :: struct {
    Name: string,
    Version: string
}

Version_Info :: struct {
    Version: string,
    ApiVersion: string,
    MinAPIVersion: string,
    Os: string,
    Arch: string,
    Components: [dynamic]Component
}

version :: proc() -> (Version_Info, Response_Error) {
    return http_get(Version_Info, "version")
}

