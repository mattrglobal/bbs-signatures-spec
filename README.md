# BBS+ Signatures

BBS+ is a pairing-based cryptographic signature used for signing 1 or more messages. As described in the
[BBS+ spec](https://eprint.iacr.org/2016/663.pdf), BBS+ keys function in the following way:

1. A a prime field _&integers;<sub>p</sub>_
1. A bilinear pairing-friendly curve _E_ with three groups _&#x1D53E;<sub>1</sub>, &#x1D53E;<sub>2</sub>,
   &#x1D53E;<sub>T</sub>_ of prime order _p_.
1. A type-3 pairing function _e_ such that _e : &#x1D53E;<sub>1</sub> X &#x1D53E;<sub>2</sub> &xrarr;
   &#x1D53E;<sub>T</sub>_. More requirements for this can be found in section 4.1 in the
   [BBS+ spec](https://eprint.iacr.org/2016/663.pdf)
1. A base generator _g<sub>1</sub> &isin; &#x1D53E;<sub>1</sub>_ for curve _E_
1. A base generator _g<sub>2</sub> &isin; &#x1D53E;<sub>2</sub>_ for curve _E_
1. _L_ messages to be signed


**Key Generation** generate(L)


Inputs:
\- _L_ is the number of messages that can be signed

Output:
\- _p<sub>k</sub>_ is the public key
\- _x_ is the secret key

Steps:
   1. Generate a random generator for each message _(h<sub>1</sub>, ... , h<sub>L</sub>) &xlarr;
      &#x1D53E;<sub>1</sub><sup>L+1</sup>_
   1. Generate a random generator used for blinding factors _h<sub>0</sub> &xlarr; &#x1D53E;<sub>1</sub>_
   1. Generate random _x &xlarr; &integers;<sub>p</sub>_
   1. Compute _w &xlarr; g<sub>2</sub><sup>x</sup>_
   1. Secret key is _x_ and public _p<sub>k</sub>_ is _(w, h<sub>0</sub>, h<sub>1</sub>, ... , h<sub>L</sub>)_
   1. return _x, p<sub>k</sub>_
   
**Signature** sign(M, x, p<sub>k</sub>)

Inputs:
\- _M_ is an array of messages to be signed
\- _x_ is the secret key
\- _p<sub>k</sub>_ is the public key

Output:
\- _&sigma;_ is the signature

Steps:

   1. Each message _M_ is converted to integers _(m<sub>1</sub>, ..., m<sub>L</sub>) &isin; &integers;<sub>p</sub>_
   1. Generate random numbers _&epsi;, s &xlarr; &integers;<sub>p</sub>_
   1. Compute _B &xlarr; g<sub>1</sub>h<sub>0</sub><sup>s</sup> &prod;<sub>i=1</sub><sup>L</sup>h<sub>i</sub><sup>m<sub>i</sub></sup>_
   1. Compute _A &xlarr;B<sup>1&frasl;<sub>x+&epsi;</sub></sup>_
   1. return signature _&sigma; &xlarr; (A, &epsi;, s)_

**Verification** verify(&sigma;, M, p<sub>k</sub>)

Inputs:
\- _&sigma;_ is the signature
\- _p<sub>k</sub>_ is the public key
\- _M_ is an array of messages that were signed

Output:
\- _true_ if valid, _false_ otherwise

Steps:

   1. Each message _M_ is converted to integers _(m<sub>1</sub>, ..., m<sub>L</sub>) &isin; &integers;<sub>p</sub>_
   1. Compute _e(A, wg<sub>2</sub><sup>&epsi;</sup>) &#x225f; e(B, g<sub>2</sub>)_


**Zero-Knowledge Proof Generation** create_proof(&sigma;, M, p<sub>k</sub>, R, n)

Inputs:
\- _&sigma;_ is the signature
\- _p<sub>k</sub>_ is the public key
\- _M_ is an array of messages that were signed
\- _R_ is an array of indices for which messages in M are to be revealed
\- _n_ is an integer nonce (usually received from the verifier)

Output:
\- _&pi;_ is the zero-knowledge proof

Steps:

   1. To create a signature proof of knowledge where certain messages are disclosed and others remain hidden
   2. Each message _M_ is converted to integers _(m<sub>1</sub>, ..., m<sub>L</sub>) &isin; &integers;<sub>p</sub>_
   3. Generate random numbers _r<sub>1</sub>, r<sub>2</sub> &xlarr; &integers;<sub>p</sub>_
   4. Compute _B &xlarr; g<sub>1</sub>h<sub>0</sub><sup>s</sup> &prod;<sub>i=1</sub><sup>L</sup>h<sub>i</sub><sup>m<sub>i</sub></sup>_
   5. Compute _A' &xlarr; A<sup>r<sub>1</sub></sup>_
   6. Compute _A&#773; &xlarr; A'<sup>-&epsi;</sup>B<sup>r<sub>1</sub></sup>_
   7. Compute _d &xlarr; B<sup>r<sub>1</sub></sup>h<sub>0</sub><sup>-r<sub>2</sub></sup>_
   8. Compute _r<sub>3</sub> &xlarr; 1&frasl;<sub>r<sub>1</sub></sub>_
   9. Compute _s' &xlarr; s - r<sub>2</sub> r<sub>3</sub>_
   10. Compute _&pi;<sub>1</sub> &xlarr; A'<sup>-&epsi;</sup> h<sub>0</sub><sup>r<sub>2</sub></sup>_
   11. Compute for all hidden attributes _&pi;<sub>2</sub> &xlarr;d<sup>r<sub>3</sub></sup>h<sub>0</sub><sup>-s'</sup>&prod;<sub>i=1</sub><sup>R</sup>h<sub>i</sub><sup>m<sub>i</sub></sup>_
   12. The proof is &pi; &xlarr; (A', A&#773;, d, &pi;<sub>1</sub>, &pi;<sub>2</sub>)
   13. return &pi;


**Zero-Knowledge Proof Verification** verify_proof(&pi;, p<sub>k</sub>, M<sub>R</sub>, n)

Inputs:
\- _&pi;_ is the proof
\- _p<sub>k</sub>_ is the public key
\- _<sub>R</sub>_ is a list of revealed messages
\- _n_ is an integer nonce. Must be the same nonce used in create_proof

Output:
\- _true_ if the proof is valid, _false_ otherwise

Steps:

   1. Check signature _e(A', w) &#x225f; e(A&#773;, g<sub>2</sub>)_
   1. Check hidden attributes _A&#773;&frasl;<sub>d</sub> &#x225f; &pi;<sub>1</sub>_
   1. Check revealed attributes _g<sub>1</sub>&prod;<sub>i=1</sub><sup>A<sub>D</sub></sup>h<sub>i</sub><sup>m<sub>i</sub></sup> &#x225f; &pi;<sub>2</sub>_

The BBS+ spec does not specify when the generators _(h<sub>0</sub>, h<sub>1</sub>, ..., h<sub>L</sub>)_, only that they
are random generators. Generally in cryptography, public keys are created entirely during the key generation step.
However, Notice the only value in the public key _p<sub>k</sub>_ that is tied to the private key _x_ is _w_. If we
isolate this value as the public key _p<sub>k</sub>_, this is identical to the other elliptic curve cryptography keys like
[BLS signature keys](https://crypto.stanford.edu/~dabo/pubs/papers/BLSmultisig.html), Ed25519 or ECDSA. The remaining generators
could be computed at a later time, say during signing, verification, proof generation and verification. This means key
generation and storage is much smaller at the expense of computing the generators later when they are needed. Creating the
remaining generators in this manner requires all parties to be able to compute the same values, otherwise
signatures and proofs will not validate. In this Spec, we describe an efficient and secure method for computing the
public key generators on-the-fly.

## Proposal

In a prime field, any non-zero element in a prime order group generates the whole group, and ability to solve the
discrete log relatively to a specific generator is equivalent to ability to solve it for any other and the relative discrete logarithms are unknown. As long as the
generators meet these requirements, then any generator should be secure. To compute the generators, we propose using
IETF's [Hash to Curve](https://datatracker.ietf.org/doc/draft-irtf-cfrg-hash-to-curve/?include_text=1) **HashTo&#x1D53E;** algorithm which
is also constant time. This method satisfies our security requirements and allows any party to compute generators that can be used in
the BBS+ signature scheme.

## Notation

* a || b: denotes the concatenation of byte arrays a and b
* HashTo&#x1D53E;<sub>1</sub>: denotes the hash to curve function <CurveName>G1_XMD:SHA-256_SSWU_RO where <CurveName> is a pairing friendly curve.
* I2OSP: Convert a byte string to a non-negative integer as described in [RFC8017](https://tools.ietf.org/html/rfc8017).

## Algorithm

**ConvertToBBSPublicKey** converToBBSPublicKey(w, L)
Inputs:
\- _w_ is a point in &#x1D53E;<sub>2</sub> e.g. BLS public key
\- _L_ is the number of messages that can be signed

Output:
\- _h<sub>0</sub>, h<sub>1</sub>, ... , h<sub>L</sub>_, a list of points in &#x1D53E;<sub>1</sub>

Steps:

1. h = [0; L]
1. for i = 0; i <= L; i += 1:
&nbsp;&nbsp;&nbsp;&nbsp;h[i] = HashTo&#x1D53E;<sub>1</sub>(w || I2OSP(i, 4) || I2OSP(0, 1) || I2OSP(L, 4))

## Flow

**ConvertToBBSPublicKey** can be called prior to function calls like sign, verify, proof generation or proof verification. Key Generation can modified to accomadate this new method as follows

**Key Generation** generate()

Output:
\- _w_ is the public key
\- _x_ is the secret key