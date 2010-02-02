From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Tue, 02 Feb 2010 21:22:04 +0300
Subject: [Lustre-devel] SOM discussion, write-up
Message-ID: <1C2080C0-9CF8-41B3-BAB2-F430DCE9BF7F@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

some results from our last talks with Eric and bzzz about SOM which
intend to resolve the recovery issues describied in the thread "SOM
safety" and previously in "SOM recovery of opened files", and some
simplifications.

(I) SOM recovery issues, blocking IO on OST

1. Problem description.

As a reminder, there are the following problems:

- client eviction from MDS, client is not aware about this
   eviction and is continuing with its IO;

- MDS failover may also include a client eviction, but in this
   case MDS even does not know the list of files involved;

- RPC could be in-flight long enough after client figured out
   it is evicted from MDS and we must ensure SOM cache on MDS
   does not get invalid if we apply this IO (it mostly concerns
   lockless IO, as locked IO is controled on OST through extent
   locks);

due to the last issue the right way seems to move the whole handling
to OST side, and OST needs to block new IO for files closed on MDS.

"new" means that IO cached under extent locks is allowed, but lockless
IO and extent lock enqueue are not;

2. Solution

"SOM safety" thread describes some solutions for this issue.
the simplest way from the described seems to be "timeouts".

2.1. eviction from MDS;

- SOM cache is invalidated on-disk for files opened by this client;

- SOM cache is not rebuilt for these files for SOM_RECOVERY_TIMEOUT:
   (a) which is long enough to ensure the client knows it is evicted;
   (b) and long enough to ensure the last RPC sent from client, before
   it has got known it is evicted from MDS, would either complete or
   would be blocked by OST according to the "Implementation" section;

- client blocks new IO to previously opened files, once it understands
   it is evicted, even after re-connection; application gets EIO and has
   to re-open files by itself;

   note: alternatively (or probably for a future optimisation) client
   re-opens files by itself after re-connection silently for the
   application, if it will be considered as not acceptable to force
   application to do it by itself;

2.2. MDS failover;

MDS waits for SOM_RECOVERY_TIMEOUT after the bootup before starting
to rebuild SOM cache globally. Reasons are the same as for client  
eviction, globally because MDS does not have a list of files involved.

3. Implementation

The problem with timeout solution is that some RPC can come to OST
much later and OST must be able to ignore it.

3.1. Skip too old RPC;

Make the time synchronised between nodes, once OST gets too old RPC
it just ignores it -- client will re-send it anyway.

Resend must be controlled -- lockless RPC and lock exqueue for not
re-opened files must have the time of the original request to become
"too old" for OST.

3.2. Skip RPC by its deadline;

Eric suggests not to synchronize time between all the nodes,
but get the server time in RPC replies and calculate the client
"idea" about the server time. It does not have to be accurate but
the largest possible. Every time sending RPC to this server client
puts the deadline time to this RPC, client's "idea" about the server
time + rpc timeout. The server skips all the RPC beyond the deadline.

Resend must be controlled as well.

3.3. Another way is to rely on our current timeout mechanism:

- if client has no reply from a server within obd_timeout,
   it reconnects;

- if server has no RPC from a client, it evicts this client;
   client will have to re-connect;

- if server gets RPC from previous connection, RPC is ignored;
   client will re-send it anyway;

- after reconnection client resends RPC;
   it must be blocked by client if it has been evicted from MDS and
   the file is not re-opened;

3.4. Timeout agreement.

Due to misconfigurations or errors, nodes may have different timeout
settings, but for SOM purposes it is enough to use the largest possible
timeout.

Although it does not protect us from malicious clients.

(II) SOM revalidation.

SOM cache cannot be rebuilt at once by the client which modifies the
file, due to asynchronous commits on OST, i_blocks are known later
then WRITE RPC reply is sent, so client does not know i_blocks by
DONE_WRITING time.

One of the solutions here is to separate SOM invalidation and SOM
revalidation mechanisms and to revalidate when data are already
committed and SOM cache is actually needed -- a client gets MDS &
OST attributes and is able to send them to MDS:

- SOM cache is not rebuilt for OST_COMMIT_TIMEOUT after IOEpoch close
   time, which is long enough to let OST to commit written data;

- MDS notifies the client SOM cache could be rebuilt in reply to
   md_getattr (once OST_COMMIT_TIMEOUT passed); MDS generates new IOEp#
   for this rebuilt packing it to the reply to the client as well;

   Note: it seems enough to send the last generated IOEp#.

- MDS does not have in-core inode state while waiting for SOM
   revalidation so if it will be interrupted (client eviction or
   a such) there is no problem;

   Note: we still need to mark inode as "SOM rebuild in progress" to
   not ask many clients in parallel to rebuild it, but it does not mean
   we need to pin inode in memory.

- client gather attributes from OST and OST checks
   (a) if it has no extent locks and
   (b) if all the changes to this object are committed;
   OST notifies the client in reply the object state is stable;

- client sends md_setattr with OST attributes if all the file objects
   are stable; otherwise, SOM revalidation is interrupted, client does
   not have to send anything;

- MDS applies attributes if no NEW IOEpoch has been opened on this
   file, it checks it by the IOEp# client sents in md_setattr;

- Client eviction
   SOM cache is not revalidated for SOM_RECOVERY_TIMEOUT as was shown
   above, however by that time data may be still cached on the client,
   thus to let clients to flush and commit, MDS waits for
	SOM_TIMEOUT = max(SOM_RECOVERY_TIMEOUT, CLIENT_FLUSH_TIMEOUT)
                       + OST_COMMIT_TIMEOUT
   for involved files.

- MDS failover, similar to client eviction, but globally;

(III) DONE_WRITING RPC.

