# BBS+ Signatures

[Latest Draft](https://mattrglobal.github.io/bbs-signatures-spec/)

BBS+ is a pairing-based cryptographic signature used for signing 1 or more messages.

## Contributing

The main specification is written in the markdown, however to preview the changes you have made in the final format, the following steps can be followed.

The tool `markdown2rfc` is used to convert the raw markdown representation to both an HTML and XML format. In order to run this tool you must have [docker](https://www.docker.com/) installed.

### Updating Docs

Update `spec.md` file with your desired changes.

Run the following to compile the new txt into the output HTML.

```./scripts/build-html.sh```
