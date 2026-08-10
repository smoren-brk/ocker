package ocker

import "core:fmt"

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

Image_Descriptor :: struct {
    digest: string,
    mediaType: string,
    size: u64
}

Listed_Image :: struct {
    Containers: u16,
    Created: u64,
    Descriptor: Image_Descriptor,
    Id: string,
    Labels: map[string]string,
    ParentId: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    SharedSize: i64,
    Size: u64
}

Image_List :: [dynamic]Listed_Image

Image :: struct {
    Architecture: string,
    Config: Image_Config,
    Descriptor: Image_Descriptor,
    Id: string,
    Identity: Image_Identity,
    Metadata: Image_Metadata,
    OS: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    RootFS: Image_RootFS,
    Size: u64,
}

list_images :: proc() -> (Image_List, Response_Error) {
    return http_get(Image_List, "images/json")
}

parse_image :: proc(image_id: string) -> (Image, Response_Error) {
    url := fmt.aprintf("images/%s/json", image_id)
    return http_get(Image, url)
}
