# GI Edge device simulator for contract/compose.contract.yml.
# Build context: tools/gi_edge_sim. One dependency (package:crypto), so the
# build runs `dart pub get`; the runtime image is the AOT binary only.
FROM dart:3.14@sha256:520700c66210aa263db8c782783839cb14d577a2f1a01774cdec6d6561668da4 AS build
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get
COPY bin bin
COPY lib lib
RUN mkdir /out && dart compile exe bin/gi_edge_sim.dart -o /out/gi_edge_sim

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /out/gi_edge_sim /app/gi_edge_sim
# GI Core only talks to devices on port 80 (esphome-http.client.ts parseEndpoint);
# 8081 is the control surface (/fake/*), published on loopback only.
EXPOSE 80 8081
ENTRYPOINT ["/app/gi_edge_sim"]
