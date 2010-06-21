From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 21 Jun 2010 08:34:15 -0600
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <201006210242.o5L2gcRM011040@hedwig.cmf.nrl.navy.mil>
References: <201006210242.o5L2gcRM011040@hedwig.cmf.nrl.navy.mil>
Message-ID: <B3476F3E-948A-4310-8AF9-4E420E5FE2E4@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 2010-06-20, at 20:42, Ken Hornstein <kenh@cmf.nrl.navy.mil> wrote:
> Now here's a thought: if I get a broken lock on a vnode, I can tell  
> the
> upper layer to invalidate the name->vnode mapping (can I do that?   
> Yes,
> it turns out I can).  That will mean lookup() will be called the  
> next time
> around.  I think in terms of RPC round-trip, a GETATTR is the same  
> as a
> LOOKUP, right?  It feels kinda wrong to do it that way, though.

This is in fact the right way to do it. If the lock is cancelledq then  
the client has no way of knowing whether that name will continue to  
point at the same FID or not.

Also note we recently changed the Linux client to invalidate the inode  
when all of the DLM locks related to that inode are cancelled.  This  
ensures the client 'forgets' about deleted inodes even when another  
client deleted it. Otherwise, the client will accumulate a lot of  
unnecessary inodes in cache.

Cheers, Andreas
