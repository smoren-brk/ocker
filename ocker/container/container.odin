package container

import "core:encoding/json"
import "core:fmt"

import "../http"
import "../image"
import "../util"

Create_Response :: struct {
    Id: string,
    Warnings: [dynamic]string,
}

Container_State :: enum {
    Unknown,
    Created,
    Running,
    Paused,
    Restarting,
    Exited,
    Removing,
    Dead
}

Container :: struct {
    Id: string,
    Names: [dynamic]string,
    Image: string,
    ImageID: string,
    ImageManifestDescriptor: image.OCIDescriptor,
    Command: string,
    Created: u64,
    Labels: image.Image_Labels,
    State: Container_State,
    Status: string,
}

list :: proc() -> ([dynamic]Container, http.Response_Error) {
    util.enroll_unmarshaller(Container_State, container_state_unmarshaller)
    return http.get([dynamic]Container, "containers/json")
}

// TODO: change cmd to list of strings
create :: proc(image: string, cmd: string) -> Create_Response {
    url := "containers/create"
    cmd := fmt.aprintf(`{{"Image":"%s","Cmd":%s}}`, image, cmd)

    response, err := http.post(Create_Response, url, cmd)
    if err != nil {
        panic("Cannot create container")
    }

    return response
}

start :: proc(image_id: string) {
    url := fmt.aprintf("containers/%s/start", image_id)
    err := http.just_post(url)
    if err != nil {
        panic("Cannot start the container")
    }
}

container_state_unmarshaller :: proc(p: ^json.Parser, v: any) -> json.Unmarshal_Error {
    str, err := json.unquote_string(
        p.curr_token,
        p.spec,
        p.allocator,
    )
    if err != .None {
        return err
    }

    state := (^Container_State)(v.data)

    switch str {
    case "created":
        state^ = .Created
    case "running":
        state^ = .Running
    case "paused":
        state^ = .Paused
    case "restarting":
        state^ = .Restarting
    case "exited":
        state^ = .Exited
    case "removing":
        state^ = .Removing
    case "dead":
        state^ = .Dead
    case:
        state^ = .Unknown
    }

    json.advance_token(p)

    return nil
}
