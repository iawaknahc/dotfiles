- Split a x509 certificate bundle into file named xx0000, xx0001, up to xx9999:

`csplit -f xx -n 4 -s -k {{filename}} '/-----BEGIN CERTIFICATE-----/' '{9999}'`
