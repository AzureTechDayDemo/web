#!/bin/bash

while getopts ':v:r:' arg; do
    case ${arg} in
        v)
            _image_version=$OPTARG
            ;;
        r) 
            _registry_name=$OPTARG
            ;;
        \? )
            echo "Usage: cmd [-h] [-t]"
            echo Pulls the latest dotnet/aspnetcore images 
            echo Pushes to the -r specified registry
            echo Parameters
            echo "   -v version to pull"
            echo "   -r ACR Private registry [OPTIONAL - uses REGISTRY_NAME if not specified]"

            exit

            ;;
    esac
done
if [ -z $_registry_name ]
then
    _registry_name=$REGISTRY_NAME

    if [ -z $_registry_name ]
    then
        echo ERROR: -r required 
        exit
    fi
fi
echo "IMAGE:    "$_image_version
echo "REGISTRY: "$_registry_name

echo Pull/Tag/Push dotnet SDK:${_image_version}
docker pull microsoft/dotnet-nightly:${_image_version}-sdk
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_new_image=${_registry_name}baseimages/microsoft/dotnet-sdk:linux-${_image_version}

docker build \
  -f Dockerfile-sdk \
  -t $_new_image \
  --build-arg IMAGE_VERSION=${_image_version} \
  --build-arg IMAGE_BUILD_DATE=`date +%Y%m%d-%H%M%S` \
  .
docker push $_new_image

echo Pull/Tag/Push aspnetcore RUNTIME:${_image_version}


docker pull microsoft/dotnet-nightly:${_image_version}-aspnetcore-runtime

_new_image=${_registry_name}baseimages/microsoft/aspnetcore-runtime:linux-${_image_version}

docker build \
  -f Dockerfile-runtime \
  -t $_new_image \
  --build-arg IMAGE_VERSION=${_image_version} \
  --build-arg IMAGE_BUILD_DATE=`date +%Y%m%d-%H%M%S` \
  .

docker push $_new_image