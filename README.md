# Build

```
bash generate-certificates.sh
(cd server && npm install)
```

# Run

```
(cd server && node .)
```

# Demo

- Install `certificates/intermediate-ca.crt` as Certificate Authority and the PKCS12 archives (`certificates/client-1.p12`, `certificates/client-2.p12`) as own certificates in your Browser, the password for the PKCS12 archives is "test" (see `generate-certificates.sh`).
- Open `client/index.html` in your Browser twice, for each window chose a different certificate to authenticate to simulate two different users.
- Send a message: The respective other page shows the message together with the correct sender.
