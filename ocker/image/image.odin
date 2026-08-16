package image

import "core:fmt"
import "../http"

Image_Metadata :: struct {
    LastTagTime: string
}

Image_RootFS :: struct {
    Layers: [dynamic]string,
    Type: string,
}

Image_Identity :: struct {
    Pull: [dynamic]map[string]string
}

Image_Config :: struct {
    Entrypoint: [dynamic]string,
    Env: [dynamic]string,
    StopSignal: string,
    WorkingDir: string,
}

Image_Annotations :: map[string]string

Image_Platform :: struct {
    architecture: string,
    os: string
}

OCIDescriptor :: struct {
    digest: string,
    mediaType: string,
    size: u64,
    annotations: Image_Annotations,
    platform: Image_Platform
}

Image_Labels :: map[string]string

Listed_Image :: struct {
    Containers: u16,
    Created: u64,
    Descriptor: OCIDescriptor,
    Id: string,
    Labels: Image_Labels,
    ParentId: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    SharedSize: i64,
    Size: u64
}

Image :: struct {
    Architecture: string,
    Config: Image_Config,
    Descriptor: OCIDescriptor,
    Id: string,
    Identity: Image_Identity,
    Metadata: Image_Metadata,
    OS: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    RootFS: Image_RootFS,
    Size: u64,
}

list_images :: proc() -> ([dynamic]Listed_Image, http.Response_Error) {
    return http.get([dynamic]Listed_Image, "images/json")
}

parse_image :: proc(image_id: string) -> (Image, http.Response_Error) {
    url := fmt.aprintf("images/%s/json", image_id)
    return http.get(Image, url)
}

image_history :: proc(image_id: string) -> ([dynamic]Image, http.Response_Error) {
    url := fmt.aprintf("images/%s/history", image_id)
    return http.get([dynamic]Image, url)
}

pull :: proc(image: string, tag: string) -> (Image, http.Response_Error) {
    url := fmt.aprintf("images/create?fromImage=%s&tag=%s", image, tag)
    return http.post(Image, url)
}
