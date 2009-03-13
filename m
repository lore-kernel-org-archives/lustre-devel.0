From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Fri, 13 Mar 2009 18:32:00 +0300
Subject: [Lustre-devel] SOM Recovery of open files
Message-ID: <C7C2EDB9-409A-4BEA-9C9E-5A9CC3927653@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

this is the summary of our following discussion with Andreas from Feb24,
it includes the problem use cases of SOM recovery and interoperability,
describes problems of each use case and suggests possible solutions.

UseCase1. Client is evicted from MDS and re-connects.
UseCase2. MDS failover.
UseCase3. Client eviction and following MDS failover.

Problem1 File opened for write is not re-opened;
Problem2. File opened (precisely, with IOEpoch opened) for truncate is  
not re-opened;
Problem3. Client is able to write (new syscall) to a not re-opened file
(MDS has no control over IO happened in the cluster).
Problem4. Client is able to flush dirty data to OST for a not re- 
opened file.
Problem5. Client is able to re-send a write RPC to OST for a not re- 
opened file.

Solution1: New OPEN rpc on recovery.
Problem1.1: does not work for client eviction so far, when no MDS  
recovery is involved.
Problem1.2. even if recovery is involved but the client is already  
evicted, it does not work.
Problem1.2: does not work for truncate. The situation is pretty rare  
as client does not
cache punches, but what if at the time of the client eviction from  
MDS, the connection
between this client and an OST is unstable so that punches will hang  
in the re-send list
for a while, enough for another client to modify the file -- MDS gets  
a new SOM cache,
and later punch will modify the file.

Solution2: LOV EA lock, client blocks new IO if absent.
Problem2.1: LOV EA works for new syscalls only, not for  
(Problem4,Problem5).

Solution3: SOM cache is removed upon client eviction for all the  
opened IOEpochs
Problem3.1. works until SOM cache is re-validated before some later  
IO  happens
from a lost client.

Solution4: client's dirty cache is controlled from OST through extent  
locks.
MDS removes SOM cache for inode on client eviction, next file writer  
sees there is no
cache on MDS upon file open, thus the cache is re-obtained under  
[0;EOF] extent lock,
what flushes all the data on OST.
Problem4.1: Lockless IO (write,truncate) is not handled this way. rpc  
may be sitting in
the re-send list enough for another client to modify the file, SOM  
cache is re-obtained
to MDS, and delayed write/punch makes it invalid.
Problem4.2: Locked truncate is not handled this way. Enqueue may be  
sitting in re-send
list similar to 4.1.

Solution5: Cluster flush on MDS-OST synchronization.
SOM is disabled for a file until all the OSTs from its stripe are  
synchronized with MDS;
Synchronization includes: all the clients flushes their dirty cache to  
OST, llog cookie is
sent to MDS, MDS removes SOM cache for files involved. It means, a new  
IOEpoch opens
but cache is not re-validated at the end; getattr does not obtain SOM  
cache.
Problem5.1. Lockless IO (write,truncate) is not handled this way.
Problem5.2. Locked truncate is not handled this way (see Problem4.2)

UseCase4. Upgrade to SOM-enabled Lustre.
All the above problems exists.

Problem6. No IOEpoch has been opened (however, the SOM cache is  
removed synchronously
on open) truncate does not close "opened" file at all, i.e. MDS has no  
control over IO happened
in the cluster and later punch may destroy the SOM cache on MDS.

Solution6. Send done_writing even if SOM is disabled.

UseCase5. MDS fails over, a client has dirty cache but does not  
participate in the recovery.

Solution7. Invalidate SOM cache on MDS on close.
I.e. instead of blocking IO on the client, remove SOM cache in advance.
Problem7.1. the solution does not work, thus we cannot depend on  
client as it may be evicted
(UseCase5) if close is not committed yet, lockless IO still may happen  
with a delay..

Solution8. Evict client from OST once client is evicted from MDS (via  
MDS->OSS connection and
set_info(KEY_EVICT_BY_NID)). Or cancel this client extent locks only.  
Therefore, prevent any IO
happen since then.
Problem8.1. if 2 mds failovers happen right one after another, it  
seems mds is already not able to tell
which clients are lost over failover -- after the first failover it  
lets the clients to re-connect and
overwrites the previous info about connected clients but does not  
succeeds to tell ost to evict
the client -- and here the 2nd mds failure happens.
This solution could be probably done in some different way -- (a)  
client itself informs OST it is
evicted; (b) MDS provides the full list of connected clients to OST on  
boot and then informs OSTs
about client evictions;

Solution9. Invalidate SOM cache on open for write.
Problem1. Unless written synchronously, MDS may fail before open gets  
committed.
Problem2. Even if committed, a new IOEPOCH may re-validate SOM cache  
which could become
wrong due to a later lockless IO reached OST or a such.

Still missed solutions:
(*) block truncate and lockless IO (either it is a new syscall, an  
enqueue rpc is in re-send
list; lockless IO (write,truncate) is in the re-send list) until the  
connection to MDS is restored.
Problem: a possible race between time MDS restarts and client detects  
it is evicted. I.e. client
may continue to send IO to OST but it must detect the time (and block  
its IO until file is re-opened)
when MDS is up, MDS-OST synchronization is completed;

Solution10. Cause the OST to get an ioepoch for the file and  
invalidate the SOM cache on the
MDS by itself BEFORE allowing the lockless operation to complete.

Solution11. Client could wait for an open+SOM invalidate to commit  
before sending the lockless
operation.

Solution12. OST may send a new RPC to all the clients once MDS-OST  
synchronization starts.
Clients re-validate its connection to MDS and re-opens files on MDS is  
so, client blocks its IO
to OST until done. If client re-connects to OST, it must re-validate  
MDS connection as well
right before that.

--
Vitaly
