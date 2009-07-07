From: Andreas Dilger <adilger@sun.com>
Date: Tue, 07 Jul 2009 08:38:19 -0600
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <4A531BE4.20207@sun.com>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <20090706224203.GZ15302@Sun.COM>
	<4A531BE4.20207@sun.com>
Message-ID: <20090707143819.GL5073@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 07, 2009  13:56 +0400, Alex Zhuravlev wrote:
> Nicolas Williams wrote:
> > Also, as Oleg explained to me, most open state is for files whose opens
> > committed long ago, so most open state is recovered before other
> > transactions.  Which means we already have a separate open state
> > recovery phase -- it just isn't explicit.  So the only thing that
> > changes in my proposal is that all committed open state will be
> > recovered by anonymous open by FID reconstruction instead of by replay,
> > with all other transactions (including as-yet uncommitted opens) will be
> > recovered by replay.
> 
> I think it'd be slightly easier to introduce two notions of replay:
> 
> 1) on-disk replay -- we try to recover some on-disk state from client's cache
>     regular requests like mkdir, unlink, rename, setattr, etc
> 
> 2) in-core replay - we try to recover some in-core state from client's cache
>     ldlm locks, open files
> 
> the thing is that open(2) is quite interesting in this regard because it does
> (1) *and* (2). I believe this is why we used (1) for (2).
> 
> my old thougth was that instead of introducing special new open-by-fid RPC
> we should try to implement open in terms of LDLM locks because it's in-core
> state (though with specific tracking of unlinked files). given this we'd
> automatically get single mechanism for all in-core states and we'd get rid
> of special paths for open replays.

One problem with this is that the ordering needs to be preserved.  Opens
that have committed need to be replayed before any other replay operations,
because those replayed operations may depend on the file being open.
However, "normal" lock replay should happen after (or conceivably during)
operation replay so that the objects being locked actually exist and the
server can (hopefully soon) verify the lock version number during recovery.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
