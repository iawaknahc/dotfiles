# sh

> Personal shell scripting quick reference.

- Test string equality:

`[ a = b ]`

- Test string inequality:

`[ a != b ]`

- Test string lexicographically less than:

`[ a < b ]`

- Test string lexicographically greater than:

`[ a > b ]`

- Test integer equality:

`[ 0 -eq 1 ]`

- Test integer inequality:

`[ 0 -ne 1 ]`

- Test integer greater than:

`[ 0 -gt 1 ]`

- Test integer greater than or equal to:

`[ 0 -ge 1 ]`

- Test integer less than:

`[ 0 -lt 1 ]`

- Test integer less than or equal to:

`[ 0 -le 1 ]`

- Test logical negation:

`[ ! a ]`

- Test logical and:

`[ a -a b ]`

- Test logical or:

`[ a -o b ]`

- Check if sub is a substring of full:

`printf {{superstring}} | grep >/dev/null -F {{sub}}`

- Count the number of non-overlapping substrings:

`printf {{superstring}} | grep -F -o {{sub}} | wc -l`

- Check if string has a specific prefix:

`case {{string}} in {{str}}*) true ;; *) false ;; esac`

- Check if string has a specific suffix:

`case {{string}} in *{{ing}}) true ;; *) false ;; esac`

- Repeat a string n times:

`awk -v s={{string}} -v n={{10}} 'BEGIN{for(i=0;i<n;++i)printf("%s",s)}'`

- Loop through a range with start, end, and step:

`awk -v start={{0}} -v end={{10}} -v step={{2}} 'BEGIN{for(i=start;i<=end;i+=step)print(i)}' | while IFS= read -r i; do echo "$i"; done`

- Loop through literal items:

`for i in {{item1 item2 item3 ...}}; do echo "$i"; done`

- Trim leading spaces:

`printf {{string}} | sed 's/^[[:space:]]*//g'`

- Trim trailing spaces:

`printf {{string}} | sed 's/[[:space:]]*$//g'`

- Trim leading and trailing spaces:

`printf {{string}} | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g'`

- Remove prefix from string:

`${ {{VARIABLE}} #{{prefix}} }`

- Remove suffix from string:

`${ {{VARIABLE}} %{{suffix}} }`

- Perform arithmetic operation:

`$(( 1 + 2 ))`

- Print and run a command (creates a subshell with debug mode):

`(set -x && echo hello)`
