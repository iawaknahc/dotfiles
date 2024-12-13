#!/bin/sh

# This command finds all CA certificates in the keychains.
# For each CA certificates, check if it is trusted.
# All trusted CA certificates are then saved in a cert.pem file.
# Finally, this command output a shell snippet to set SSL_CERT_FILE.
# SSL_CERT_FILE is environment variable of openssl to set -CAfile
# See https://docs.openssl.org/3.3/man7/openssl-env/#description
#
# This is useful when you are invoking a command that uses openssl, e.g. curl.
# It can be used to make curl to use the trusted CA certificates in Keychain Access.app.
#
# A typical usage of this command is
#   macos-ca-certs | source

outdir="$(mktemp -d -t macos-ca-certs)"
# Follow the convention to use `cert.pem` as the name.
# See https://docs.openssl.org/3.3/man3/SSL_CTX_load_verify_locations/#description
outpath="$outdir/cert.pem"

workdir="$(mktemp -d -t macos-ca-certs)"
cd "$workdir"

# Run /usr/bin/security find-certificate -h to see what the options do.
/usr/bin/security find-certificate \
  -a \
  -p \
  /System/Library/Keychains/SystemRootCertificates.keychain \
  /Library/Keychains/System.keychain \
| 2>/dev/null csplit \
  -f prefix- \
  -n 4 \
  -k \
  -s \
  - \
  '/-----BEGIN CERTIFICATE-----/' '{9999}'

for f in prefix-*; do
  fullpath="$PWD/$f"
  # Run /usr/bin/security verify-cert -h to see what the options do.
  /usr/bin/security verify-cert \
    -q \
    -l \
    -L \
    -R offline \
    -c "$fullpath"
  status="$?"
  if [ "$status" -eq 0 ]; then
    cat "$fullpath" >> "$outpath"
  fi
  rm "$fullpath"
done

printf "export SSL_CERT_FILE=%s\n" "$outpath"
