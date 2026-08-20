package ocker

import docker_api "docker-api"

Platform :: struct {
    Name: string,
}

Details :: struct {
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
    Details: Details,
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

version :: proc() -> (Version_Info, docker_api.Error) {
    return docker_api.get(docker_api.Client{}, Version_Info, "version")
}

