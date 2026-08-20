package image

import "core:fmt"

import docker_api "../docker-api"

client: docker_api.Client

list :: proc() -> ([dynamic]Listed_Image, docker_api.Error) {
    return docker_api.get(client, [dynamic]Listed_Image, "images/json")
}

history :: proc(image: string) -> ([dynamic]Image, docker_api.Error) {
    url := fmt.aprintf("images/%s/history", image)
    defer delete(url)

    return docker_api.get(client, [dynamic]Image, url)
}

// pull streams progress JSON, which does not fit the Image type, so the
// response body is consumed and discarded.
pull :: proc(image: string, tag: string) -> docker_api.Error {
    url := fmt.aprintf("images/create?fromImage=%s&tag=%s", image, tag)
    defer delete(url)

    return docker_api.send(client, .POST, url)
}

inspect :: proc(image: string) -> (Inspection, docker_api.Error) {
    url := fmt.aprintf("images/%s/json", image)
    defer delete(url)

    return docker_api.get(client, Inspection, url)
}
