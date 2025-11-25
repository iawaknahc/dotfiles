# openssl

> Personal quick reference on openssl.

- Generate N random bytes:

`openssl rand {{-base64|-hex}} {{N}}`

- Generate a 2048-bit RSA private key in PKCS#8, ASN.1 DER form, public key in PKIX, ASN.1 DER form:

`openssl genpkey -algorithm RSA -out {{pkcs8.pem}} -outpubkey {{pkix.pem}} -pkeyopt rsa_keygen_bits:2048`

- Convert an RSA private key in PKCS#8, ASN.1 DER form to PKCS#1, ASN.1 DER form:

`openssl rsa -in {{pkcs8.pem}} -traditional -out {{pkcs1-priv.pem}}`

- Convert an RSA private key in PKCS#1, ASN.1 DER form to PKCS#8, ASN.1 DER form:

`openssl pkcs8 -topk8 -nocrypt -in {{pkcs1-priv.pem}} -out {{pkcs8.pem}}`

- Convert an RSA public key in PKIX, ASN.1 DER form to PKCS#1, ASN.1 DER form:

`openssl rsa -pubin -in {{pkix.pem}} -RSAPublicKey_out -out {{pkcs1-pub.pem}}`

- Convert an RSA public key in PKCS#1, ASN.1 DER form to PKIX, ASN.1 DER form:

`openssl rsa -RSAPublicKey_in -in {{pkcs1-pub.pem}} -pubout -out {{pkix.pem}}`

- Generate an EC private key in PKCS#8, ASN.1 DER form, public key in PKIX, ASN.1 DER form:

`openssl genpkey -algorithm EC -out {{pkcs8.pem}} -outpubkey {{pkix.pem}} -pkeyopt ec_paramgen_curve:{{P-192|P-224|P-256|P-384|P-521}}`

- Convert an EC private key in PKCS#8, ASN.1 DER form to SEC 1, ASN.1 DER form:

`openssl ec -in {{pkcs8.pem}} -out {{sec1.pem}}`

- Generate an Ed25519 private key in PKCS#8, ASN.1 DER form, public key in PKIX, ASN.1 DER form:

`openssl genpkey -algorithm ED25519 -out {{pkcs8.pem}} -outpubkey {{pkix.pem}}`

- Generate an X25519 private key in PKCS#8, ASN.1 DER form, public key in PKIX, ASN.1 DER form:

`openssl genpkey -algorithm X25519 -out {{pkcs8.pem}} -outpubkey {{pkix.pem}}`

- Calculate HMAC-SHA256 of `stdin` with a key encoded in hex:

`openssl mac -macopt hexkey:{{hmac-key-in-hex}} -digest SHA256 -in - HMAC`

- Unarchive a PKCS#12 file, and do not encrypt the private keys:

`openssl pkcs12 -in {{pkcs12.pem}} -noenc -legacy`

- Inspect a x509 certificate:

`openssl x509 -noout -text -in {{x509.pem}}`

- Inspect a private key:

`openssl pkey -noout -text -in {{priv.pem}}`

- Inspect a public key:

`openssl pkey -noout -text -pubin -in {{pub.pem}}`

- Get the public key of a private key:

`openssl pkey -pubout -in {{priv.pem}}`

- Generate a self-signed CA certificate valid for 365 days:

`openssl req -x509 -key {{ca-priv.pem}} -subj "/CN=ca" -addext "basicConstraints=critical,CA:TRUE, pathlen:0" -addext "keyUsage=critical, keyCertSign, cRLSign" -days 365 -out {{ca-cert.pem}}`

- Generate a TLS certificate signed by a CA valid for 30 days:

`openssl req x509 -CA {{ca-cert.pem}} -CAkey {{ca-priv.pem}} -key {{tls-priv.pem}} -subj "/CN=tls" -addext "basicConstraints=critical,CA:FALSE" -addext "keyUsage=critical, digitalSignature" -addext "extendedKeyUsage=critical, serverAuth, clientAuth" -addext "subjectAltName=critical, DNS:localhost, IP:127.0.0.1, IP:::1" -days 30 -out {{tls-cert.pem}}`

- Print the SHA256 / SHA1 / MD5 fingerprint of a certificate:

`openssl x509 -noout -fingerprint {{-sha256|-sha1|-md5}} -in {{cert.pem}} | awk -F= '{ gsub(/:/, "", $2); print tolower($2) }'`
