From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Thu, 2 Jul 2009 17:39:45 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
Message-ID: <20090702223944.GR15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We're working on adding replay RPC signatures, so that clients may only
replay RPCs that have been seen by the server (thus signed).

Currently clients recover open file state by replaying the open RPCs.
Because files can stay open forever this means that replay RPC
signatures must either remain valid forever (keys never deleted) or be
renewed.  But if we add a PTLRPC replay signature renewal feature then
we'll be causing MDSes to do redundant work (since FID capabilities used
in opens will also have to be renewed).

Since MDSes are typically CPU-bound as it is, adding a yet another
cryptographic burden to them seems undesirable.  Therefore a way to
recover open state that does not depend on replaying RPCs with valid
replay signatures is appealing.

I've been researching this (and talking to Eric B. and Oleg about this).
Several possible solutions are evident.  I'll describe the one that
seems most elegant to me (and, I think, Oleg), namely separate open
state recovery from transaction recovery.

Server-side high-level description:

 - during recovery the MDS will first process anonymous open by FID RPCs
   from new clients (these open RPCs will not have transaction IDs
   assigned to them as they imply no actual transactions)

 - then the MDS will accept replays from all clients, new and old

 - followed by lock recovery as usual

Client-side high-level description:

 - open processing will begin by sending an RPC as usual...,
 
 - ... but on commit the md_open_data will be added to a doubly-linked
   list of opens and the RPC will be removed from the PTLRPC replay
   queue

 - during recovery the client will begin by traversing the list of
   md_open_data (open state), reconstruct an anonymous open by FID RPC
   and send it to the MDS, and after that the client will replay
   outstanding transactions' RPCs, followed by lock recovery

Old clients would recover as usual.

Security is provided by the capabilities used in the anonymous open by
FID RPCs and transport security.

The general principle then would be:

   RPC replaying is to be used only for recovering _transactions that
   should not be outstanding for very long.

Where "very long" is relative to the replay signature crypto key
lifecycle, which will be on the order of days.

Since opens are not transactions[*] and can stay "outstanding" forever,
opens would not be suitable for recovery by replay under that principle.
Open state is much more similar to DLM locks than transactions.

Open recovery must precede uncommitted transaction recovery so as to
ensure that open state is re-established before unlinks can be replayed
that would cause the file to be destroyed.

There are, of course, other ways to achieve the desired effect, that is,
to avoid having to renew replay signatures.

Comments?  Advice?

Nico

[*] Any filesystem object creation implied by an open, such as when
    O_CREAT is used, would be a transaction, but the open aspect of it
    wouldn't be.  Think of an open that creates as a filesystem
    transaction and an open that happen atomically.
