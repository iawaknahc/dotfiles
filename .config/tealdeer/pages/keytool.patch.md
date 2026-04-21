- Export the signing certificate in PEM format from an Android signing key store (.jks):

`keytool -exportcert -keystore {{path/to/keystore.jks}} -alias {{key_alias}} -rfc`
