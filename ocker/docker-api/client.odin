#+feature global-context
package docker_api

import "base:runtime"
import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:strings"
import curl "vendor:curl"

// HTTP verb
Method :: enum {
    GET,
    POST,
    DELETE,
}

Error :: enum {
    None,
    Curl_Init_Failed,
    Request_Failed,
    Http_Error,
    Json_Parse_Failed,
}

Client :: struct {
    host:  string,
    debug: bool,
}

DEFAULT_HOST :: "/var/run/docker.sock"

@(init)
init :: proc() {
    if curl.global_init(curl.GLOBAL_DEFAULT) != .E_OK {
        fmt.eprintln("docker-api: failed to initialize curl")
    }
    json.set_user_unmarshalers(new(map[typeid]json.User_Unmarshaler))
}

// curl is streaming the data in, so process it byte by byte.
write_callback :: proc "c" (
    ptr: rawptr,
    size: int,
    nmemb: int,
    userdata: rawptr,
) -> int {
    context = runtime.default_context()

    number_of_bytes := size * nmemb
    buffer := cast(^[dynamic]u8)userdata
    append(buffer, ..mem.slice_ptr(cast(^u8)ptr, number_of_bytes))

    return number_of_bytes
}

request :: proc(c: Client, method: Method, path: string, payload: string = "") -> ([]u8, Error) {
    host := c.host
    if host == "" {
        host = DEFAULT_HOST
    }

    request_url := strings.concatenate({"http://localhost/", path})
    defer delete(request_url)

    handle := curl.easy_init()
    if handle == nil {
        return nil, .Curl_Init_Failed
    }
    defer curl.easy_cleanup(handle)

    response := make([dynamic]u8)

    curl.easy_setopt(handle, .URL, request_url)
    curl.easy_setopt(handle, .UNIX_SOCKET_PATH, host)
    curl.easy_setopt(handle, .WRITEFUNCTION, write_callback)
    curl.easy_setopt(handle, .WRITEDATA, &response)

    headers: ^curl.slist
    defer curl.slist_free_all(headers)

    switch method {
        case .GET: {}
        case .POST:
            curl.easy_setopt(handle, .POST, i64(1))
            if payload != "" {
                // COPYPOSTFIELDS copies the data, so freeing right after setopt is safe.
                body := strings.clone_to_cstring(payload)
                curl.easy_setopt(handle, .COPYPOSTFIELDS, body)
                delete(body)

                headers = curl.slist_append(nil, "Content-Type: application/json")
                curl.easy_setopt(handle, .HTTPHEADER, headers)
            }
        case .DELETE:
            curl.easy_setopt(handle, .CUSTOMREQUEST, "DELETE")
    }

    if c.debug {
        fmt.printf("%v\t%s\t%s\n", method, request_url, payload)
    }

    if result := curl.easy_perform(handle); result != .E_OK {
        fmt.eprintf("docker-api: %s\n", curl.easy_strerror(result))
        return response[:], .Request_Failed
    }

    http_response_code: i64
    curl.easy_getinfo(handle, .RESPONSE_CODE, &http_response_code)

    if http_response_code < 200 || http_response_code >= 300 {
        fmt.eprintf("docker-api: HTTP %d: %s\n", http_response_code, string(response[:]))
        return response[:], .Http_Error
    }

    return response[:], .None
}

get :: proc(c: Client, $T: typeid, path: string) -> (T, Error) {
    raw, err := request(c, .GET, path)
    defer delete(raw)

    result: T
    if err != nil {
        return result, err
    }
    if err := json.unmarshal(raw, &result); err != nil {
        return result, .Json_Parse_Failed
    }
    return result, .None
}

post :: proc(c: Client, $T: typeid, path: string, payload: string = "") -> (T, Error) {
    raw, err := request(c, .POST, path, payload)
    defer delete(raw)

    result: T
    if err != nil {
        return result, err
    }
    if err := json.unmarshal(raw, &result); err != nil {
        return result, .Json_Parse_Failed
    }
    return result, .None
}

// send performs a request whose response body is not needed.
send :: proc(c: Client, method: Method, path: string, payload: string = "") -> Error {
    raw, err := request(c, method, path, payload)
    defer delete(raw)
    return err
}
