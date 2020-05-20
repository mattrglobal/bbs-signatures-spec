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
     
   * L: The total number of messages that the signature scheme 
     can sign.
     
   * m_i: Message at index i.
   
   * signature: The digital signature output.
