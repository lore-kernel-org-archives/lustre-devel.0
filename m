From: Eric Barton <eeb@sun.com>
Date: Mon, 06 Oct 2008 03:53:26 +0100
Subject: [Lustre-devel] MDWBC and how much to trust clients
Message-ID: <1FEDA9D966B34039AF0EC15DBD0E4BAA@eblap>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita,

Do you agree that a buggy or malicious MDWBC could disrupt the
namespace (e.g. links to missing files, orphaned files) if
it splits up operations across multiple MDTs into sub-operations
for the individual targets?  I think it will be an issue for
security if we just trust the MDWBC to do such operations
correctly, and so I'm wondering how we can fix this.  

Using a master MDT to coordinate the operation across itself and
the remaining MDTs seems part of, but not all of the solution.
We have to process batches in bulk to retain a significant
performance advantage, so I wonder if that requires us to trust
that these batches have been created correctly.  

If so, we're stuck with the MDWBC being something we can only
do in a single trust domain - i.e. not across a WAN. That seems
unfortunate since WAN performance should be a major beneficiary
of the MDWBC.  Maybe in this case, we can still send batches over
the WAN, but to a single target which proxies for the remote client
and can be trusted to split multi-target ops over batches correctly.

Thoughts?

    Cheers,
              Eric
