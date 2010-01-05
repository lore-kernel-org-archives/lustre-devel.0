From: Andreas Dilger <adilger@sun.com>
Date: Tue, 05 Jan 2010 14:50:51 -0700
Subject: [Lustre-devel] SOM safety
In-Reply-To: <079601ca8e36$70c5f480$5251dd80$@com>
References: <079601ca8e36$70c5f480$5251dd80$@com>
Message-ID: <FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-01-05, at 11:39, Eric Barton wrote:
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

This brings up an interesting question.  When the client does a lookup  
on a file, or first opens it, the client gets the cached size from the  
MDS (assuming SOM cache is valid).  However, after this initial  
update, what guarantee does the client have that the size is still  
valid?  Must it do further MDS getattr or OST glimpse operations in  
order to revalidate the size?  I don't recall any lock bit that the  
MDS gives the client that tells the client that the file size it has  
is still valid.

In this regard, it seems that SOM would only provide an improvement on  
the initial "ls -l" operation, and subsequent "ls -l" operations would  
be slower than the current "readdir + statahead + DLM lock  
cache" (which would not need to do any RPCs for the second "ls -l").

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
>
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
>
>      It seems safe to allow client replay to proceed concurrently
>      with key state recovery since clients should only replay updates
>      that were not rejected the first time round.  Also the MDS knows
>      which files are volatile through an OST restart if clients only
>      send "done writing" when all updates have committed.
>
> -- 
>
>        Cheers,
>                   Eric
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
