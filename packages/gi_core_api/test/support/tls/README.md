TEST ONLY. A throwaway self-signed certificate and its private key for
`test/tls_untrusted_test.dart`, which serves HTTPS on 127.0.0.1 and checks
that the client maps the untrusted certificate to `ApiFailure.tlsUntrusted`.

They protect nothing, are trusted by nothing and must never be used outside
tests. Regenerate (valid for 100 years) with:

    openssl req -x509 -newkey rsa:2048 -nodes -days 36500 \
      -keyout test_only_key.pem -out test_only_cert.pem \
      -subj "/CN=gi-core-api test only (self-signed)" \
      -addext "subjectAltName=IP:127.0.0.1,DNS:localhost"
