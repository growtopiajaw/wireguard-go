#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if ! command -v git &> /dev/null
then
    DEV_VER="development"
else
    DEV_VER="dev-$(git rev-parse --short HEAD)"
fi

VERSION=${VERSION:=$DEV_VER}

build() {
    EXT=""
    [[ $GOOS = "windows" ]] && EXT=".exe"
    echo "Building ${GOOS} ${GOARCH}v${GOARM}"
    CGO_ENABLED=0 go build \
        -trimpath \
        -ldflags="-s -w -X 'github.com/WireGuard/wireguard-go/cmd.Version=$VERSION'" \
        -o ./bin/rospo-${GOOS}-${GOARCH}v${GOARM}${EXT} .
}

### test units
go clean -testcache
go test ./... -v -cover -race || exit 1


### multi arch binary build
GOOS=linux GOARCH=arm GOARM=5 build
GOOS=linux GOARCH=arm GOARM=6 build
GOOS=linux GOARCH=arm GOARM=7 build
