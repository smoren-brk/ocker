package image

Metadata :: struct {
    LastTagTime: string
}

RootFS :: struct {
    Layers: [dynamic]string,
    Type: string,
}

Identity :: struct {
    Pull: [dynamic]map[string]string
}

Config :: struct {
    Entrypoint: [dynamic]string,
    Env: [dynamic]string,
    StopSignal: string,
    WorkingDir: string,
}

Annotations :: map[string]string

Platform :: struct {
    architecture: string,
    os: string
}

OCIDescriptor :: struct {
    digest: string,
    mediaType: string,
    size: i64,
    annotations: Annotations,
    platform: Platform
}

Labels :: map[string]string

Listed_Image :: struct {
    Containers: u16,
    Created: i64,
    Descriptor: OCIDescriptor,
    Id: string,
    Labels: Labels,
    ParentId: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    SharedSize: i64,
    Size: i64
}

Image :: struct {
    Architecture: string,
    Config: Config,
    Descriptor: OCIDescriptor,
    Id: string,
    Identity: Identity,
    Metadata: Metadata,
    OS: string,
    RepoDigests: [dynamic]string,
    RepoTags: [dynamic]string,
    RootFS: RootFS,
    Size: i64,
}

ImageManifestSummary :: struct {}
DriverData :: struct {}

Inspection :: struct {
    Id: string,
    Descriptor: OCIDescriptor,
    Manifests: ImageManifestSummary,
    Identity: Identity,
    RepoTags: [dynamic]string,
    RepoDigests: [dynamic]string,
    Comment: Maybe(string),
    Created: Maybe(i64),
    Author: Maybe(string),
    Config: Config,
    Architecture: string,
    Variant: Maybe(string),
    Os: string,
    OsVersion: Maybe(string),
    Size: i64,
    GraphDriver: DriverData,
    RootFS: RootFS,
    Metadata: Metadata
}

