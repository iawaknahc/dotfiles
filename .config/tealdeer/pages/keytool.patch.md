- Export the signing certifcate in PEM format from a Android signing key store (.jks):

`keytool -exportcert -keystore {{path/to/keystore.jks}} -alias {{key_alias}} -rfc`
