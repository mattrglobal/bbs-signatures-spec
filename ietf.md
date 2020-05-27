CFRG                                                      Michael Lodder
Internet-Draft                                              Mattr Global
Intended status: Informational                             Tobias Looker
Expires: {EXPIRE-DATE}                                      Mattr Global
                                                          {Today's Date}

                **BBS+ Signature Scheme**
            draft-irtf-cfrg-bbs-plus-signature-00

Abstract

  BBS+ is a short group digital signature that allows a set of
  messages to be signed with a single key. The scheme permits a
  signer and signature holder to be two separate parties. The holder
  creates a Pedersen commitment which is combined with other
  messages by the signer to complete a blind signature which can be
  unblinded by the holder. Lastly, BBS+ also supports an efficient
  Zero-Knowledge Signature Proof of Knowledge construction where a
  holder can selectively disclose any subset of signed messages to
  another party without revealing the signature or the hidden messages.

Status of This Memo

   This Internet-Draft is submitted in full conformance with the
   provisions of BCP 78 and BCP 79.

   Internet-Drafts are working documents of the Internet Engineering
   Task Force (IETF).  Note that other groups may also distribute
   working documents as Internet-Drafts.  The list of current Internet-
   Drafts is at https://datatracker.ietf.org/drafts/current/.

   Internet-Drafts are draft documents valid for a maximum of six months
   and may be updated, replaced, or obsoleted by other documents at any
   time.  It is inappropriate to use Internet-Drafts as reference
   material or to cite them other than as "work in progress."

   This Internet-Draft will expire on {EXPIRE-DATE}

Copyright Notice

   Copyright (c) 2020 IETF Trust and the persons identified as the
   document authors.  All rights reserved.

   This document is subject to BCP 78 and the IETF Trust's Legal
   Provisions Relating to IETF Documents
   (https://trustee.ietf.org/license-info) in effect on the date of
   publication of this document.  Please review these documents
   carefully, as they describe your rights and restrictions with respect
   to this document.  Code Components extracted from this document must
   include Simplified BSD License text as described in Section 4.e of
   the Trust Legal Provisions and are provided without warranty as
   described in the Simplified BSD License.

Table of Contents

1.  Introduction

   A signature scheme is a fundamental cryptographic primitive that is
   used to protect authenticity and integrity of communication.  Only
   the holder of a secret key can sign messages, but anyone can verify
   the signature using the associated public key.
  
   Signature schemes are used in point-to-point secure communication
   protocols, PKI, remote connections, etc.  Designing efficient and
   secure digital signature is very important for these applications.
   
   This document describes the BBS+ signature scheme. The scheme features
   many important properties:
   
   1. The signature is over a group of Pedersen commitments--signatures
      can be created blinded or unblinded.
   
   2. The signature is encoded as a single group element and two field
      elements.
   
   3. Verification requires 2 pairing operations.
   
   4. Simple signature schemes require the entire signature
      and message be disclosed during verification. BBS+ allows a fast
      and small zero-knowledge signature proof of knowledge to be
      created from the signature and the public key. This allows the
      signature holder to selectively reveal any number of signed
      messages to another entity (none, all, or any number in between).    
      
   These properties allow the scheme to be used in applications where
   privacy and data minimization techniques are desired and/or required.
     
   A recent emerging use case applies signature schemes in [verifiable
   credentials](https://www.w3.org/TR/vc-data-model/). One problem with
   using simple signature schemes like ECSDA or ED25519 is a holder
   must disclose the entire signed message and signature for verification.
   Circuit based logic can be applied to verify these in zero-knowledge
   like SNARKS or Bulletproofs with R1CS but tend to be complicated.
   BBS+ on the other hand adds, to verifiable credentials or any other
   application, the ability to do very efficient zero-knowledge proofs.
   A holder gains the ability to choose which claims to reveal to a
   relying party without the need for any additional complicated logic.
   
1.1.  Comparison with ECC signatures

   The following comparison assumes BBS+ signatures with curve BLS12-381,
   targeting 128 bit security.
   
   For 128 bits security, ECDSA with curve P-256 takes 37 and 79 micro-
   seconds to sign and verify signature on a modern computer. BBS+
   680 and 1400 milliseconds to sign and verify a single message. However,
   ECDSA can only sign a single message whereas BBS+ can sign any
   number of messages at the expense of a bigger public key. To sign
   and verify 10 messages takes 3.7 and 5.4 milliseconds, and 22.3 and
   24.4 milliseconds for 100 messages.
   
   The signature size remains constant regardless of the number of signed
   messages. ECDSA and ED25519 use 32 bytes for public keys and 64 bytes
   for signatures. In contrast, BBS+ public key sizes follow the formula
   48 * (messages + 1) + 96, and 112 bytes for signatures. However,
   A single BBS+ signature is sufficient to authenticate multiple
   messages. We also present a method that only needs 96 bytes for the
   public key at the expense of a some computation before performing
   operations like signing, proof generation, and verification.

1.2.  Requirements

   The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
   "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
   document are to be interpreted as described in [RFC2119].
   
1.3.  Organization of this document
   
   This document is organized as follows:
   
   * The remainder of this section defines terminology and the high-
     level API.
   
   * Section 2 defines primitive operations used in the BLS signature
     scheme. These operations MUST NOT be used alone.
   
   * Section 3 defines two BBS+ Signature schemes giving slightly
     different security and performance properties.
   
   * Section 4 defines the format for a ciphersuites and gives
     recommended ciphersuites.
   
   * The appendices give test vectors, etc.
   
1.4.  Terminology, definitions, and notation

   The following terminology is used throughout this document:
   
   * SK: The secret key for the signature scheme
   
   * PK: The public key for the signature scheme containing all
     information needed to perform cryptographic operations.
     
   * DPK: The short form of the public key or deterministic public
     key.
     
   * U: The set of messages that are blinded from the signer during
     a blind signing.
     
   * K: The set of messages that are known to the signer during a
     blind signing.
     
   * L: The total number of messages that the signature scheme 
     can sign.
     
   * R: The set of message indices that are revealed in a signature
     proof of knowledge.
     
   * msg: The input to be signed by the signature scheme.
   
   * h_i: The generator corresponding to a given msg.
   
   * h0: A generator for the blinding value in the signature.
   
   * signature: The digital signature output.
   
   * s': The signature blinding factor held by the signature recipient.
     
   * blind_signature: The blind digital signature output.
   
   * commitment: A pedersen commitment composed of 1 or more messages.
   
   * nonce: A cryptographic nonce
   
   * spk: Zero-Knowledge Signature Proof of Knowledge.
   
   * nizk: A non-interactive zero-knowledge proof from fiat-shamir
     heuristic.
   
   * dst: The domain separation tag, the ASCII string
     "BLS12381G1_XMD:BLAKE2B_SSWU_RO_BBS+_SIGNATURES:1_0_0" comprising
      52 octets.
      
   * I2OSP and OS2IP are the functions defined in [RFC8017], Section 4.
   
   * a || b denotes the concatenation of octet strings a and b.
   
   A pairing-friendly elliptic curve defines the following primitives
   (see [I-D.irtf-cfrg-pairing-friendly-curves] for detailed
   discussion):
   
   * E1, E2: elliptic curve groups defined over finite fields. This
     document assumes that E1 has a more compact representation than
     E2, i.e., because E1 is defined over a smaller field than E2. 
   
   * G1, G2: subgroups of E1 and E2 (respectively) having prime order r.
   
   * GT: a subgroup, of prime order r, of the multiplicative group of a
     field extension.
     
   * e: G1 x G2 -> GT: a non-degenerate bilinear map.
   
   * P1, P2: points on G1 and G2 respectively. For a pairing-friendly
     curve, this document denotes operations in E1 and E2 in additive
     notation, i.e., P + Q denotes point addition and x * P denotes
     scalar multiplication. Operations in GT are written in
     multiplicative notation, i.e., a * b is field multiplication.
   
   * hash_to_curve_g1(ostr) -> P: The cryptographic hash function that
     takes as an arbitrary octet string input and returns a point in G1
     as defined in https://datatracker.ietf.org/doc/draft-irtf-cfrg
     -hash-to-curve/?include_text=1. The algorithm is
     BLS12381G1_XMD:BLAKE2B_SSWU_RO, i.e use Blake2b-512 as part of
     expand message digest, apply the isogeny simplified SWU map to
     compute a point in G1 using the random oracle method. The domain
     separation tag value is dst.
   
   * hash_to_curve_g2(ostr) -> P: The cryptographic hash function that
     takes as an arbitrary octet string input and returns a point in G1
     as defined in https://datatracker.ietf.org/doc/draft-irtf-cfrg
     -hash-to-curve/?include_text=1. The algorithm is
     BLS12381G2_XMD:BLAKE2B_SSWU_RO, i.e use Blake2b-512 as part of
     expand message digest, apply the isogeny simplified SWU map to
     compute a point in G2 using the random oracle method. The domain
     separation tag value is dst.
     
   * point_to_octets(P) -> ostr: returns the canonical
     representation of the point P as an octet string.  This
     operation is also known as serialization.
     
   * octets_to_point(ostr) -> P: returns the point P corresponding
     to the canonical representation ostr, or INVALID if ostr is not
     a valid output of point_to_octets.  This operation is also
     known as deserialization.
     
   * subgroup_check(P) -> VALID or INVALID: returns VALID when the
     point P is an element of the subgroup of order r, and INVALID
     otherwise.  This function can always be implemented by checking
     that r * P is equal to the identity element.  In some cases,
     faster checks may also exist, e.g., [Bowe19].
     
1.4. Other Functions

   The following functions are also used as part of the BBS+ signature
   scheme.

   * blake2b: The Blake2b hash function defined in [RFC7693].
   
     
1.5.  API

   The BBS+ signature scheme defines the following API:
   
   * KeyGen(IKM) -> SK: a key generation algorithm that takes as input
     an octet string comprising secret keying material, and outputs a
     secret key SK.
   
   * SkToDpk(SK) -> DPK: a public key generation algorithm that takes
     as input a secret key and outputs a deterministic public key, the
     public key short form 
     
   * SkToPk(SK) -> PK: an algorithm that takes as input a secret key
     and outputs the corresponding public key.
     
   * DpkToPk(DPK, count): an algorithm that takes as input the short
     public key form or deterministic public key and the number of
     messages that the key is capable of signing simultaneously and
     outputs the corresponding public key.
     
   * Sign((msg_i,...,msg_L), SK, PK) -> signature: a signing
     algorithm that generates a randomized signature given a secret
     key, public key and a vector of messages.
     
   * Verify(PK, signature, (msg_i,...,msg_L)) -> VALID or INVALID:
     an algorithm that outputs VALID if the signature is valid for
     all messages under the public key.
     
   * PreBlindSign((msg_i,...,msg_U), (h_i,...,h_U), h0) ->
     (commitment, s'): an algorithm that generates a
     randomized commitment from a vector of messages that will be
     blind to the signer and generators taken from the public key.
     The commitment is given to the signer and the blinding factor
     is retained by the holder to unblind the signature. 
     
   * BlindSign(commitment, (msg_i,...,msg_K), (h_i,...,h_K), SK, h0)
     -> blind_signature: a signing algorithm that produces a blind
     signature from a vector of known messages, a commitment from a
     signature recipient, the remaining generators taken from the
     public key, and a secret key.
     
   * UnblindSign(blind_signature, s') -> signature:
     an unblinding algorithm that uses a signature blinding value
     and blind signature and yields a digital signature.
     
   * BlindMessagesProofGen((msg_i,...,msg_U), (h_i,...,h_U), h0, nonce)
     -> nizk: creates a zero-knowledge proof
     for proving a knowledge about a set of committed messages.
     
   * BlindMessagesProofVerify(nizk, (h_i,...,h_H), h0, nonce) -> 
     VALID or INVALID: outputs if a proof of committed messages is VALID
     or not given a proof, generators, and nonce. 
     
   * SpkGen(signature, PK, (msg_i,...,msg_L), R, nonce) -> spk: A non 
     interactive zero-knowledge proof generation algorithm from a BBS+
     signature, a public key, a set of revealed messages, and a
     verifier nonce.
     
   * SpkVerify(spk, PK, (msg_i,...,msg_R), nonce) -> VALID or INVALID:
     an algorithm that verifies if signature proof of knowledge is
     valid or not from a proof, a public key, and a set of revealed
     messages.
     
1.5. Requirements

   The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
   "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
   document are to be interpreted as described in [RFC2119].
   
2. Core operations

   This section defines core operations used by the schemes defined in
   Section 3.  These operations MUST NOT be used except as described in
   that section.
   
2.1 Parameters

   The core operations in this section depend on several parameters:
   
   * A pairing-friendly elliptic curve, plus associated functionality
     given in Section 1.4.
     
   * H, a hash function that MUST be a secure cryptographic hash
     function, e.g. Blake2b-512. For security, H MUST output
     at least ceil(log2(r)) bits, where r is the order of the subgroups
     G1 and G2 defined by the pairing-friendly elliptic curve.
     
   * PRF(n): a pseudo-random function similar to [RFC4868]. Returns n
     pseudo randomly generated bytes.

2.2. KeyGen

   The KeyGen algorithm generates a secret key SK deterministically
   from a secret octet string IKM.
   
   KeyGen uses HKDF [RFC5869] instantiated with the hash function H.
   
   For security, IKM MUST be infeasible to guess, e.g., generated by a
   trusted source of randomness.  IKM MUST be at least 32 bytes long,
   but it MAY be longer.
   
   Because KeyGen is deterministic, implementations MAY choose either to
   store the resulting SK or to store IKM and call KeyGen to derive SK
   when necessary.
   
   KeyGen takes an optional parameter, key_info.  This parameter MAY be
   used to derive multiple independent keys from the same IKM.  By
   default, key_info is the empty string.
   
   SK = KeyGen(IKM)
   
   Inputs:
   - IKM, a secret octet string. See requirements above.
   
   Outputs:
   - SK, a uniformly random integer such that 0 < SK < r.
   
   Parameters:
   - key_info, an optional octect string.
     If key_info is not supplied, it defaults to the empty string.
     
   Definitions:
   - HKDF-Extract is as defined in RFC5869, instantiated with hash H.
   - HKDF-Expand is as defined in RFC5869, instantiated with hash H.
   - I2OSP and OS2IP are as defined in RFC8017, Section 4.
   - L is the integer given by ceil((3 * ceil(log2(r))) / 16).
   - "BBS-SIG-KEYGEN-SALT-" is an ASCII string comprising 20 octets. 
    
   Procedure:
   1. PRK = HKDF-Extract("BBS-SIG-KEYGEN-SALT-", IKM || I2OSP(0, 1))
   2. OKM = HKDF-Expand(PRK, key_info || I2OSP(L, 2), L)
   3. SK = OS2IP(OKM) mod r
   4. return SK
   
2.3. SkToDpk
   SkToDpk algorithm takes a secret key SK and outputs a corresponding
   short formed public key.
    
   SK MUST be indistinguishable from uniformly random modulo r
   (Section 2.2) and infeasible to guess, e.g., generated using a
   trusted source of randomness.  KeyGen (Section 2.3) outputs SK
   meeting these requirements.  Other key generation approaches meeting
   these requirements MAY also be used; details of such methods are
   beyond the scope of this document.
   
   DPK = SkToDpk(SK)
   
   Inputs:
   - SK, a secret integer such that 0 <= SK <= r
   
   Outputs:
   - DPK, a public key encoded as an octet string
   
   Procedure:
   1. w = SK * P2
   2. DPK = w
   3. return DPK
   
2.4. SkToPk

   The SkToPk algorithm takes a secret key SK and the number of messages
   that can be signed and outputs the corresponding public key PK.
   
   SK MUST be indistinguishable from uniformly random modulo r
   (Section 2.2) and infeasible to guess, e.g., generated using a
   trusted source of randomness.  KeyGen (Section 2.3) outputs SK
   meeting these requirements.  Other key generation approaches meeting
   these requirements MAY also be used; details of such methods are
   beyond the scope of this document.
   
   PK = SkToPk(Sk, count)
   
   Inputs:
   - SK, a secret integer such that 0 <= SK <= r
   - count, an integer
    
   Outputs:
   - PK, a public key encoded as an octet string
   
   Procedure:
   1. w = SK * P2
   2. h0 = hash_to_curve_g1( w || I2OSP(0, 1) || I2OSP(0, 4) ||
                             I2OSP(0, 1) || I2OSP(count, 4) )
   3. h = \[count\]
   4. for i in 0 to count:
         h\[i\] = hash_to_curve_g1( w || I2OSP(0, 1) || I2OSP(i + 1, 4)
                                    || I2OSP(0, 1) || I2OSP(count, 4) )
   5. PK = (w, h0, h)
   6. return PK
     
2.5. DpkToPk

   DpkToPk converts the short form of the public key to the long form
   just like SkToPk.
   
   PK = DpkToPk(DPK, count)
   
   Inputs:
   - DPK, the short form of the public key
   - count, an integer
   
   Outputs:
   - PK, a public key encoded as an octet string
   
   Procedure:
   1. w = DPK
   2. h0 = hash_to_curve_g1( w || I2OSP(0, 1) || I2OSP(0, 4) ||
                             I2OSP(0, 1) || I2OSP(count, 4) )
   3. h = \[count\]
   4. for i in 0 to count:
         h\[i\] = hash_to_curve_g1( w || I2OSP(0, 1) || I2OSP(i + 1, 4)
                                    || I2OSP(0, 1) || I2OSP(count, 4) )
   5. PK = (w, h0, h)
   6. return PK
    
2.6. KeyValidate

   KeyValidate checks if the public key is valid.
   
   As an optimization, implementations MAY cache the result of
   KeyValidate in order to avoid unnecessarily repeating validation for
   known keys.
   
   result = KeyValidate(PK)
   
   Inputs:
   - PK, a public key in the format output by SkToPk.
   
   Outputs:
   - result, either VALID or INVALID
   
   Procedure:
   1. (w, h0, h) = PK
   2. result = subgroup_check(w) && subgroup_check(h0)
   3. for i in 0 to len(h):
         result &= subgroup_check(h\[i\])
   4. return result
     
2.7. Sign

   Sign computes a signature from SK, PK, over a vector of messages.
   
   signature = Sign((msg_i,...,msg_n), SK, PK)
   
   Inputs:
   - msg_i,...,msg_n, octet strings
   - SK, a secret key output from KeyGen
   - PK, a public key output from either DpkToPk or SkToPk
   
   Outputs:
   - signature, an octet string
   
   Procedure:
   1. (w, h0, h) = PK
   2. e = H(PRF(8*ceil(log2(r)))) mod r
   3. s = H(PRF(8*ceil(log2(r)))) mod r
   4. b = P1 + h0 * s + h_i * msg_i + ... + h_n * msg_n
   5. A = b * (1 / (SK + e))
   6. signature = (A, e, s)
   7. return signature

2.8. Verify

   Verify checks that a signature is valid for the octet string
   messages under the public key.
   
   result = Verify((msg_i,...,msg_n), signature, PK)
   
   Inputs:
   - msg_i,...,msg_n, octet strings.
   - signature, octet string.
   - PK, a public key in the format output by SkToPk.
   
   Outputs:
   - result, either VALID or INVALId.
   
   Procedure:
   1. if subgroup_check(signature) is INVALID, return INVALID
   2. if KeyValidate(PK) is INVALID, return INVALID
   3. b = P1 + h0 * s + h_i * msg_i + ... + h_n * msg_n
   4. C1 = e(A, w * P2 ^ e)
   5. C2 = e(b, P2)
   6. return C1 == C2
     
2.9. PreBlindSign

   The PreBlindSign algorithm allows a holder of a signature to blind
   messages that when signed, are unknown to the signer.
   
   The algorithm takes generates a blinding factor that is used to
   unblind the signature from the signer, and a pedersen commitment
   from the generators in the signers public key PK and a vector of
   messages.
   
   s', commitment = PreBlindSign((msg_i,...,msg_U),h0, (h_i,...,h_U))
   
   Inputs:
   - msg_i,...,msg_U, octet strings of the messages to be blinded.
   - h0, octet string.
   - h_i,...,h_U, octet strings of generators for the messages to
     be blinded.
     
   Outputs:
   - s', octet string.
   - commitment, octet string
   
   Procedure:
   1. s' = H(PRF(8*ceil(log2(r)))) mod r
   2. commitment = h0 * s' + h_i * msg_i + ... + h_U * msg_U
   3. return s', commitment
     
2.10. BlindSign

   BlindSign generates a blind signature from a commitment received
   from a holder, known messages, a secret key, and generators from
   the corresponding public key.
   
   blind_signature = BlindSign(commitment, (msg_i,...msg_K), SK, h0,
   (h_i,...,h_K))
   
   Inputs:
   - commitment, octet string receive from the holder in output form
     from PreBlindSign
   - msg_i,...,msg_K, octet strings
   - SK, a secret key output from KeyGen
   - h0, octet string.
   - h_i,...,h_K, octet strings of generators for the known messages
   
   Outputs:
   - blind_signature, octet string
   
   Procedure:
   1. e = H(PRF(8*ceil(log2(r)))) mod r
   2. s'' = H(PRF(8*ceil(log2(r)))) mod r
   3. b = commitment + h0 * s'' + h_i * msg_i + ... + h_K * msg_K
   4. A = b * (1 / (SK + e))
   5. blind_signature = (A, e, s'')
   6. return blind_signature
   
2.11. UnblindSign

   UnblindSign computes the unblinded signature given a blind signature
   and the holder's blinding factor. It is advised to verify the
   signature after unblinding.
   
   signature = UnblindSign(blind_signature, s')
   
   Inputs:
   - s', octet string in output form from PreBlindSign
   - blind_signature, octet string in output form from BlindSign
   
   Outputs:
   - signature, octet string
   
   Procedure:
   1. (A, e, s'') = blind_signature
   2. s = s' + s''
   3. signature = (A, e, s)
   4. return signature
     
2.12. BlindMessagesProofGen

   BlindMessagesProofGen creates a proof of committed messages zero-
   knowledge proof. The proof should be verified before a signer
   computes a blind signature. The proof is created from a nonce
   given to the holder from the signer, a vector of messages, a
   blinding factor output from PreBlindSign, and generators from the
   signers public key.
   
   nizk = BlindMessagesProofGen(commitment, s', (msg_i,...,msg_U), h0,
   (h_i,...,h_U), nonce)
   
   Inputs:
   - commitment, octet string as output from PreBlindSign
   - s', octet string as output from PreBlindSign
   - msg_i,...,msg_U, octet strings of the messages to be blinded.
   - h0, octet string.
   - h_i,...,h_U, octet strings of generators for the messages to
     be blinded.
   - nonce, octet string.
     
   Outputs:
   - nizk, octet string
   
   Procedure:
   1. r~ = []
   2. s~ = H(PRF(8*ceil(log2(r)))) mod r
   3. for i in 0 to U:
         r~\[i\] = H(PRF(8*ceil(log2(r)))) mod r
   4. U~ = h0 * s~ + h_i * r~_i + ... + h_U * r~_U
   5. c = H(commitment || U~ || nonce)
   6. s^ = s~ + c * s'
   7. for i in 0 to U:
         r^\[i\] = r~\[i\] + c * msg_i
   8. nizk = (c, s^, r^)
     
2.13. BlindMessagesProofVerify

   BlindMessagesProofVerify checks whether a proof of committed messages
   zero-knowledge proof is valid.
   
   result = BlindMessagesProofVerify(commitment, nizk, nonce)
   
   Inputs:
   - commitment, octet string in output form from PreBlindSign
   - nizk, octet string in output form from BlindMessagesProofGen
   - nonce, octet string
   
   Outputs:
   - result, either VALID or INVALId.
   
   Procedure:
   1. (c, s^, r^) = nizk
   2. U^ = commitment * -c + h0 * s^ + h_i * r^_i + ... + h_U * r^_U
   3. c_v = H(U || U^ || nonce)
   4. return c == c_v
     
2.14. SpkGen
     
2.15. SpkVerify
