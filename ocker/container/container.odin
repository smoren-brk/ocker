package container

import "core:encoding/json"
import "../http"
import "../image"

state_unmarshal :: proc(p: ^json.Parser, v: any) -> json.Unmarshal_Error {
    str, err := json.unquote_string(
        p.curr_token,
        p.spec,
        p.allocator,
    )
    if err != .None {
        return err
    }

    state := (^State)(v.data)

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

State :: enum {
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
    State: State,
    Status: string,
}

list :: proc() -> ([dynamic]Container, http.Response_Error) {
    json.set_user_unmarshalers(
        new(map[typeid]json.User_Unmarshaler),
    )

    err := json.register_user_unmarshaler(
        typeid_of(State),
        state_unmarshal,
    )
    assert(err == .None)

    return http.get([dynamic]Container, "containers/json")
}

