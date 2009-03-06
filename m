From: Andreas Dilger <adilger@sun.com>
Date: Fri, 06 Mar 2009 12:16:20 -0700
Subject: [Lustre-devel] layout lock / extent lock interaction
In-Reply-To: <49B16509.9000409@sun.com>
References: <20090130233253.GK3652@webber.adilger.int>
	<63CF2DAF-59F7-4124-8AE9-188927051AAB@sun.com>
	<C68908D1-8287-4870-903E-DDCDED6E31D0@Sun.COM>
	<5882C1BC-E01E-42FF-A728-08885E997075@sun.com>
	<20090221002109.GA3863@webber.adilger.int> <49B16509.9000409@sun.com>
Message-ID: <20090306191620.GB3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 06, 2009  10:01 -0800, Nathaniel Rutman wrote:
> I think we need to explicitly list the extent / layout lock interactions  
> so we don't miss anything in the implementation:
> 1. Create
>
>    * MDT generates new layout lock at open
>    * client gets Common Reader layout lock
>    * client can get new extents read/write locks as long it holds CR
>      layout lock
>
> 2. Layout change
>
>    * MDT takes PW layout lock, revoking all client CR locks
>    * in parallel, MDT takes PW lock on all extents on all OSTs for this
>      file
>    * Clients drop layout lock and requeue
>    * Clients flush cache and drop their extent locks
>    * MDT changes layout
>    * MDT releases layout lock and extents locks
>    * Clients get CR layout lock and can now requeue their extent locks
>
> 3. Client / MDT network partition
>
>    * client can continue reading/writing to currently held extents
>    * when client determines it has been disconnected from MDT it drops
>      layout lock
>    * client can't get new extent locks, but can continue writing to
>      currently held extents
>    * if MDT changes layout, it first PW locks all extents, causing OSTs
>      to revoke client's extents locks
>    * Client must requeue layout lock before requeueing extents locks
>
>    What if client hasn't noticed it's been disconnected from the MDT by
>    the time it tries to requeue extent locks?  It doesn't know that the
>    layout lock its holding is invalid...

That is a thorny problem.  I'll go through several partial solutions
and see why they do not work, then hopefully a safe solution at the end.

One possibility is that the AST sent to the clients during the extent lock
revocation would contain a flag that indicates "the layout is changing"
(similar to the truncate/discard data flag), so the clients get notified
even if disconnected from the MDS.  It still isn't enough, however,
as the clients will only get this AST if they currently have an extent
lock, and it isn't always true.

A second option is in case a client holding a layout lock is evicted AND
the layout is being changed then the MDS can't release the extent locks
until at least one ping interval (assuming any still-alive client would
have detected this and try reconnecting).  This is also not 100% safe because
the client might have been evicted moments earlier due to some other lock
and the "wait for one ping interval" heuristic would no longer apply.

We cannot depend on the layout change to be drastic and the objects would
no longer exist to be written to (CROW issues aside).  If we are changing
the layout to add a mirror that wouldn't help and we would now have
inconsistent data on each half of the mirror.

Another option is something like "imperative eviction" so that clients
being evicted are actively told they are being evicted, but that has
the issue of the "you are evicted" RPC will normally be sent to a node
which is already dead and slow down the MDS and/or block all of its
LNET credits so isn't really even a usable option.


A safe option (AFAICS) is to have MDS eviction force OST eviction (via
obd_set_info_async(EVICT_BY_NID).  That would also resolve some other
recovery problems, but might be overly drastic if e.g. the client is
being evicted from the MDS due to router failure or simple network
partition.  Having a proper health network and also server-side RPC
resending would help avoid such problems.

This is one of the main reasons why having DLM servers on one node
controlling resources on another node is a bad idea.  We had similar
issues in the past when we locked all objects via the OST only on
stripe index 0, and we might have similar problems with subtree locks
in the future with CMD or any SNS RAID that is only locking a subset
of objects.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
