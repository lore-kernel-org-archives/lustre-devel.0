From: Andreas Dilger <adilger@sun.com>
Date: Mon, 02 Jun 2008 17:24:33 -0600
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C4682B4E.5615%peter.braam@sun.com>
References: <20080528080613.GN3582@lore> <C4682B4E.5615%peter.braam@sun.com>
Message-ID: <20080602232433.GS2961@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 01, 2008  10:32 +0800, Peter J. Braam wrote:
> I am quite worried about the dynamic qunit patch.
> I am not convinced I want smaller qunits to stick around.
> 
> Please PROVE RIGOROUSLY that qunits are grow large quickly again, otherwise
> they create too much server - server overhead.  The cost of 100MB of disk
> space is barely more than a cent now; what are we trying to address withtiny
> qunits?
> 
> Plan for 5000 OSS servers at the minimum and 1,000,000 clients, and up to
> 100TB/sec in I/O.  Calculate quota RPC traffic from that.  A server cannot
> handle more than 15,000 RPC's / sec.
> 
> No arguing, or opinions here, numbers please.  The original design I did 4
> years ago limited quota calls from one OSS to the master to one per second.
> Qunits were made adaptive without solid reasoning or design.

Just a note - it isn't only shrinking of qunits that is possible, but also
growth of qunits.  I think there was also work done to allow recall of
qunits from the servers, but I'm not sure if it was landed into CVS.


If we are significantly re-architecting quotas, I'd suggest that we also
re-implement grants at the same time and use the DLM to do both of them.
This way we can have grant + quota on a per-file basis (quota + grant are
given to clients as part of extent lock LVB), and are also able to
recall quota + grant.  We may not even want to have separate quota+grant,
since we track the ownership of files on the OSTs and space allocation
is done on a per-file basis.

It would be possible, for example, to take a user's whole quota from
the master, split it evenly into "num_osts * 2" chunks at mount time
to pass to the OSTs, they further grant it to clients when they request
extent locks, and then avoid ALL master->OST quota RPCs unless that user
actually got close to exceeding their quota, either granting out some
of the remaining "num_osts" qunits or recalling some of the outstanding
quota (possibly via lock "conversion" to avoid revoking the quota lock).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
