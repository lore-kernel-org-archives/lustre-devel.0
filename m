From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Sun, 20 Jun 2010 22:42:34 -0400
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <A7BFC57F-AB97-41F2-95A8-B867E89C4875@oracle.com>
Message-ID: <201006210242.o5L2gcRM011040@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>sorry for the delay in replying, this mail disappeared off the top of my
>inbox.

Understood; I've been caught up in other things as well.

>The "intent" part of the locking is that the client is trying to
>write-lock the directory with the intent looking up the file to
>open+create it.  In all cases today the MDS does not grant the write
>lock on the directory, and replies to the client essentially "you can't
>have the directory lock, but I opened/created the file for you, and here
>are the attributes".

Ah, okay understood (I know you have explained this before; it's all coming
back now).

>But this question was never answered, and the patch was landed.  To my
>reading, the lack of ATTRFID support would prevent attribute caching on
>clients connected to 2.x servers once they lose their lock - they will
>repeatedly to MDS_GETATTR RPCs and never be able to cache them.

Ah-HA!  Well, that's sorta what I had thought, and I figured that wasn't
right.  But I'm glad to see at least that we agree on thatpart :-/

>It is a serious defect to LBUG() on the server due to bad client
>data/request.  Could you please file a bug on that?

Sure, will do.

>I think that is fixing the symptom and not the cause.  I'm not sure why
>we need the parent FID to get a lock on the child by itself, but even
>the client can't be 100% sure that it will have the parent.  For
>example, if the Lustre client is re-exporting the filesystem via NFS,
>then it has crashed and lost the in-memory directory hierarchy, and then
>gets a revalidation/getattr request from its NFS client without the
>parent it won't have the parent directory.  IIRC, this is the original
>reason we added ATTRFID support, was for NFS to be able to cache
>attributes for such inodes.

Ahhh ... okay.  From my reading of the code, the parent directory is locked,
but then released.  Again, I'm not sure why that happens ... the code there
is a bit hairy to my eyes.

>Well, it should do a getattr-by-FID and re-fetch the lock, which is
>exactly what happens with 1.6/1.8 servers.  I wonder if we even have a
>test workload that would expose this difference, since many tests like
>"ls -l" will always do a stat(filename), and I suspect very few tests
>will keep a filehandle open and do fstat(fd) for a long enough time for
>the client to lose its lock on the inode.

Well, I guess the question is ... does a "ls -l" involve doing a
new LOOKUP on Linux?.  I was kinda hoping to avoid that on the
Lustre client; the name-to-vnode mapping is controlled by the layer
above me in vnode filesystems.  Obviously I provide my own lookup()
routine to perform that mapping, but once that is done I tell the
upper layer about the name->vnode and it is cached, and obviously
I want that caching to stick around to avoid LOOKUP rpcs.

Now here's a thought: if I get a broken lock on a vnode, I can tell the
upper layer to invalidate the name->vnode mapping (can I do that?  Yes,
it turns out I can).  That will mean lookup() will be called the next time
around.  I think in terms of RPC round-trip, a GETATTR is the same as a
LOOKUP, right?  It feels kinda wrong to do it that way, though.

--Ken
