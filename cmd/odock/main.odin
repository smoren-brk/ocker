package main

import "core:fmt"
import odock "../../odock"

main :: proc() {

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

