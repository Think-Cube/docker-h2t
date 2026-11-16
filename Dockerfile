FROM python:3.14-alpine3.24@sha256:5862d971d1f0ae26b258cefa4e893556b1d3aba81bd2ff30888704ad378bab67

LABEL org.opencontainers.image.title="h2t" \
      org.opencontainers.image.description="h2t - HTTP Hardening Tool in a non-root image" \
      org.opencontainers.image.vendor="Think-Cube" \
      org.opencontainers.image.authors="contact@thinkcube.dev" \
      org.opencontainers.image.licenses="MIT"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# The upgrade is what lets the weekly rebuild pick up security patches
# while the base image stays pinned by digest.
RUN apk upgrade --no-cache

COPY requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir --root-user-action=ignore --only-binary=:all: --require-hashes \
        -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Upstream h2t (MIT, Gildásio Júnior), pinned to a commit and verified by its SHA.
# Its LICENSE ships with the source in /opt/h2t.
ADD --checksum=56e1447848f5382b8a5a7dfd00e84b1a0335a589 \
    https://github.com/gildasio/h2t.git#56e1447848f5382b8a5a7dfd00e84b1a0335a589 /opt/h2t

RUN addgroup -S -g 10001 h2t && \
    adduser -S -D -H -u 10001 -G h2t h2t

WORKDIR /opt/h2t

USER 10001:10001

ENTRYPOINT ["python", "h2t.py"]
