package http

import "base:runtime"
import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:strings"
import curl "vendor:curl"

Request_type :: enum {
    None,
    GET,
    POST,
}

// curl is streaming the goddamn data so
// we need to process it byte by byte
write_callback :: proc "c" (
    ptr: rawptr,
    size: int,
    nmemb: int,
    userdata: rawptr,
) -> int {
    context = runtime.default_context()
    number_of_bytes := size * nmemb

    buffer := cast(^[dynamic]u8)userdata
    chunk := mem.slice_ptr(cast(^u8)ptr, number_of_bytes)

    append(buffer, ..chunk)

    return number_of_bytes
}

client_init :: proc() {
    // init curl
    if curl.global_init(curl.GLOBAL_DEFAULT) != .E_OK {
        fmt.println("Error while initializing curl")
        return
    }
}

request :: proc(url_command: string, request_type: Request_type, payload: string = "{}") -> ([dynamic]u8, Curl_Error) {
    client_init()
    defer curl.global_cleanup()

    DOCKER_SOCKET :: "/var/run/docker.sock"

    request_url := strings.concatenate({"http://localhost/", url_command})
    // TODO: check if string builder can be used here
    response := make([dynamic]u8)

    // init easy - single basic request
    mono_request := curl.easy_init()
    if mono_request == nil {
        fmt.println("Error while initializing curl")
        return response, .Curl_Init_Failed
    }
    defer curl.easy_cleanup(mono_request)

    // set parameters for api call
    curl.easy_setopt(mono_request, .URL, request_url)
    curl.easy_setopt(mono_request, .UNIX_SOCKET_PATH, DOCKER_SOCKET)
    curl.easy_setopt(mono_request, .WRITEFUNCTION, write_callback)
    curl.easy_setopt(mono_request, .WRITEDATA, &response)

    headers: ^curl.slist
    defer curl.slist_free_all(headers)

    switch request_type {
        case .None: {}
        case .GET: {}
        case .POST: {
            curl.easy_setopt(mono_request, .POST, i64(1))
            curl.easy_setopt(mono_request, .COPYPOSTFIELDS, strings.clone_to_cstring(payload))
            headers = curl.slist_append(nil, "Content-Type: application/json")
            curl.easy_setopt(mono_request, .HTTPHEADER, headers)
        }
    }

    fmt.printf("%s\t%s\n\t%s\n", request_type, request_url, payload)

    http_response_code: i64
    response_code := curl.easy_perform(mono_request)
    curl.easy_getinfo(mono_request, .RESPONSE_CODE, &http_response_code)

    if http_response_code < 200 || http_response_code >= 300 {
        fmt.printf("Docker HTTP %d: %s\n", http_response_code, string(response[:]))
        return response, .Request_Failed
    }

    if response_code != .E_OK {
        fmt.println(curl.easy_strerror(response_code))
        return response, .Request_Failed
    }

    return response, .None
}

get :: proc($T: typeid, url: string) -> (T, Response_Error) {
    typ: T

    response, curl_err := request(url, Request_type.GET)
    defer delete(response)
    if curl_err != nil {
        fmt.println("Invalid response")
        return typ, .Invalid_Response
    }

    json_err := json.unmarshal(response[:], &typ)
    if json_err != nil {
        fmt.println("Failed to unmarshal version response")
        fmt.println(json_err)
        return typ, .Json_Parse_Failed
    }

    return typ, .None
}

just_post :: proc(url: string, payload: string = "") -> Response_Error {
    response, curl_err := request(url, Request_type.POST, payload)
    defer delete(response)
    if curl_err != nil {
        fmt.println("Invalid response")
        return .Invalid_Response
    }

    return .None
}

post :: proc($T: typeid, url: string, payload: string = "") -> (T, Response_Error) {
    typ: T

    response, curl_err := request(url, Request_type.POST, payload)
    defer delete(response)
    if curl_err != nil {
        fmt.println("Invalid response")
        return typ, .Invalid_Response
    }

    json_err := json.unmarshal(response[:], &typ)
    if json_err != nil {
        fmt.println("Failed to unmarshal version response")
        fmt.println(json_err)
        return typ, .Json_Parse_Failed
    }

    return typ, .None
}