As we do not want to revalidate the SOM cache immediately after the
file modification, there is a thought IOEpoch may close on file close,
not waiting for the cached data flush to OST, and therefore there is
no need in DW RPC.

1. Let's compare.
1.1. How DW is used, addressing "SOM revalidation" section thoughts:

- DW informs MDS IOEpoch is closed on the client and MDS can start
   cache revalidation immediately (once IOEp is closed on all the
   clients for the file);

- client still gathers llog cookies and send them in DW RPC
   (not attributes due to the problem described in "SOM revalidation"
   section); MDS invalidates SOM cache if it gets a llog cookie;
   once committed, llog cancel is sent to OST;

   Note: as SOM revalidation happens much later than file modification,
   we cannot keep llog records on OST for so long anymore, remember
   that it is not only a disk usage but an in-core state of OST inode.
   So we send it immediately on DW;

- client eviction: no llog cookies, resulting in a temporary llog
   record leakage, which is resolved on next file modification;

- MDS failover: all the llogs are read and handled by MDS, llog
   cancels are sent to OST and canceled there; llog leackage is
   eliminated as well;

Disadvantages:

- it is not possible to save on amount of RPC by sending attributes
   in DW due to i_blocks problem, so there will be a separate SOM
   revalidation anyway; DW only point the time we can start SOM
   revalidation, but immediate revalidation requires extra activity,
   either MDS does it by itself or asks a client to do it;
   besides that DW is 1 extra rpc per file as well;

- temporary llog record leackage may become a problem resulting
   in OOM, because each record has inode in-core state;

1.2. How it will work without DW, with new IOEpoch notion:

- MDS invalidates SOM cache on-disk on close RPC;

   Note: it could be invalidated on open, but close is better as
   it lets us to make a useful optimisation to not invalidate SOM
   cache if file has not been modified.

- IO from previous IOEpoch can come to OST but only under extent lock,
   therefore OST has a control over such IO;

- MDS does not start SOM revalidation after the file is closed for
   CLIENT_FLUSH_TIMEOUT + OST_COMMIT_TIMEOUT, it lets clients to flush
   their data to OST and OST to commit it; if not flushed & committed
   by that time, OST will detect it and SOM will not be revalidated;
   however, there is no overhead as client sends glimpse to OST anyway;

   This timeout may also include our expectation if this file will be
   modified anyhow soon and do not revalidate if we think so, e.g. if
   file has not been modified within 1h it will not be modified soon
   and we can revalidate the cache.

- OST-driven SOM-cache invalidation;
   LLOG records on OST cannot wait for SOM revalidation as shown above,
   but there is no DW, so client does not send llog cookies to MDS
   anymore. A possible solution is to send llog records directly from
   OST to MDS:
   - new IO creates a llog record on OST;
   - once committed, OST sends llog record to MDS;
   - MDS invalidates SOM cache on file specified by llog record;
   - once committed, MDS sends llog cancel back to OST;
   - OST cancel llog record and stored IOEp to inode EA;
   - OST gets IO from the same or smaller IOEp, no llog record is
     created as EA states SOM cache is already invalidated on MDS
     for such IOEp;

   Note: llog records are always batched to save on amount of RPC;

- Client eviction after close
   the file is closed but dirty cache may still exists, no new IO may
   happen, and OST has a full control over cached IO through extent
   locks, thus there is no need to wait for SOM_RECOVERY_TIMEOUT here.
   MDS is waiting for CLIENT_FLUSH_TIMEOUT + OST_COMMIT_TIMEOUT to let
   client to flush&commit and it is enough;

- MDS failover after close
   MDS completely relied on MDS-OST synchronisation here, ignoring DW
   replays anyway, so it is left the same -- client eviction timeouts
   but globally;

Advantages:

- client needs to send glimpse to OST anyway, so the only overhead
   is the final md_setattr, it can be batched to save on amount of RPC;

- OST sends llog records to MDS by itself, so there is no llog
   leackage anymore;

- a possible optimisation: this approach lets us to inform OST on
   glimpse that file is not opened on MDS and MDS thinks it will not
   be modified soon. Therefore, there is no need in dirty cache on
   clients anymore and we can initiate lock cancel for these files.

2. Implementation.

To detect it is time to revalidate SOM cache on MDS, it is probably
enough to store timestamp of close on disk in EA along with other SOM
attributes and therefore we do not need to have in-core state, we just
check this timestamp on each getattr.

(IV) IOEpoch number.

Another question is if we need a separate IOEpoch# generator or
we could re-use VBR number or transaction id.

1. Requirements:

- IOEpoch# is increased for new IOEpochs;

- SOM invalidation can be applied with larger IOEpoch#;
   it must be re-invalidated again for the last generated #,
   otherwise a later revalidation with smaller IOEpoch# would be
   applied; invalidation IOEpoch# is stored on disk as well;

- SOM revalidation can be applied to invalidated cache only and with
   not smaller IOEpoch#;

- IOEpoch# does not need to be re-generated on replay for now;

- MDS needs to understand which IOEpoch# it can generate after reboot
   for new opens; MDS must be able to understand it with some absent OST
   or client nodes; we support currently a separate "IOEpoch window"
   mechanism for this;

Let's consider we are going to use transno for this:

- MDS gives clients the current transno as IOEpoch# on open RPCs and
   increments transno correspondingly;

- once file is closed by all the clients, SOM cache is invalidated
   on disk for this file for the opened IOEpoch#;

- transno is already made safe agast node failures, it cannot become
   smaller so MDS will be able to generate new ones;

- MDS gives clients the current transno on md_getattr RPC if it thinks
   it is time for SOM cache revalidation;

- MDS stores attributes for the given by client IOEpoch# if file is not
   already invalidated with a larger IOEp#;

--
Vitaly
