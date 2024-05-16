#!/bin/bash
# Build script
#set -eo pipefail
#build_tag=$1
#name=knowledge-mw-service
#node=$2
#org=$3

#[[ -f ImageMagick-i386-pc-solaris2.11.tar.gz ]] || wget https://www.imagemagick.org/download/binaries/ImageMagick-i386-pc-solaris2.11.tar.gz
#docker build -f ./Dockerfile --label commitHash=$(git rev-parse --short HEAD) -t ${org}/${name}:${build_tag} .
#echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
#####################################################################
#!/bin/bash
# Build script
set -eo pipefail
build_tag=$1
name=knowledge-mw-service
node=$2
org=$3
url="https://www.imagemagick.org/download/binaries/ImageMagick-i386-pc-solaris2.11.tar.gz"
file="ImageMagick-i386-pc-solaris2.11.tar.gz"
max_retries=5
retry_delay=10

download_file() {
    local retries=0
    while [[ $retries -lt $max_retries ]]; do
        if wget $url; then
            return 0
        else
            echo "Download failed, retrying in $retry_delay seconds..."
            sleep $retry_delay
            retries=$((retries + 1))
        fi
    done
    return 1
}

if [[ ! -f $file ]]; then
    echo "Downloading $file..."
    if ! download_file; then
        echo "Failed to download $file after $max_retries attempts."
        exit 1
    fi
fi

docker build -f ./Dockerfile --label commitHash=$(git rev-parse --short HEAD) -t ${org}/${name}:${build_tag} .
echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
