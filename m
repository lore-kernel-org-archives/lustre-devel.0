From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 22 Dec 2008 15:45:51 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <494F7F6B.9080509@sun.com>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
Message-ID: <18767.35839.133024.625896@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev writes:
 > Hello,

Hello,

 > 
 > Nikita Danilov wrote:
 > > For a given update U, a node N can send a message to U.node, requesting a
 > > _lock_ that will delay requests for locks for conflicting updates requested
 > > from other nodes until the lock is either released by another message or when
 > > N leaves the cluster. (In reality locks are taken on objects, but introducing
 > > them would complicate the exposition.)
 > 
 > I find this relying on explicit request (lock in this case) as a disadvantage:
 > lock can be taken long before reintegration meaning epoch might be pinned for

Hm.. a lock doesn't pin an epoch in any way.

 > long pinning in turn a lot of undo/redo logs. It's also not very clear how fsync(2)
 > and similar requests will be working with such pinned epochs - broadcast to release
 > or change on-client epoch? Another point is that some operation can be lockless:
 > for example, we were planning to skip extents locking for exclusively open files
 > while epoch could be used by SNS for data.

Locks are only needed to make proof of S2 possible. Once lockless
operation or SNS guarantee in some domain-specific way that no epoch can
depend on a future one, we are fine.

 > 
 > > Every node N maintains an `oldest locally volatile epoch' N.lvepoch, defined
 > > as an earliest epoch that still has on this node updates in the volatile
 > > memory only.
 > > For a client node, N.lvepoch is an epoch of the earliest reintegration that
 > > has at least one update that hasn't been committed to the stable storage on
 > > the corresponding server.
 > 
 > this means client actually should maintain many epochs at same time as any lock
 > enqueue can advance epoch.

I don't understand what is meant by "maintaining an epoch" here. Epoch
is just a number. Surely a client will keep in its memory (in the redo
log) a list of updates tagged by multiple epochs, but I don't see any
problem with this.

 > 
 > > A node SC (Stability Coordinator) is selected in the cluster configuration. SC
 > > monitors
 > 
 > I think having SC is also drawback:
 > 1) choosing such node is additional complexity and delay
 > 2) failing of such node would need global resend of states
 > 3) many unrelated nodes can get stuck due to large redo logs

As I pointed out, only the simplest `1-level star' form of a stability
algorithm was described for simplicity. This algorithms is amendable to
a lot of optimization, because it, in effect, has to find a running
minimum in a distributed array, and this can be done in a scalable way:

        Clearly, stability algorithm aligns very well with the tree
        reduction [6]: in a typical cluster clients will report their
        oldest volatile epochs to the servers, that would compute
        minimum across their children and forward it upward until the
        root node is reached, from where the global minimum is
        propagated back.

Note, that this requires _no_ additional rpcs from the clients.

 > > 
 > > Protocol E5--E7 implements a `stability algorithm'.
 > 
 > given current epoch can be advanced by lock enqueue, client can get many used
 > epochs at same time, thus we'd have to track them all in the protocol.

I am not sure I understand this. _Any_ message (including lock enqueue,
REINT, MIN_VOLATILE, CONNECT, EVICT, etc.) potentially updates the epoch
of a receiving node.

 > 
 > > Clearly, stability algorithm aligns very well with the tree reduction [6]: in
 > > a typical cluster clients will report their oldest volatile epochs to the
 > > servers, that would compute minimum across their children and forward it
 > > upward until the root node is reached, from where the global minimum is
 > > propagated back.
 > 
 > I'm not sure it scales well as any failed node may cause global stuck in undo/redo
 > pruning.

Only until this node is evicted, and I think that no matter what is the
pattern of failures, a single level of `tree reduction', can be delayed
by no more than a single eviction timeout.

 > 
 > > Redo logs:
 > > ==========
 > > 
 > > The problem of pruning redo logs, filled by O1 is much simpler: once a record
 > > for an update U is discarded from the undo log, corresponding record can be
 > > discarded from the redo log too, because if record is never undone, there will
 > > never be a chance to redo it. This policy is conservative, because redo logs
 > > can be pruned much more aggressively, yet, it is simple, and all
 > > infrastructure for it already exists.
 > 
 > it's probably simpler, but single node suffers from this global dependency much:
 > there might be a lot of epochs under work and lots of RPCs (especially with tree
 > reduction) before client can discard redo. I don't think this really scales well
 > with 100K and more nodes.

Actually, single-server operation can be discarded from a redo log as
soon as it commits on the target server, because the later can always
redo it (possibly after undo). Given that majority of operations are
single server, redo logs won't be much larger than they are to-day.

 > 
 > > Proper recovery.
 > > The rough recovery plan is to
 > > 
 > >         - find out which is the latest everywhere stable epoch (by running
 > >           stability algorithm described above),
 > 
 > It's not very clear how server finds epoch stable in case of total power off:
 > no client can provide this data.

The `marker' of a last everywhere stable epoch is the end of undo
log---when a server receives a MIN_VOLATILE message, it prunes all
everywhere stable epochs from its undo log, so on recovery servers
simply exchange the oldest epochs in their logs, and find youngest of
them. All the epochs before this one are everywhere stable (because at
least one server pruned them from its undo logs and hence it received a
MIN_VOLATILE message authorizing it to do so), and every server can roll
back to it. So, rolling all servers back to this epoch is possible and
restores a consistent snapshot.

Nikita.
