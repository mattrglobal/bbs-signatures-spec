# BBS+ Signatures

[Latest Draft](https://mattrglobal.github.io/bbs-signatures-spec/)

BBS+ is a pairing-based cryptographic signature used for signing 1 or more messages.

## Relevant Links

The following is a curated list of relevant links to BBS+ signatures

- [Rust BBS+ Signatures](https://github.com/hyperledger/ursa/tree/master/libzmix/bbs)
- [Rust Crate BBS+ Signatures](https://crates.io/crates/bbs)
- [Node JS BBS+ Signatures](https://github.com/mattrglobal/node-bbs-signatures)
- [WASM JS BSS+ Signatures](https://github.com/mattrglobal/bbs-signatures)
- [BLS 12-381 Key Pair JS](https://github.com/mattrglobal/bls12381-key-pair)
- [BBS+ JSON-LD Signatures JS](https://github.com/mattrglobal/jsonld-signatures-bbs)
- [BBS+ JSON-LD Signatures Spec](https://w3c-ccg.github.io/ldp-bbs2020/)
- [FFI for BBS+ Signatures](https://github.com/mikelodder7/ffi-bbs-signatures)
- [C# BBS+ Signatures](https://github.com/streetcred-id/bbs-signatures-dotnet)

## Contributing

The main specification is written in the markdown, however to preview the changes you have made in the final format, the following steps can be followed.

The tool `markdown2rfc` is used to convert the raw markdown representation to both an HTML and XML format. In order to run this tool you must have [docker](https://www.docker.com/) installed.

### Updating Docs

Update `spec.md` file with your desired changes.

Run the following to compile the new txt into the output HTML.

```./scripts/build-html.sh```
