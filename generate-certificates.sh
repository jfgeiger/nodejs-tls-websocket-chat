# Setup

CERTS_FOLDER=certificates
rm -rf "$CERTS_FOLDER"
mkdir -p "$CERTS_FOLDER"

# Root CA
openssl genrsa -out "$CERTS_FOLDER"/root-ca.key 4096
openssl req -x509 -new -nodes -key "$CERTS_FOLDER"/root-ca.key -sha256 -days 1024 -out "$CERTS_FOLDER"/root-ca.crt -subj "/CN=Root CA"

# Intermediate CA
openssl genrsa -out "$CERTS_FOLDER"/intermediate-ca.key 4096
openssl req -new -sha256 -key "$CERTS_FOLDER"/intermediate-ca.key -subj "/CN=Intermediate CA" -out "$CERTS_FOLDER"/intermediate-ca.csr
CONFIG="
[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
"
openssl x509 -req -in "$CERTS_FOLDER"/intermediate-ca.csr -CA "$CERTS_FOLDER"/root-ca.crt -CAkey "$CERTS_FOLDER"/root-ca.key -CAcreateserial -out "$CERTS_FOLDER"/intermediate-ca.crt -days 500 -sha256 -extfile <(echo "$CONFIG") -extensions v3_intermediate_ca
openssl verify -verbose -CAfile "$CERTS_FOLDER"/root-ca.crt "$CERTS_FOLDER"/intermediate-ca.crt

# Server
openssl genrsa -out "$CERTS_FOLDER"/localhost.key 4096
openssl req -new -sha256 -key "$CERTS_FOLDER"/localhost.key -subj "/CN=localhost" -out "$CERTS_FOLDER"/localhost.csr
openssl x509 -req -in "$CERTS_FOLDER"/localhost.csr -CA "$CERTS_FOLDER"/intermediate-ca.crt -CAkey "$CERTS_FOLDER"/intermediate-ca.key -CAcreateserial -out "$CERTS_FOLDER"/localhost.crt -days 500 -sha256
openssl verify -verbose -CAfile <(cat "$CERTS_FOLDER"/intermediate-ca.crt "$CERTS_FOLDER"/root-ca.crt) "$CERTS_FOLDER"/localhost.crt
cat "$CERTS_FOLDER"/intermediate-ca.crt "$CERTS_FOLDER"/root-ca.crt > "$CERTS_FOLDER"/server-ca.crt

# Client 1
openssl genrsa -out "$CERTS_FOLDER"/client-1.key 4096
openssl req -new -sha256 -key "$CERTS_FOLDER"/client-1.key -subj "/CN=client-1" -out "$CERTS_FOLDER"/client-1.csr
openssl x509 -req -in "$CERTS_FOLDER"/client-1.csr -CA "$CERTS_FOLDER"/intermediate-ca.crt -CAkey "$CERTS_FOLDER"/intermediate-ca.key -CAcreateserial -out "$CERTS_FOLDER"/client-1.crt -days 500 -sha256
openssl verify -verbose -CAfile <(cat "$CERTS_FOLDER"/intermediate-ca.crt "$CERTS_FOLDER"/root-ca.crt) "$CERTS_FOLDER"/client-1.crt
openssl pkcs12 -export -out certificates/client-1.p12 -inkey certificates/client-1.key -in certificates/client-1.crt -passout pass:test

# Client 2
openssl genrsa -out "$CERTS_FOLDER"/client-2.key 4096
openssl req -new -sha256 -key "$CERTS_FOLDER"/client-2.key -subj "/CN=client-2" -out "$CERTS_FOLDER"/client-2.csr
openssl x509 -req -in "$CERTS_FOLDER"/client-2.csr -CA "$CERTS_FOLDER"/intermediate-ca.crt -CAkey "$CERTS_FOLDER"/intermediate-ca.key -CAcreateserial -out "$CERTS_FOLDER"/client-2.crt -days 500 -sha256
openssl verify -verbose -CAfile <(cat "$CERTS_FOLDER"/intermediate-ca.crt "$CERTS_FOLDER"/root-ca.crt) "$CERTS_FOLDER"/client-2.crt
openssl pkcs12 -export -out certificates/client-2.p12 -inkey certificates/client-2.key -in certificates/client-2.crt -passout pass:test

# Malicious CA
openssl genrsa -out "$CERTS_FOLDER"/malicious-root-ca.key 4096
openssl req -x509 -new -nodes -key "$CERTS_FOLDER"/malicious-root-ca.key -sha256 -days 1024 -out "$CERTS_FOLDER"/malicious-root-ca.crt -subj "/CN=CA"

# Malicious client
openssl genrsa -out "$CERTS_FOLDER"/malicious-client.key 4096
openssl req -new -sha256 -key "$CERTS_FOLDER"/malicious-client.key -subj "/CN=client" -out "$CERTS_FOLDER"/malicious-client.csr
openssl x509 -req -in "$CERTS_FOLDER"/malicious-client.csr -CA "$CERTS_FOLDER"/malicious-root-ca.crt -CAkey "$CERTS_FOLDER"/malicious-root-ca.key -CAcreateserial -out "$CERTS_FOLDER"/malicious-client.crt -days 500 -sha256
openssl verify -verbose -CAfile "$CERTS_FOLDER"/malicious-root-ca.crt "$CERTS_FOLDER"/malicious-client.crt
openssl pkcs12 -export -out certificates/malicious-client.p12 -inkey certificates/malicious-client.key -in certificates/malicious-client.crt -passout pass:test