package main

import "core:os"
import "core:fmt"
import "core:flags"
import odock "../../odock"

version_info :: proc() {
    version_info, err := odock.version()
    if err != nil {
        fmt.println("Version request failed")
        return
    }

    fmt.printf(
        "Docker %s, on %s (%s)\nSupported API versions: %s-%s\n",
        version_info.Version, version_info.Os, version_info.Arch,
        version_info.MinAPIVersion, version_info.ApiVersion
    )
}

main :: proc() {
    Options :: struct {
        version: bool `usage:"Show docker version info"`
    }

    opt: Options
    flags.parse_or_exit(&opt, os.args)

    if opt.version {
        version_info()
    }
}

