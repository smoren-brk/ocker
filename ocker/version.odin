package ocker

Platform :: struct {
    Name: string,
}

Component_Details :: struct {
    ApiVersion:       string,
    Arch:             string,
    BuildTime:        string,
    Experimental:     string,
    GitCommit:        string,
    GoVersion:        string,
    KernelVersion:    string,
    MinAPIVersion:    string,
    Module:           string,
    ModuleVersion:    string,
    Os:               string,
}

Component :: struct {
    Name:    string,
    Version: string,
    Details: Component_Details,
}

Version_Info :: struct {
    Platform:      Platform,
    Version:       string,
    ApiVersion:    string,
    MinAPIVersion: string,
    Os:            string,
    Arch:          string,
    Components:    [dynamic]Component,
    GitCommit:     string,
    GoVersion:     string,
    KernelVersion: string,
    BuildTime:     string,
}

version :: proc() -> (Version_Info, Response_Error) {
    return http_get(Version_Info, "version")
}

