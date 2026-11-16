# docker-h2t

Container image for [h2t - HTTP Hardening Tool](https://github.com/gildasio/h2t), which checks a website's HTTP response headers and recommends security headers to add or remove.

Images are built for `linux/amd64` and `linux/arm64`, run as a non-root user and ship with an SBOM, build provenance and a keyless signature.

## Images

Images are published to GitHub Container Registry as `ghcr.io/think-cube/h2t`.

| Tag | Meaning | Changes? |
|---|---|---|
| `2.0.0` | Exact release | Never |
| `2.0`, `2`, `latest` | Newest matching release | With each release |
| `edge` | Newest build of `main` | With each merge and weekly rebuild |
| `edge-YYYYMMDD` | Weekly rebuild of `main` with current OS patches | Never |
| `sha-<commit>` | Build of one `main` commit | Never |

For production, pin by digest: `ghcr.io/think-cube/h2t:2.0.0@sha256:...`.

## Usage

h2t has two subcommands: `list` shows the header catalog and `scan` checks a website.

```bash
docker run --rm ghcr.io/think-cube/h2t:2 scan https://example.com
docker run --rm ghcr.io/think-cube/h2t:2 list -a -p description refs
```

Results are colored:

- `[+]` in yellow: a good header the site does not use yet. Consider adding it.
- `[-]` in red: a header that leaks information or weakens security. Consider removing it.
- `[+]` in green: a good header the site already uses. Shown with `scan -s`.

Use `scan -o csv` or `scan -o json` for machine-readable output, and `-h` on any subcommand for all options.

To scan a list of URLs, mount a file with one URL per line:

```bash
docker run --rm -v "$PWD/urls.txt:/opt/h2t/urls.txt:ro" ghcr.io/think-cube/h2t:2 scan urls.txt
```

## What is in the image

- h2t from [gildasio/h2t](https://github.com/gildasio/h2t), built from commit `56e1447` and verified against that commit when the image is built
- Python on Alpine Linux, in the versions named on the `FROM` line of the `Dockerfile`
- `requests` and `colorama`, pinned with hashes in `requirements.txt`, generated from `requirements.in`

## Verify an image

Check the signature:

```bash
cosign verify ghcr.io/think-cube/h2t:2.0.0 \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/Think-Cube/workflows/\.github/workflows/container-image\.yml@refs/tags/v.+$'
```

Read the SBOM and provenance:

```bash
docker buildx imagetools inspect ghcr.io/think-cube/h2t:2.0.0 --format '{{ json .SBOM }}'
docker buildx imagetools inspect ghcr.io/think-cube/h2t:2.0.0 --format '{{ json .Provenance }}'
```

## Build and test locally

```bash
docker build -t h2t:local .
bash tests/smoke.sh h2t:local
```

To change a Python dependency, edit `requirements.in` and regenerate the lock file:

```bash
pip-compile --generate-hashes --output-file=requirements.txt requirements.in
```

To move to a newer h2t, change the commit in both places on the `ADD` line of the `Dockerfile`.

## Support

Only the newest release receives fixes. `main` is rebuilt every week, and images with fixable critical vulnerabilities are not published. Report security issues in the image through [GitHub private vulnerability reporting](https://github.com/Think-Cube/docker-h2t/security/advisories/new), and issues in h2t itself [upstream](https://github.com/gildasio/h2t/issues).

## License

The packaging in this repository is licensed under the [MIT License](LICENSE). h2t is licensed under the MIT License by Gildásio Júnior; its license is included in the image at `/opt/h2t/LICENSE`.

## Contribution

Feel free to contribute by opening issues or pull requests. Your feedback and improvements are highly appreciated!
