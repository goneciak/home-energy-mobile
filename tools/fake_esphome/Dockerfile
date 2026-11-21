# Fake GI/ESPHome controller for contract/compose.contract.yml (spike S6).
# Build context: tools/fake_esphome. dart:io only, so no pub get is needed.
FROM dart:3.14@sha256:520700c66210aa263db8c782783839cb14d577a2f1a01774cdec6d6561668da4 AS build
WORKDIR /src
COPY bin/fake_esphome.dart bin/
RUN mkdir /out && dart compile exe bin/fake_esphome.dart -o /out/fake_esphome

# Minimal runtime: the AOT binary plus the libraries the Dart image ships in
# /runtime (the pattern documented for the official dart image).
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /out/fake_esphome /app/fake_esphome
# GI Core only talks to devices on port 80 (esphome-http.client.ts parseEndpoint).
EXPOSE 80
ENTRYPOINT ["/app/fake_esphome"]
