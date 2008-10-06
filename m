From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 06 Oct 2008 19:55:48 +0400
Subject: [Lustre-devel] MDWBC and how much to trust clients
In-Reply-To: <1FEDA9D966B34039AF0EC15DBD0E4BAA@eblap>
References: <1FEDA9D966B34039AF0EC15DBD0E4BAA@eblap>
Message-ID: <18666.13572.686218.818001@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton writes:
 > Nikita,

Hello,

 > 
 > Do you agree that a buggy or malicious MDWBC could disrupt the
 > namespace (e.g. links to missing files, orphaned files) if
 > it splits up operations across multiple MDTs into sub-operations
 > for the individual targets?  I think it will be an issue for
 > security if we just trust the MDWBC to do such operations
 > correctly, and so I'm wondering how we can fix this.  

as Peter mentioned, we discussed this topic during the Moscow
meeting. If I am not mistaken, we converged to the idea that before
committing an epoch, every mdt composes some kind of a `summary',
containing enough information for verification of a global consistency,
and this summary is passed though every server as a ticket, with every
server `approving' some bits in the summary accumulated so far, and
adding new ones. For example, one server adds 

        (SETATTR: FID: fid1, UPDATE: nlink += 2) 

to the summary, then another server having 

        (LINK: PARENT_FID: fid2, NAME: "foo", CHILD_FID: fid1),

in its local epoch replaces UPDATE part of the SETATTR record above with
nlink += 1, and yet another server with

        (LINK: PARENT_FID: fid3, NAME: "bar", CHILD_FID: fid1),

can cancel SETATTR completely. Note, that LINK might cancel UNLINK or
RENAME as well as SETATTR. Global consistency is verified when all
summary records are similarly canceled. All this is still very vague to
me:

    - it is not clear how to start summary exchange (round robin
      perhaps, based on an epoch number)?

    - what state should be kept in a summary?

    - is it always possible to prove consistency in one cycle?

 > 
 > Using a master MDT to coordinate the operation across itself and
 > the remaining MDTs seems part of, but not all of the solution.
 > We have to process batches in bulk to retain a significant
 > performance advantage, so I wonder if that requires us to trust
 > that these batches have been created correctly.  
 > 
 > If so, we're stuck with the MDWBC being something we can only
 > do in a single trust domain - i.e. not across a WAN. That seems
 > unfortunate since WAN performance should be a major beneficiary
 > of the MDWBC.  Maybe in this case, we can still send batches over
 > the WAN, but to a single target which proxies for the remote client
 > and can be trusted to split multi-target ops over batches correctly.
 > 
 > Thoughts?
 > 
 >     Cheers,
 >               Eric

Nikita.
