function pe --description "percent encoding"
  set name "$(status function)"

  argparse \
    --exclusive h,e \
    --exclusive h,d \
    --exclusive e,d \
    --exclusive u,p \
    --exclusive u,q \
    --exclusive u,f \
    --exclusive p,q \
    --exclusive p,f \
    --exclusive q,f \
    h/help \
    e/encode \
    d/decode \
    u/unspecified \
    p/path \
    q/query \
    f/fragment \
    -- $argv
  set argparse_status "$status"
  if test "$argparse_status" -ne 0
    return 1
  end

  if test -n "$_flag_h" -o -n "$_flag_help"
    printf 1>&2 "\
Usage: $name [ -e | -d ] [ -u | -p | -q | -f ] input...
  -h, --help         Show this help.
  -e, --encode       (Defualt) Encode.
  -d, --decode       Decode.
  -u, --unspecified  (Default) Encode non-unreserved characters
                     https://datatracker.ietf.org/doc/html/rfc3986#section-2.3
  -p, --path         Encode path component
                     https://datatracker.ietf.org/doc/html/rfc3986#section-3.3
  -q, --query        Encode x-www-form-urlencoded
                     https://url.spec.whatwg.org/#application/x-www-form-urlencoded
  -f, --fragment     Encode fragment
                     https://datatracker.ietf.org/doc/html/rfc3986#section-3.5
"
    return 0
  end

  set operation "encode"
  if test -n "$_flag_d" -o -n "$_flag_decode"
    set operation "decode"
  end

  set position "unspecified"
  if test -n "$_flag_p" -o -n "$_flag_path"
    set position "path"
  end
  if test -n "$_flag_q" -o -n "$_flag_query"
    set position "query"
  end
  if test -n "$_flag_f" -o -n "$_flag_fragment"
    set position "fragment"
  end

  set program "\
import sys
from urllib.parse import quote, unquote, quote_plus, unquote_plus

operation = '$operation'
position = '$position'

safe = ''
if position == 'path':
  # RFC3986 3.3
  # pchar         = unreserved / pct-encoded / sub-delims / ':' / '@'
  safe = '!\$&\'()*+,;=' + ':@'
elif position == 'query':
  # RFC3986 3.4
  # query       = *( pchar / '/' / '?' )
  # https://url.spec.whatwg.org/#urlencoded-parsing
  # & and = is not safe
  safe = '!\$\'()*+,;' + ':@' + '/?'
elif position == 'fragment':
  # RFC3986 3.5
  # fragment    = *( pchar / '/' / '?' )
  safe = '!\$&\'()*+,;=' + ':@' + '/?'

for arg in sys.argv[1:]:
  if operation == 'encode' and position == 'query':
    print(quote_plus(arg, safe=safe))
  elif operation == 'decode' and position == 'query':
    print(unquote_plus(arg))
  elif operation == 'encode':
    print(quote(arg, safe=safe))
  elif operation == 'decode':
    print(unquote(arg))
  else:
    raise Exception('unreachable')
"

  python3 -c "$program" $argv
end
