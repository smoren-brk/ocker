package util

import "core:encoding/json"

enroll_unmarshaller :: proc($T: typeid, unmarshaller: proc(^json.Parser, any) -> json.Unmarshal_Error) {
    json.set_user_unmarshalers(
        new(map[typeid]json.User_Unmarshaler),
    )

    err := json.register_user_unmarshaler(
        typeid_of(T),
        unmarshaller,
    )
    assert(err == .None)
}

