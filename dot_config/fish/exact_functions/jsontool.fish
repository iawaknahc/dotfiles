function jsontool --description "shortcut to python3 -m json.tool with some defaults"
  argparse \
    sort \
    compact \
    -- $argv

  set argparse_status "$status"
  if test "$argparse_status" -ne 0
    return 1
  end

  set options "--no-ensure-ascii"

  if test -n "$_flag_sort"
    set --append options "--sort-keys"
  end

  if test -n "$_flag_compact"
    set --append options "--compact"
  else
    set --append options "--indent=2"
  end

  python3 -m json.tool $options $argv
end
