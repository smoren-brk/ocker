package main

import "core:os"
import "core:fmt"
import "core:flags"
import "../ocker"
import "../ocker/image"
import "../ocker/container"

version_info :: proc() {
    version_info, err := ocker.version()
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
    image_list, err := image.list()
    defer delete(image_list)
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

list_containers :: proc() {
    containers, err := container.list()
    defer delete(containers)
    if err != nil {
        panic("Image listing failed")
    }

    for container in containers {
       fmt.printf("%s : %s, %s", container.Image, container.State, container.Status)
    }
}

hello_world :: proc() {
    response, err := container.create("alpine", `["sleep","20"]`)
    if err != nil {
        panic("Cannot create container")
    }

    container.start(response.Id)
}

pull_alpine :: proc() {
    image.pull("alpine", "latest")
}

main :: proc() {
    Options :: struct {
        version: bool `usage:"Show docker version info"`,
        image_ls: bool `usage:"List images"`,
        hellope: bool `usage:"Run hello world"`,
        pull: bool `usage:"Pull alpine latest"`,
        ps: bool `usage:"List containers"`
    }

    opt: Options
    flags.parse_or_exit(&opt, os.args)

    if opt.version {
        version_info()
    }

    if opt.image_ls {
        list_images()
    }

    if opt.hellope {
        hello_world()
    }

    if opt.pull {
        pull_alpine()
    }

    if opt.ps {
        list_containers()
    }
}
