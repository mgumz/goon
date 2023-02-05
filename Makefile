VERSION=$(shell cat VERSION)
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_HASH=$(shell git rev-parse HEAD)

TARGETS=linux.amd64 linux.386 linux.arm64 linux.mips64 windows.amd64.exe darwin.amd64 darwin.arm64 freebsd.amd64
BINARIES=$(addprefix bin/goon-$(VERSION)., $(TARGETS))
RELEASES=$(subst windows.amd64.tar.gz,windows.amd64.zip,$(foreach r,$(subst .exe,,$(TARGETS)),releases/goon-$(VERSION).$(r).tar.gz))

LDFLAGS=-X main.version=$(VERSION) -X main.buildDate=$(BUILD_DATE) -X main.gitHash=$(GIT_HASH)

bin/goon: bin
	go build -o $@ .

binaries: $(BINARIES)
releases: $(RELEASES)
	make $(RELEASES)

bin/goon-$(VERSION).%:
	env GOARCH=$(subst .,,$(suffix $(subst .exe,,$@))) \
		GOOS=$(subst .,,$(suffix $(basename $(subst .exe,,$@)))) \
		CGO_ENABLED=0 \
		go build -ldflags "$(LDFLAGS)" -o $@ .

releases/goon-$(VERSION).%.zip: bin/goon-$(VERSION).%.exe
	mkdir -p releases
	zip -9 -j -r $@ README.md $<
releases/goon-$(VERSION).%.tar.gz: bin/goon-$(VERSION).%
	mkdir -p releases
	tar -cf $(basename $@) README.md && \
		tar -rf $(basename $@) --strip-components 1 $< && \
		gzip -9 $(basename $@)

deps-vendor:
	go mod vendor
deps-cleanup:
	go mod tidy

bin:
	mkdir $@

report: report-cyclo report-staticcheck report-mispell report-ineffassign report-vet report-golangci-lint
report-cyclo:
	@echo '####################################################################'
	gocyclo ./main.go
report-mispell:
	@echo '####################################################################'
	misspell .
report-lint:
	@echo '####################################################################'
	golint .
report-ineffassign:
	@echo '####################################################################'
	ineffassign .
report-vet:
	@echo '####################################################################'
	go vet .
report-staticcheck:
	@echo '####################################################################'
	staticcheck .
report-golangci-lint:
	@echo '####################################################################'
	golangci-lint run

fetch-report-tools:
	go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
	go install github.com/client9/misspell/cmd/misspell@latest
	go install github.com/gordonklaus/ineffassign@latest
	go install honnef.co/go/tools/cmd/staticcheck@latest
	go install golang.org/x/lint/golint@latest

.PHONY: bin/goon
