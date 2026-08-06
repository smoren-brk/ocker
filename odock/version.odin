package odock

import "core:fmt"
import "core:encoding/json"

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
    version_info: Version_Info

    response, curl_err := request("version")
    defer delete(response)
    if curl_err != nil {
        fmt.println("Invalid response")
        return version_info, .Invalid_Response
    }

    json_err := json.unmarshal(response[:], &version_info)
    if json_err != nil {
        fmt.println("Failed to unmarshal version response")
        fmt.println(json_err)
        return version_info, .Json_Parse_Failed
    }

    return version_info, .None
}

