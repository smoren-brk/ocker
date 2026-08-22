package image

import "core:fmt"
import "core:encoding/json"

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

manifest_kind_unmarshaller :: proc(p: ^json.Parser, v: any) -> json.Unmarshal_Error {
    str, err := json.unquote_string(
        p.curr_token,
        p.spec,
        p.allocator,
    )
    if err != .None {
        return err
    }

    kind := (^Manifest_Kind)(v.data)

    switch str {
    case "image":
        kind^ = .Image
    case "attestation":
        kind^ = .Attestation
    case:
        kind^ = .Unknown
    }

    json.advance_token(p)

    return nil
}

