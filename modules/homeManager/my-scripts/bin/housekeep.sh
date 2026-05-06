#!/bin/sh

# Housekeep well-known generated ignored directories.
find "$HOME" -maxdepth 2 -type d -name .git -exec sh -c 'dirname $1' _ {} \; 2>/dev/null | while read -r gitrepo; do
	(
		cd "$gitrepo"
		git status --ignored --porcelain | awk '$1 ~ /^!!$/ { print $2 }' | while read -r ignored; do
			is_target=0

			case "$(basename "$ignored")" in
				.dart_tool)
					is_target=1
					;;
				DerivedData)
					is_target=1
					;;
				Pods)
					is_target=1
					;;
				bin)
					is_target=1
					;;
				obj)
					is_target=1
					;;
				dist)
					is_target=1
					;;
				build)
					is_target=1
					;;
				node_modules)
					is_target=1
					;;
				vendor)
					is_target=1
					;;
			esac

			if [ "$is_target" = 1 ]; then
				(set -eux; rm -r "${gitrepo:?}/${ignored}")
			fi
		done
	)
done

# Housekeep Go modules
if command -v go 1>/dev/null; then
	(set -eux; go clean -cache -testcache -modcache -fuzzcache)
fi

# Housekeep Docker
if command -v docker 1>/dev/null; then
	(set -eux; docker system prune --force)
fi

# Housekeep gradle
if [ -d ~/.gradle/caches ]; then
	(set -eux; rm -r ~/.gradle/caches)
fi
