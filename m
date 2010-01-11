From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Tue, 12 Jan 2010 00:41:29 +0300
Subject: [Lustre-devel] SOM safety
In-Reply-To: <079601ca8e36$70c5f480$5251dd80$@com>
References: <079601ca8e36$70c5f480$5251dd80$@com>
Message-ID: <9015F026-CB34-4310-B7D4-0D9716FDD049@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 5, 2010, at 9:39 PM, Eric Barton wrote:

> Some thoughts on SOM safety...
>
> The MDS must guarantee that any SOM attributes it provides to its
> clients are valid at the moment they are requested - i.e. that no file
> stripes were updated while the SOM attributes were computed and
> cached.  This guarantee must hold in the presence of all possible
> failures.
>
> Clients notify the MDS before they could possibly update any stripe of
> a file (e.g. on OPEN) so that the MDS can invalidate any cached SOM
> attributes.  Clients also notify the MDS with "done writing" when all
> their stripe updates have committed so that the MDS can determine when
> it may resume caching SOM attributes.
>
> This protocol breaks down when the MDS evicts a client which is
> updating files.  The client may not be aware of the eviction and can
> continue to update the file's stripes.  Since it is not safe to cache
> SOM attributes for this file again until we can guarantee that all
> stripe updates by the evicted client have ceased, we must...
>
> R1: Invalidate SOM attributes cached on the MDS
>
> and/or
>
> R2: Prevent further stripe updates by the evicted client
>
> ...until the client has reconnected to the MDS and the protocol is
> back in synch.
>
> R3: R1 and R2 must hold irrespective of any server (MDS or OSS) crash
>    or restart.
>
> The following requirements are also needed for performance...
>
> R4. The MDS must avoid doing a synchronous disk I/O when receiving
>    notification of possible stripe updates.
>
> R5. O(# files * # clients) persistent state must be avoided (e.g. it's
>    not OK to keep a persistent list of open files for each client).
>
> This means the MDS can't track which files are vulnerable to stripe
> updates if it crashes and then restarts or fails over.  A client that
> had files open for update before the crash could fail to reconnect,
> and since the OST logs only tell the MDS which files have been updated
> already, files previously opened for update but not yet actually
> updated by this client are not accounted.
>
> Therefore without (R2), SOM attribute caching cannot be re-enabled for
> _any_ files on a restarted MDS while any clients remain evicted.
>
> Here are some alternative proposals to implement (R2)...
>
> 1. Timeouts
>
>   A timeout can be use to guarantee (R2) by ensuring clients discover
>   they have been evicted by the MDS and cease updates within a
>   bounded interval.  This relies on...
>
>   a. Clients and the MDS agree on the timeout.
>
>   b. Clients detect they have been evicted by the MDS and stop
>      sending stripe updates to any OST until the they have
>      reconnected to the MDS.
>
>   Note...
>
>   1. Configuration errors could invalidate the timeout agreement
>      unless it is confirmed by explicit message passing.
>
>   2. Guaranteeing all in-flight stripe updates have completed within
>      the timeout is tricky.  It requires a maximum latency bound
>      either from LNET or ptlrpc.

it requires a time synchronisation between nodes to check RPC has been
too long in-flight, this is not mandatory yet AFAIK and it looks pure
controllable...

