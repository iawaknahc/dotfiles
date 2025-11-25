# pax

> Personal quick reference on pax

- List the contents of a .tar archive:

`pax -v -f {{archive.tar}}`

- Extract a .tar archive into current directory:

`pax -r -v -f {{archive.tar}}`

- Create a .tar archive:

`COPYFILE_DISABLE=1 pax -w -v -f {{archive.tar}} {{dir1 dir2 dir3 ...}}`

- Copy file hierarchy:

`pax -rw -v {{the/hierarchy/is/preserved/}} {{path/to/existing_directory}}`

- Rename Java packages:

`pax -rw -v ./{{com/thiscompany}} -s ',{{com/thiscompany}},{{org/thatorganization}},p' ./`
