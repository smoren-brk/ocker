package main

import "core:os"
import "core:fmt"
import "core:flags"
import odock "../../odock"

version_info :: proc() {
    version_info, err := odock.version()
    if err != nil {
        panic("Version request failed")
    }

    fmt.printf(
        "Docker %s, on %s (%s)\nSupported API versions: %s-%s\n",
        version_info.Version, version_info.Os, version_info.Arch,
        version_info.MinAPIVersion, version_info.ApiVersion
    )
}

list_images :: proc() {
    image_list, err := odock.list_images()
    if err != nil {
        panic("Image listing failed")
    }

    for image in image_list {
        fmt.printf(
            "[Id] %s, with size %d was created at %d\n",
            image.Id, image.Size, image.Created
        )
    }
}

main :: proc() {
    Options :: struct {
        version: bool `usage:"Show docker version info"`,
        image_ls: bool `usage:"List images"`,
    }

    opt: Options
    flags.parse_or_exit(&opt, os.args)

    if opt.version {
        version_info()
    }

    if opt.image_ls {
        list_images()
    }
}

