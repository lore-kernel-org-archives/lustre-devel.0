From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Wed, 03 Feb 2010 19:46:42 +0300
Subject: [Lustre-devel] SOM re-design, overview
Message-ID: <A2258830-1799-49C9-B1F5-97739051DD24@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I. Introduction.

SOM is split to several simple mechanisms: invalidation, revalidation,
llog cleanup.

1. Invalidation.

Once file is opened for modification, SOM cache is invalidated, this is
a modification of inode EA on MDS, not synchronous so we need to  
protect this
change against MDS failure -- IO to OST will create a llog record.

2. Revalidation.

The main idea is to re-use the basic getattr mechanism, client already  
gather
attributes from both MDS & OST and the only missed bit is to send  
attributes
back to MDS. However, it is done only if needed -- a client asks for  
file
attributes by itself and MDS decides it is time to rebuild the cache,  
tells
the client in reply to do it.

MDS has no in-core state while SOM revalidation, if client is evicted  
or so, there
is no problem as inode is not pinned in the memory. However, we still  
want to mark
this inode as "SOM rebuild is in progress" because we do not want to  
have many
clients performing SOM rebuild in parallel.

If MDS decides to rebuild the cache too early, OST must be able to  
detect it!
Once detected and reported to client in reply on glimpse, client just  
interrupts.

2.1. Revalidation time.

MDS is not notified when clients completes their writes (there is no  
DONE_WRITING
RPC nymore), and IOEpoch closes on file close. By that time clients  
may still have
dirty cache and we do not want to force client to flush it  
immediately, MDS just
waits for SOM_TIMEOUT before starting the revalidation.

SOM_TIMEOUT covers the time client will keep the data in cache, the  
flush and
commit on OST: SOM_TIMEOUT = CLIENT_FLUSH_TIMEOUT + OST_COMMIT_TIMEOUT

Revalidation is done when file is closed, so OST is able to detect the  
revalidation
is too early by existent extent lock or not committed data.

SOM_TIMEOUT may also reflect the MDS idea that we do not need clients  
cache
anymore, and OST will initiate lock cancel when get such a  
notification on glimpse.

2.2. Advantages

- no overhead for too early revalidation, no extra rpc;
- no overhead for revalidation, except the final md_setattr, which can  
be batched;
- no extra in-core state on MDS;
- no extra activity on client nor on MDS;

2.3. Disadvantages

- first client has no SOM cache benefits;

3. LLOG cleanup.

The main idea is to not rely on clients in propagating llog cookies  
from OST to
MDS, but sending them directly from OST to MDS. Indeed:
- client is not informing MDS about write completion and not having  
llog cookies
   by the time of close (although DONE_WRITING could do it);
- client may be evicted from MDS and we get llog record leackage --  
nobody will
   take care of it till the next modification;
- SOM cache revalidation is done on-demand so could be done much later;

OST sends llog records to MDS immediately once the transaction with  
this llog
record is committed, batched to save on the amount of RPC. Once SOM  
invalidation
committed, MDS sends llog cancel back, batched again.

IO comes to OST with IOEpoch# assigned, OST creates a llog record for  
this IOepoch and updates IOEpoch# in inode EA. IOEpoch# in EA tells  
next IO that
llog record for this IOEpoch is already created. LLOG record indicates  
SOM
cache on MDS for this IOEpoch needs to be invalidated -- once  
invalidation commits, llog record is not needed. This way OST has no  
in-core states.

Advantages:
- minimum RPC overhead, evrything is batched;
- quick LLOG cancel;
- no in-core states on OST.

II. Recovery.

1. Client eviction.

After eviction, client can proceeds with its IO to files MDS has  
closed on
eviction. This IO must be blocked right on client, until files are not  
re-opened,
otherwise we will not be able to rebuild SOM cache -- new IO will  
destroy it.

However, client get known about its eviction not immediately and even  
after
that it may already have some RPC in-fligth (it concerns lockless IO  
or extent
lock enqueue only, cached IO under already existent locks is allowed  
as can be
controlled by OST through these extent locks).

One of the possible solutions here is timeouts. MDS closes all the  
opened by the
evicted client files and therefore opened IOEpochs, since close, SOM  
cache cannot
be rebuild for SOM_RECOVERY_TIMEOUT which must ensure:
- the client knows it is evicted;
- the last client's RPC in-flight, sent before it has got known it is  
evicted
  from MDS, would either complete or would be blocked;

At the same time client may have a dirty data, so MDS needs to let it  
to flush
and commit on OST, thus MDS waits for
	SOM_TIMEOUT = max(SOM_RECOVERY_TIMEOUT, CLIENT_FLUSH_TIMEOUT)
                     + OST_COMMIT_TIMEOUT

If RPC in-flight comes to OST too late, client is already reconnected,  
OST
skips RPC from previous connections, but client resends it. This  
resend can
be blocked on the client (if the client detects it is evicted from MDS  
in the
meanwhile).

2. MDS failover.

MDS waits for SOM_TIMEOUT after the bootup before starting to rebuild  
SOM
cache globally. Reasons are the same as for client eviction, as some  
client
may be evicted over the failover as well; globally because MDS does  
not have
a list of files involved.

Of course, SOM is disabled for a file if some OST in its stripeset has  
not
synchronised LLOGs with MDS yet.

--
Vitaly