>   3. Clients will have to ping the MDS regularly in the absence of
>      other traffic to bound the time it takes to detect eviction.
>      Shorter timeouts will lead to shorter ping intervals and a
>      corresponding increase in MDS load.
>
>   4. On startup, the MDS cannot enable SOM attributes until the
>      timeout has expired to ensure all clients have detected the
>      restart.
>
>   5. A buggy or malicious client can disregard the timeout.
>
> 2. OST eviction
>
>   An alternative to timeouts is to evict clients from the OSTs when
>   they are evicted from the MDS.  This prevents clients from
>   performing further stripe updates after eviction from the MDS and
>   notifies them to reconnect.
>
>   Note however that this requires client connection/eviction to
>   proceed in lockstep across all servers to ensure that stripe
>   updates arriving at any OST were sent in the context of the current
>   client/MDS connection and not an earlier one.
>
> 3. Ordered Keys
>
>   Using ordered keys to verify stripe updates eliminates the lockstep
>   requirement on OST eviction.  The MDS and OSTs maintain a key for
>   every client which uniquely identifies a particular client/MDS
>   connection instance and can be compared with other keys for the
>   same client/MDS connection to determine which one is older.
>   Clients receive this key when they connect to the MDS and pass it
>   on every stripe update.  OSTs check the key and reject updates with
>   an "old" key, which forces the client to reconnect to the MDS to
>   obtain a new key.
>
>   Note...
>
>   1. The only requirement on keys is that they increase monotonically
>      for a given client.  The same key can be in use by many
>      different clients so a single clock could be used to generate
>      keys for all clients provided it never goes backwards
>      (persistently) and an individual client is not permitted to
>      reconnect before the clock ticks.
>
>   2. When a client is evicted, the MDS must continue to disable SOM
>      attribute caching for the client's writeable files until the new
>      key has been sent to all OSTs backing those files.  This can be
>      done individually for each file.
>
>      Clients may reconnect and continue with stripe updates before
>      all OSTs have received their new key since OSTs only reject old
>      keys.  This allows OST notification to be relatively lazy -
>      i.e. the MDS can buffer pending client/key updates for all OSTs
>      and send them periodically.  Increasing this period only
>      increases the time that SOM attribute caching must remain
>      disabled for affected files.
>
>   3. When the MDS restarts or fails over, it must resynchronise with
>      all OSTs - i.e.  install keys to limit stripe updates to
>      actively connected clients and read the OST logs to discover
>      files that were updated without persistently invalidating SOM
>      attributes cached on the MDS.  Since it only needs a single key
>      for all clients at this time, resynchronisation should be cheap.
>
>   4. When an OST restarts or fails over, it must recover its
>      client/key state from the MDS before it can continue with normal
>      operation to ensure that it continues to reject stripe updates
>      that the MDS had already disabled with the previous OST
>      instance.  For a long-running MDS, this client/key state could
>      be 1 key for every client which might best be sent as bulk data.
>
>      Alternatively, key state could be stored persistently on the
>      OST so that recovery could use existing code to replay
>      uncommitted key updates from the MDS.

we will need to give OST fresh identifiers because OST could be down
long enough and they have succeeded to change.

>      It seems safe to allow client replay to proceed concurrently
>      with key state recovery since clients should only replay updates
>      that were not rejected the first time round.  Also the MDS knows
>      which files are volatile through an OST restart if clients only
>      send "done writing" when all updates have committed.

another possibility is not to try to get a common solution for MDS  
failover
and client eviction if it becomes complex but instead to get 2 separate
simple solutions for them. thus for MDS failover it could be as simple  
as:

1.1. you described in ordered keys;
1.2. I described in SC09 persentation with IOEpoch delimiter;
1.3. it could be just an MDS mountid;

this unique identifier is propagated to OST on MDS-OST synchronisation  
and
OST compares it with id packed into IO from clients;

for client eviction it could be resolved through incrementing some per- 
file
identified in OST objects, stored in EA; it could be:

2.1 IOEpoch, MDS can send notifications to OST in stripeset by itself
(batched to save on RPC amount); we will have:
- extra load for MDS, but in client eviction case only;
- extra write on OST, but in client eviction case only;
- extra RPC between MDS & OST, could be batched so not a problem;
- separate mechanisms for MDS failover & client eviction;

2.2 IOEpoch, client may do it for us on obd_getattr when MDS asks it  
to rebuild
the cache, client will have to wait until IOEpoch will commit to EA  
and send
setattr to MDS (batched to save on RPC amount); we will have:
- extra write on OST, but in client eviction case only;
- extra RPC between client & MDS, could be batched so not a problem;
- separate mechanisms for MDS failover & client eviction;
+ client anyway need to gather attributes and merge them, it is natural
   solution to send them to MDS as well;

Note: this could be a common solution for MDS failover as well, but  
there
will be no way to distinguish between SOM-disabled and SOM-recovery  
inodes,
i.e. for each inode with disabled SOM we will propagate IOEpoch to OST  
on
getattr and write it to EA, in this case:
- extra write on OST, 1 per file stripe; does it look dangerous?
- extra RPC between client & MDS, could be batched so not a problem;
+ common mechanisms for MDS failover & client eviction;
+ client anyway need to gather attributes and merge them, it is natural
   solution to send them to MDS as well;

2.3. Layout generation
Can we re-use Layout Lock mechanism here, blocking IO from previous  
generations?
If so, this way seems cheap.
- extra load for MDS, but in client eviction case only;
- extra write on OST, but in client eviction case only;
- extra RPC between MDS & OST, could be batched so not a problem;
+ common solution for layout lock & client eviction;
+ layout lock is done for HSM so it is cheapest solution, isn't it?

2.4. Client-MDS connection ID (suggested above by Eric)
- extra load for MDS, but in client eviction and OST failover cases  
only;
- extra RPC between MDS & OST, could be batched so not a problem;
+ common mechanisms for MDS failover & client eviction;

--
Vitaly
