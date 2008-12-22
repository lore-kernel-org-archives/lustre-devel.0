From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Dec 2008 14:52:11 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18767.18277.958956.959956@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
Message-ID: <494F7F6B.9080509@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Nikita Danilov wrote:
> For a given update U, a node N can send a message to U.node, requesting a
> _lock_ that will delay requests for locks for conflicting updates requested
> from other nodes until the lock is either released by another message or when
> N leaves the cluster. (In reality locks are taken on objects, but introducing
> them would complicate the exposition.)

I find this relying on explicit request (lock in this case) as a disadvantage:
lock can be taken long before reintegration meaning epoch might be pinned for
long pinning in turn a lot of undo/redo logs. It's also not very clear how fsync(2)
and similar requests will be working with such pinned epochs - broadcast to release
or change on-client epoch? Another point is that some operation can be lockless:
for example, we were planning to skip extents locking for exclusively open files
while epoch could be used by SNS for data.

> Every node N maintains an `oldest locally volatile epoch' N.lvepoch, defined
> as an earliest epoch that still has on this node updates in the volatile
> memory only.
> For a client node, N.lvepoch is an epoch of the earliest reintegration that
> has at least one update that hasn't been committed to the stable storage on
> the corresponding server.

this means client actually should maintain many epochs at same time as any lock
enqueue can advance epoch.

> A node SC (Stability Coordinator) is selected in the cluster configuration. SC
> monitors

I think having SC is also drawback:
1) choosing such node is additional complexity and delay
2) failing of such node would need global resend of states
3) many unrelated nodes can get stuck due to large redo logs

> These data are updated as following:
> 
>         E5. Periodically every node N sends 
> 
>                 HAS_VOLATILE(N, N.lvepoch) : N -> SC.
> 
>         E6. On receiving HAS_VOLATILE(N, lvepoch) : M -> SC, SC sets
> 
>                 SC.lvepoch[N] = lvepoch;
> 
>         E7. When min{SC.lvepoch[*]} changes, SC broadcasts
> 
>                 MIN_VOLATILE(min{SC.lvepoch[*]}) : SC -> N
> 
>             to every node N.
> 
> Protocol E5--E7 implements a `stability algorithm'.

given current epoch can be advanced by lock enqueue, client can get many used
epochs at same time, thus we'd have to track them all in the protocol.

> Clearly, stability algorithm aligns very well with the tree reduction [6]: in
> a typical cluster clients will report their oldest volatile epochs to the
> servers, that would compute minimum across their children and forward it
> upward until the root node is reached, from where the global minimum is
> propagated back.

I'm not sure it scales well as any failed node may cause global stuck in undo/redo
pruning.

> Redo logs:
> ==========
> 
> The problem of pruning redo logs, filled by O1 is much simpler: once a record
> for an update U is discarded from the undo log, corresponding record can be
> discarded from the redo log too, because if record is never undone, there will
> never be a chance to redo it. This policy is conservative, because redo logs
> can be pruned much more aggressively, yet, it is simple, and all
> infrastructure for it already exists.

it's probably simpler, but single node suffers from this global dependency much:
there might be a lot of epochs under work and lots of RPCs (especially with tree
reduction) before client can discard redo. I don't think this really scales well
with 100K and more nodes.

> Proper recovery.
> The rough recovery plan is to
> 
>         - find out which is the latest everywhere stable epoch (by running
>           stability algorithm described above),

It's not very clear how server finds epoch stable in case of total power off:
no client can provide this data.

> 
>         - undo all epochs up to the epoch found, and
> 
>         - apply all available redo logs to restore as much state as possible.
> 
> Some node (presumably a node that failed and restarted) acts as a recovery
> coordinator (RC). RC maintains `oldest somewhere volatile epoch' RC.svepoch as
> described below.
> 
> The following protocol (two phase commit protocol [9] for RC.svepoch, in fact)
> is executed:
> 
>         R1. RC sends RECOVERY_PREP(RC) : RC -> N to all nodes with the
>         persistent storage.
> 
>         R2. On receiving RECOVERY_PREP(RC) : RC -> N, node N sends
> 
>                 HAS_VOLATILE(N, N.lvepoch) : N -> RC
> 
>         R3. On receiving HAS_VOLATILE(N, lvepoch) : N -> RC, RC sets
> 
>                 RC.svepoch = min(RC.svepoch, lvepoch).
> 
>         R4. Once RC received all HAS_VOLATILE messages from all servers, it
>         broadcasts
> 
>                 RECOVERY_COMMIT(RC, RC.svepoch) : RC ->> N
> 
>         R5. on receiving RECOVERY_COMMIT(RC, E), node N undoes all updates in
>         has in its logs in all epochs starting from E.
> 
> Nodes might need to keep some persistent state to guarantee recovery progress
> in the face of repeated failures, in the standard 2PC fashion.
> 
> Once undo-part of recovery is finished, clients are asked to push their redo
> logs, starting from epoch RC.svepoch to servers, before they can start
> requesting new reintegrations. Usual Lustre algorithm (version based recovery)
> can be used here, with nodes evicted, when they cannot redo updates due to
> some other client failure.
> 

while one may find this simple I think we shouldn't sacrifice scalability and
performance for simplicity.

Instead we could do the following:

  * when client issues transaction it labels it with unique id
  * server executing operation write atomically undo record with:
    * VBR versions so that we can build chains of really depended operations
    * unique transaction id generated by client
    * number of servers involved in transaction
  * periodically servers exchange their committed unique transaction ids
    (only distributed transaction are involved in this)
  * once some distributed transaction is committed on all involved servers, we can prune
    it and all its local successors
  * during recovery:
    * first, all capable clients replay they redo (replay queue)
    * servers read their undo logs, find distributed transactions
    * servers exchange their distributed transaction ids
    * servers find partially committed distributed transactions
    * servers undo partially committed distributed transactions and all depending on them

I see the following advantages of this dependency-based approach:
  * only servers are involved
  * no single point of failure that may cause many nodes to block due to large redo logs
  * client doesn't need to track many global epochs - just use current mechanism, no
    changes on the client side
  * no rely on some protocol like ldlm
  * support for lockless operations
  * with late replay we don't need to update redo with some new epoch
  * doesn't depend on current cluster state:
    * can forward transactions via intermediate nodes
    * may be important for complex setups over WAN
  * fsync(2) and synchronous requests can be implemented optimal way
  * support for global and local epochs with no additional code
  * amount of network overhead is proportional to number of distributed transactions:
    * server just needs to send arrays of transaction ids to other servers
    * much better batching compared to the above
  * with 32K distributed transaction per second and 16byte unique transaction id, server 
nwould need to send ~2,5MB per 5 second
  * if server is told what other transaction's participant, then this exchange can be very 
efficient
  * no need in undo for non-depended changes:
   * in the simplest form - no uncommitted distributed transaction in undo before
   * in the complex form - tracking real dependency at executime time
   * it means in many cases recovery can be very fast
  * recovery can be completed quickly as undo is smaller and we undo-redo very selectively
  * as long as no distributed transactions are issued (A works with /home/a living on mds1,
    B works with /home/b living on mds2) no any epoch-related activity is required,
    including undo



thanks, Alex
