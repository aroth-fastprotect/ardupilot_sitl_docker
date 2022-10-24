#!/bin/bash -x
script_file=`readlink -f "$0"`
script_dir=`dirname "$script_file"`
script_docker_image_name=`basename "$script_dir"`
tag='dev'
got_tag=0
no_cache=0
docker_build_opts=''

function usage() {
    set +x
	echo "Usage: $script_file [OPTIONS] [TAG]"
	echo "OPTIONS:"
	echo "    -h, --help            shows this help"
	echo "    -v, --verbose         enable verbose output"
	echo "    -L, --latest          build latest instead of development"
	echo "    --tag <TAG>           override tag name"
	echo "    --no-cache            disable cache for docker build"
	echo ""
	echo "  TAG        name of the docker image tag (default $tag)"
	echo ""
	echo "Builds the docker image: $script_docker_image_name, tag $tag"
	exit 0
}

# parse command line arguments
while [ $# -ne 0 ]; do
	case "$1" in
	'-?'|'-h'|'--help') usage;;
	'-v'|'--verbose') verbose=1; ;;
	'-L'|'--latest') lsb_rel='latest'; ;;
	'--tag') lsb_rel="$2"; shift; ;;
	'--no-cache') no_cache=1; ;;
	-*)
		echo "Unrecognized option $1" >&2
		exit 1
		;;
	*)
        if [ $got_tag -eq 0 ]; then
            tag="$1"
            got_tag=1
        else
			echo "Docker image tag $tag already specified." >&2
			exit 1
		fi
		;;
	esac
	shift
done

if [ $no_cache -ne 0 ]; then
    docker_build_opts="$docker_build_opts --no-cache"
fi

echo "Builds the docker image: $script_docker_image_name, tag $tag"

docker_user='rothan'
full_image_name="${script_docker_image_name}:${tag}"
docker build --pull $docker_build_opts --tag "$full_image_name" "$script_dir"
docker tag "$full_image_name" "$docker_user/$full_image_name"
#docker push "$docker_user/$full_image_name"
