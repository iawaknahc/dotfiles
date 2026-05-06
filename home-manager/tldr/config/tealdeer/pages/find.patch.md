- Rename all .cpp files to .cxx recursively:

`find . -name '*.cpp' -exec sh -c 'mv "$1" "${1%.cpp}.cxx"' _ {} \;`
