From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 08 Jul 2009 10:46:54 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090707143819.GL5073@webber.adilger.int>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <20090706224203.GZ15302@Sun.COM>
	<4A531BE4.20207@sun.com> <20090707143819.GL5073@webber.adilger.int>
Message-ID: <4A5440DE.7020707@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
>> my old thougth was that instead of introducing special new open-by-fid RPC
>> we should try to implement open in terms of LDLM locks because it's in-core
>> state (though with specific tracking of unlinked files). given this we'd
>> automatically get single mechanism for all in-core states and we'd get rid
>> of special paths for open replays.
> 
> One problem with this is that the ordering needs to be preserved.  Opens
> that have committed need to be replayed before any other replay operations,
> because those replayed operations may depend on the file being open.
> However, "normal" lock replay should happen after (or conceivably during)
> operation replay so that the objects being locked actually exist and the
> server can (hopefully soon) verify the lock version number during recovery.

well, that ordering is already "dead" due to VBR?

I think semantics of unlink is just to unlink name, everything else is up to
MDS (when to destroy inode and objects). also notice inode destroy is a different
transaction in general (due to possible multi-transaction truncate).

if we decouple unlink and object destroy, then the following sequence should work:
1) replay on-disk states
    (unlink just put inode onto orphan list)
2) replay in-core states
    (including open locks)
... at some point
3) MDS goes over orphan list and destroys selected objects
    (depending on VRB policy, etc)

thanks, Alex
