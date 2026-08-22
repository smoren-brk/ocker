package image

import "core:time"

Metadata :: struct {
    Last_Tag_Time: string `json:"LastTagTime"`
}

Root_FS :: struct {
    Layers: []string,
    Type: string,
}

Identity :: struct {
    Pull: []map[string]string
}

Config :: struct {
    Entrypoint: []string,
    Env: []string,
    Stop_Signal: string `json:"StopSignal"`,
    Working_Dir: string `json:"WorkingDir"`,
}

Annotations :: map[string]string

OCI_Descriptor :: struct {
    Digest: string,
    Media_Type: string `json:"mediaType"`,
    Size: i64,
    Annotations: Annotations,
    Platform: OCI_Platform
}

OCI_Platform :: struct {
    Architecture: string,
    Os:           string,
    OS_Version:  string   `json:"os.version,omitempty"`,
    OS_Features: []string `json:"os.features,omitempty"`,
    Variant: string,
}

Labels :: map[string]string

Listed_Image :: struct {
    Containers: u16,
    Created: i64,
    Descriptor: OCI_Descriptor,
    ID: string,
    Labels: Labels,
    Parent_ID: string `json:"ParentId"`,
    Repo_Digests: []string `json:"RepoDigests"`,
    Repo_Tags: []string `json:"RepoTags"`,
    Shared_Size: i64 `json:"SharedSize"`,
    Size: i64
}

Image :: struct {
    Architecture: string,
    Config: Config,
    Descriptor: OCI_Descriptor,
    ID: string,
    Identity: Identity,
    Metadata: Metadata,
    OS: string,
    Repo_Digests: []string `json:"RepoDigests"`,
    Repo_Tags: []string `json:"RepoTags"`,
    Root_FS: Root_FS `json:"RootFS"`,
    Size: i64,
}

Image_Manifest_Summary :: struct {
    ID:         string,
    Descriptor: OCI_Descriptor,
    Available:  bool,
    Size:       Manifest_Size,
    Kind:       Manifest_Kind,

    Image_Data:       Manifest_Image_Data `json:"ImageData,omitempty"`,
    Attestation_Data: Manifest_Attestation_Data `json:"AttestationData,omitempty"`
}

Manifest_Attestation_Data :: struct {
    For: string,
}

Manifest_Image_Data :: struct {
    Platform:   OCI_Platform,
    Identity:   Manifest_Identity,
    Containers: []string,
    Size:       Manifest_Image_Size,
}

Manifest_Identity :: struct {
    Signature: []Manifest_Signature,
    Pull:      []Manifest_Pull_Source,
    Build:     []Manifest_Build_Source,
}

Manifest_Signature :: struct {
    Name:             string,
    Timestamps:       []Manifest_Timestamp,
    Known_Signer:     string `json:"KnownSigner"`,
    Docker_Reference: string `json:"DockerReference"`,

    Signer: Manifest_Signer,

    Signature_Type: string   `json:"SignatureType"`,
    Error:          string,
    Warnings:       []string,
}

Manifest_Timestamp :: struct {
    Type:      string,
    URI:       string,
    Timestamp: time.Time,
}

Manifest_Signer :: struct {
    Certificate_Issuer: string `json:"CertificateIssuer"`,
    Subject_Alternative_Name: string `json:"SubjectAlternativeName"`,
    Issuer:                   string,

    Build_Signer_URI:    string `json:"BuildSignerURI"`,
    Build_Signer_Digest: string `json:"BuildSignerDigest"`,

    Runner_Environment: string `json:"RunnerEnvironment"`,

    Source_Repository_URI:        string `json:"SourceRepositoryURI"`,
    Source_Repository_Digest:     string `json:"SourceRepositoryDigest"`,
    Source_Repository_Ref:        string `json:"SourceRepositoryRef"`,
    Source_Repository_Identifier: string `json:"SourceRepositoryIdentifier"`,
    Source_Repository_Owner_URI: string `json:"SourceRepositoryOwnerURI"`,
    Source_Repository_Owner_Identifier: string `json:"SourceRepositoryOwnerIdentifier"`,

    Build_Config_URI:    string `json:"BuildConfigURI"`,
    Build_Config_Digest: string `json:"BuildConfigDigest"`,
    Build_Trigger:      string `json:"BuildTrigger"`,

    Run_Invocation_URI: string `json:"RunInvocationURI"`,
    Source_Repository_Visibility_At_Signing: string `json:"SourceRepositoryVisibilityAtSigning"`,
}

Manifest_Pull_Source :: struct {
    Repository: string,
}

Manifest_Build_Source :: struct {
    Ref:        string,
    Created_At: time.Time `json:"CreatedAt"`,
}

Manifest_Size :: struct {
    Total:   i64,
    Content: i64,
}

Manifest_Image_Size :: struct {
    Unpacked: i64,
}

Manifest_Kind :: enum {
    Image,
    Attestation,
    Unknown,
}

Driver_Data :: struct {
    Name: string,
    Data: map[string]string,
}

Inspection :: struct {
    Id: string,
    Descriptor: OCI_Descriptor,
    Manifests: Image_Manifest_Summary,
    Identity: Identity,
    Repo_Digests: []string `json:"RepoDigests"`,
    Repo_Tags: []string `json:"RepoTags"`,
    Root_FS: Root_FS `json:"RootFS"`,
    Comment: Maybe(string),
    Created: Maybe(i64),
    Author: Maybe(string),
    Config: Config,
    Architecture: string,
    Variant: Maybe(string),
    Os: string,
    Os_Version: Maybe(string) `json:"OsVerison"`,
    Size: i64,
    Graph_Driver: Driver_Data `json:"GraphDriver"`,
    Metadata: Metadata
}

