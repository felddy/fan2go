.DEFAULT_GOAL := build
.PHONY: help test build build-ppc64le build-s390x build-riscv64 deploy run clean

GO_FLAGS   ?=
NAME       := fan2go
OUTPUT_BIN ?= bin/${NAME}
PACKAGE    := github.com/markusressel/$(NAME)
GIT_REV    ?= $(shell git rev-parse --short HEAD)
SOURCE_DATE_EPOCH ?= $(shell date +%s)
DATE       ?= $(shell date -u -d @${SOURCE_DATE_EPOCH} +"%Y-%m-%dT%H:%M:%SZ")
VERSION    ?= 0.13.0

test:   ## Run all tests
	@go clean --testcache && go test -tags disable_nvml -v ./...

build:  ## Builds the CLI
	@go build ${GO_FLAGS} \
	-ldflags "-w -s \
	-extldflags=-Wl,-z,lazy \
	-X ${NAME}/cmd/global.Version=${VERSION} \
	-X ${PACKAGE}/cmd/global.Version=${VERSION} \
	-X ${NAME}/cmd/global.Commit=${GIT_REV} \
	-X ${PACKAGE}/cmd/global.Commit=${GIT_REV} \
	-X ${NAME}/cmd/global.Date=${DATE} \
	-X ${PACKAGE}/cmd/global.Date=${DATE}" \
	-a -tags netgo -o "${OUTPUT_BIN}" main.go

build-no-nvml: ## Builds the CLI without nvml (nvidia GPU) support
	@go build ${GO_FLAGS} \
	-ldflags "-w -s \
	-X ${NAME}/cmd/global.Version=${VERSION} \
	-X ${PACKAGE}/cmd/global.Version=${VERSION} \
	-X ${NAME}/cmd/global.Commit=${GIT_REV} \
	-X ${PACKAGE}/cmd/global.Commit=${GIT_REV} \
	-X ${NAME}/cmd/global.Date=${DATE} \
	-X ${PACKAGE}/cmd/global.Date=${DATE}" \
	-a -tags netgo,disable_nvml -o "${OUTPUT_BIN}" main.go

build-ppc64le: ## Builds for linux/ppc64le with CGO cross-compilation (requires crossbuild-essential-ppc64el and libsensors-dev:ppc64el)
	CGO_ENABLED=1 CC=powerpc64le-linux-gnu-gcc GOOS=linux GOARCH=ppc64le \
	go build ${GO_FLAGS} \
	-ldflags "-w -s \
	-X ${NAME}/cmd/global.Version=${VERSION} \
	-X ${PACKAGE}/cmd/global.Version=${VERSION} \
	-X ${NAME}/cmd/global.Commit=${GIT_REV} \
	-X ${PACKAGE}/cmd/global.Commit=${GIT_REV} \
	-X ${NAME}/cmd/global.Date=${DATE} \
	-X ${PACKAGE}/cmd/global.Date=${DATE}" \
	-a -tags netgo -o "dist/fan2go-linux-ppc64le" main.go

build-s390x: ## Builds for linux/s390x with CGO cross-compilation (requires crossbuild-essential-s390x and libsensors-dev:s390x)
	CGO_ENABLED=1 CC=s390x-linux-gnu-gcc GOOS=linux GOARCH=s390x \
	go build ${GO_FLAGS} \
	-ldflags "-w -s \
	-X ${NAME}/cmd/global.Version=${VERSION} \
	-X ${PACKAGE}/cmd/global.Version=${VERSION} \
	-X ${NAME}/cmd/global.Commit=${GIT_REV} \
	-X ${PACKAGE}/cmd/global.Commit=${GIT_REV} \
	-X ${NAME}/cmd/global.Date=${DATE} \
	-X ${PACKAGE}/cmd/global.Date=${DATE}" \
	-a -tags netgo -o "dist/fan2go-linux-s390x" main.go

build-riscv64: ## Builds for linux/riscv64 with CGO cross-compilation (requires crossbuild-essential-riscv64 and libsensors-dev:riscv64)
	CGO_ENABLED=1 CC=riscv64-linux-gnu-gcc GOOS=linux GOARCH=riscv64 \
	go build ${GO_FLAGS} \
	-ldflags "-w -s \
	-X ${NAME}/cmd/global.Version=${VERSION} \
	-X ${PACKAGE}/cmd/global.Version=${VERSION} \
	-X ${NAME}/cmd/global.Commit=${GIT_REV} \
	-X ${PACKAGE}/cmd/global.Commit=${GIT_REV} \
	-X ${NAME}/cmd/global.Date=${DATE} \
	-X ${PACKAGE}/cmd/global.Date=${DATE}" \
	-a -tags netgo -o "dist/fan2go-linux-riscv64" main.go

run: build
	./${OUTPUT_BIN}

deploy: build
	sudo cp "${OUTPUT_BIN}" "/usr/bin/${NAME}"

clean:
	go clean
	rm -f "${OUTPUT_BIN}"
