package odock

Curl_Error :: enum {
    None,
    Curl_Init_Failed,
    Request_Failed,
    Invalid_Response,
    Json_Parse_Failed
}

Response_Error :: enum {
    None,
    Json_Parse_Failed,
    Invalid_Response
}

