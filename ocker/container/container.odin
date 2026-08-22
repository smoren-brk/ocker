#+feature global-context
package container

import "core:encoding/json"
import "core:fmt"

import docker_api "../docker-api"
import "../image"

client: docker_api.Client

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
    ImageManifestDescriptor: image.OCI_Descriptor,
    Command: string,
    Created: u64,
    Labels: image.Labels,
    State: Container_State,
    Status: string,
}

@(init)
init :: proc() {
    json.register_user_unmarshaler(typeid_of(Container_State), container_state_unmarshaller)
}

list :: proc() -> ([dynamic]Container, docker_api.Error) {
    return docker_api.get(client, [dynamic]Container, "containers/json")
}

create :: proc(image: string, cmd: string) -> (Create_Response, docker_api.Error) {
    payload := fmt.aprintf(`{"Image":"%s","Cmd":%s}`, image, cmd)
    defer delete(payload)

    return docker_api.post(client, Create_Response, "containers/create", nil,  payload)
}

start :: proc(id: string) -> docker_api.Error {
    url := fmt.aprintf("containers/%s/start", id)
    defer delete(url)

    return docker_api.send(client, .POST, url)
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
