VERSION=0.1.0
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_HASH=$(shell git rev-parse HEAD)

BINARIES=bin/goon-$(VERSION).linux.amd64 \
		 bin/goon-$(VERSION).linux.386 \
		 bin/goon-$(VERSION).linux.arm64 \
		 bin/goon-$(VERSION).linux.mips64 \
		 bin/goon-$(VERSION).windows.amd64.exe \
		 bin/goon-$(VERSION).freebsd.amd64 \
		 bin/goon-$(VERSION).darwin.amd64


LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildDate=$(BUILD_DATE) -X main.GitHash=$(GIT_HASH)"


simple:
	go build -o goon main.go

release: $(BINARIES)

bin/goon-$(VERSION).linux.mips64: bin
	env GOOS=linux GOARCH=mips64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).linux.amd64: bin
	env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).linux.386: bin
	env GOOS=linux GOARCH=386 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).linux.arm64: bin
	env GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).windows.amd64.exe: bin
	env GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).darwin.amd64: bin
	env GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin/goon-$(VERSION).freebsd.amd64: bin
	env GOOS=freebsd GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o $@

bin:
	mkdir $@
