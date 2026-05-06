# yq

> Personal yq quick reference.

- Add a property in the front-matter of a note:

`yq --inplace --front-matter=process '.a = [] | sort' {{filename}}`

- Delete a property in the front-matter of a note:

`yq --inplace --front-matter=process 'del(.a) | sort' {{filename}}`

- Rename a property in the front-matter of a note:

`yq --inplace --front-matter=process '.b = .a | del(.a) | sort' {{filename}}`
