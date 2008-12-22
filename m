From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 22 Dec 2008 10:53:09 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
Message-ID: <18767.18277.958956.959956@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

a few proposals for a distributed recovery for the upcoming CMD release
of Lustre were discussed recently. In my opinion, many of them
(including the clients-epoch approach that I advocated) are very
complex, and a simpler solution, that can be fully understood is
needed. The following is an attempt to provide such a solution.

Nikita.

								 * * *

This is a strawman proposal. At least it would help us to settle the
terminology.

The following describes an alternative distributed recovery mechanism. As this
proposal is somewhat radically alternative, exposition is rather abstract,
please bear with it.

The summary is that the original `global epochs' [10] proposal is modified to
involve all cluster nodes, including clients. This seeks to fix what is seen
as a major drawback of the said algorithm: its reliance on a master-slave
processing.

Definitions:
============

A _cluster_ consists of _nodes_. Every node has a volatile storage. Some nodes
have persistent storage. Persistent means `surviving any failure considered in
the model'.

Nodes exchange _messages_. A message X with a parameter Y, sent from a node N
to a node M is denoted as

        X(Y) : N -> M

Synchronous message send is denoted as

        X(Y) : N ->> M

It is, in reality, a sequence

        X(Y) : N -> M
        RepX : M -> N

of a send and a reply.

Nodes _join_ the cluster, and _part_ from the cluster. A node can be forcibly
parted from the cluster---_evicted_.

An _operation_ is a `primitive' distributed modification of state, that moves
distributed state from one consistent state to another consistent
state. `Primitive' because without such a qualification a valid sequence of
operations would be an operation itself.

An operation OP consists of _updates_ of a state of every node involved in
this operation: OP = (U(0), ... U(n)), where U(k) is an update for a node
U(k).node.

A _reintegration_ of an operation is a process by which a node (by sending
messages) requests other nodes to _execute_ updates of a given operation,
i.e., to effect corresponding state change in the node storage (volatile or
persistent). Details of reintegration are described below.

A node with a persistent storage supports _transactions_, which are means to
declare that a sequence of updates, executed in a volatile storage, must reach
persistent storage atomically.

Two updates are _conflicting_ if their results (including success or failure
indication) and the final state are depending on the order of their
execution.

For a given update U, a node N can send a message to U.node, requesting a
_lock_ that will delay requests for locks for conflicting updates requested
from other nodes until the lock is either released by another message or when
N leaves the cluster. (In reality locks are taken on objects, but introducing
them would complicate the exposition.)

Epoch Basics:
=============

The core epochs algorithm is very simple.

Every node N keeps in its volatile storage an _epoch number_, denoted
N.epoch. Every message X is tagged with an epoch number that is denoted as
X.epoch. These epoch numbers are maintained according to the following
protocol:

        E1. On receiving X : M -> N, N sets

                N.epoch = max(N.epoch, X.epoch);

        E2. On sending X : N -> M, N sets

                X.epoch = N.epoch;

Assignments in E1 and E2 must be mutually atomic. Compare this with `Lamport
timestamps' [1] and `vector clocks' [2].

Progressing toward new epochs will be described later, for now assume that
there are multiple epoch numbers at the same time stored in the node memories
and traversing the network in messages.

Operations:
===========

        O1. To reintegrate an operation OP = (U(0), ... U(n)), a node N

                - sends lock requests: LOCK(U(k)) : N ->> U(k).node;

                - sends reintegration messages: REINT(U(k)) : N -> U(k).node
                  atomically w.r.t. E1.

                - adds U to the volatile `redo log'.

O1 doesn't require all LOCK messages to be synchronous and serialized: it's
only necessary that replies to all LOCK messages are received before first
REINT message is sent.

We denote REINT(U).epoch as U.epoch (well-defined), and say that update U `is
in the epoch U.epoch', and that corresponding undo record (see O2) is a record
`in epoch U.epoch'.

        O2. On receiving REINT(U) : M -> N (where N == U.node), 
            node N transactionally

                - executes U in the volatile storage, and

                - adds to the `undo log' a record [U, OP]

            Note that U.epoch can be less than N.epoch at the time of
            execution (it cannot be greater than the latter due to E1).

We consider only single-level reintegration, where execution of an update
requires no further reintegrations. Generalization to the multi-level case is
left as an exercise for a curious reader.

Correctness:
============

We can now prove a number of very simple statements:

S0: For a node N, N.epoch increases monotonically in time.  

    Proof: The only place where N.epoch is modified is E1, and this is
    obviously a non-decreasing function.

S1: A collection of all updates in a given epoch is presicely a collection of
updates for some set of operations (i.e., epoch contains no partial
operations).

    Proof: Obvious from O1: all updates for a given operation are sent in the
    same epoch.

S2: For any sequence of conflicting updates (U{0}, ... U{n}), the sequence
(U{0}.epoch, ..., U{n}.epoch) is monotonically increasing.

    Proof: Consider conflicting updates U{k} and U{k+1}. From O1 and the
    definition of locking it is immediately clear that the following sequence
    of message sends took place:

            LOCK(U{k})      : N -> S   ; request a lock for U{k}
            RepLOCK(U{k})   : S -> N   ; get the lock for U{k}

        (*) REINT(U{k})     : N -> S   ; reintegrate U{k}

            LOCK(U{k+1})    : M -> S   ; conflicting lock is requested by M

        (*) UNLOCK(U{k})    : N -> S   ; N yields the lock

        (*) RepLOCK(U{k+1}) : S -> M   ; M get the lock

        (*) REINT(U{k+1})   : M -> S   ; reintegrate U{k+1}

     Only ordering of messages marked with (*) matters, the rest is just for
     completeness. Then

     U{k}.epoch == REINT(U{k}).epoch       ; by definition
                <= UNLOCK(U{k}).epoch      ; by S0 for N and E2
                <= RepLOCK(U{k+1})         ; by S0 for S and E2
                <= REINT(U{k+1})           ; by S0 for M
                == U{k+1}.epoch            ; by definition

In the essence, S2 states that epoch ordering is compatible with the causal
ordering of updates. An important consequence of this is that an epoch cannot
`depend' on a previous epoch. Note that the proof of S2 is very similar to the
proof of serializability [7] of the database schedules under the two-phase
locking (2PL) protocol [3].

From S0, S1 and S2 it seems very plausible to conclude that

S3: For any epoch E, a collection of updates in all epochs up to and including
E is presicely a collection of updates in some prefix of execution
history. That is, for every node N, said collection contains updates from all
operations reintegrated by N before some moment T in N's physical time, and no
updates from operations reintegrated by N after T. Alternatively, `an epoch
boundary is a consistent state snapshot'.

We won't prove S3, as this requires formalizing the notions of global and
local histories, distributed schedules, etc., which is more formalism than is
tolerable at the moment.

Intermezzo:
===========

S3 is the main weapon in achieving correct distributed recovery: it claims
that restoring the distributed state as of on an epoch boundary results in a
globally consistent state. The key observation is that due to O2 every node
with a persistent storage has enough information to individually restore its
state to the boundary of _any_ epoch, all updates from which it has on its
persistent storage, even in the face of failures. Once all such nodes agreed
on a common epoch number, they restore their state independently. It is this
agreeing on a single number instead of agreeing on a common set of updates
that greatly simplifies recovery.

Advancing epochs:
=================

So far no way to progress to the next epoch was introduced. If algorithms
described above were ran as is, there would be only one epoch boundary: an
initial file system state (as created by mkfs), and it would be the only point
to which epoch-based recovery could restore the system up to.

A switch to the next epoch can be initiated by any node N, and is effected by

        E3. N.epoch++;

That's all. That is, multiple nodes can advance epochs completely
independently without any communication whatsoever. To understand why this is
sound recall the proof of S3: all it relies on is that epochs monotonically
increase across a chain _dependent_ messages, and to be involved into
dependent operation nodes communicate (through another node perhaps), and
their epoch numbers are synchronized by E1 and E2.

E3 is executed atomically w.r.t. E1 and E2. Note that E3 doesn't break epoch
monotonicity assumed by S0.

To speed up announcement of a new epoch, N

        E4. (optionally) sends null messages to some nodes.

The more, if any, null messages are sent to other nodes, the faster news about
new epoch are spread across the cluster. In the extreme case, N broadcasts
announcement to the whole cluster. Note that there is no synchrony
requirements for the null messages: it is perfectly valid, for example, that N
is still sending them when another node already started sending the next round
of announcements.

There is a great laxity in deciding when to switch to the next epoch. Possible
variants include: on every reintegration (an extreme case), on a timeout, on a
certain amount of updates in the existing epoch, etc. Similarly it's a matter
of policy to allow all or only select nodes to advance epochs.

Retiring epochs:
================

The description above outlines, in principle, a workable system, on top of
which distributed recovery can be implemented. Yet in O2 a flaw is hidden:
`undo log' can only grow, and no way to limit its size is indicated. While
from some points of view (audit, undelete, backup) a complete log of system
updates from the beginning of time is useful, it is generally unacceptable to
keep an O(operations) rather than O(data + metadata) state on the persistent
storage. To this end a mechanism to prune undo log without sacrificing
correctness is necessary.

Clearly, an entry can be pruned from an undo log the moment it is guaranteed
that the corresponding update will be never undone as a part of restoring
consistent state during recovery. As our goal is to restore to the epoch
boundary, all undo entries for a given epoch are discardable if one of them
is. To understand what epochs can be retired, let's look at the epochs that
can be not.

Obviously, an epoch cannot be discarded from an undo log if some of its
updates are in volatile storage only: if nodes with these volatile updates
fail, epoch can never be completed, and has to be undone completely.

From this it is tempting to conclude that an epoch can be pruned from undo
logs once all of its updates are on the persistent storage, but, welladay
[4], this is no so, because even as a given epoch can be everywhere stabilized
to the persistent storage, some of its preceding epochs can be still volatile.

This in fact is the only obstacle: an epoch can be pruned from undo
logs as soon as it and all preceding epochs are everywhere stabilized.

Note that because epochs are advanced independently, updates for a given epoch
can be spread across all nodes, and the only safe way to learn about
everywhere stable epochs is to ask every node in the cluster what is the
oldest epoch for which it has updates in the volatile storage only.

Finding out everywhere stable epochs can be done across various `topologies':
star, ring, etc. [6] We shall discuss the simplest star model, but see below.

Every node N maintains an `oldest locally volatile epoch' N.lvepoch, defined
as an earliest epoch that still has on this node updates in the volatile
memory only.

For a server node, N.lvepoch is an epoch of the earliest update that was
executed, but hasn't yet committed to the persistent storage.

For a client node, N.lvepoch is an epoch of the earliest reintegration that
has at least one update that hasn't been committed to the stable storage on
the corresponding server.

Note that N.lvepoch does _not_ necessary increase monotonically with time, as
a node can receive, as a part of reintegration, updates with an epoch smaller
than any epoch it seen before. The following however holds:

S4: For any node N, N.lvepoch <= N.epoch, at any time.

    Proof: if N received an update U as a part of reintegration, N.epoch was
    updated by E1 as part of REINT(U) processing, assuring that U.epoch <=
    N.epoch. If U originates on N, it is tagged with the current node epoch,
    so U.epoch == N.epoch. Since that moment, N.epoch continues to increase
    monotonically, guaranteeing that U.epoch <= N.epoch for any volatile (or
    stable, for that matter) update U on N. Therefore,

            N.lvepoch == min{U.epoch | volatile update U@N} <= N.epoch;

A node SC (Stability Coordinator) is selected in the cluster configuration. SC
monitors

        - cluster membership: every node N sends 

                HAS_VOLATILE(N, N.epoch) : N ->> SC 

          when it enters the cluster (where N.epoch is set up during the
          initial hand-shake with the cluster entry node) and

                HAS_VOLATILE(N, +infinity) : N ->> SC 

          when it parts from the cluster. When a node N is evicted by a node
          M, a HAS_VOLATILE(N, +infinity) : M ->> SC is send.

        - an oldest locally volatile epoch for every node as an array
          SC.lvepoch[].

These data are updated as following:

        E5. Periodically every node N sends 

                HAS_VOLATILE(N, N.lvepoch) : N -> SC.

        E6. On receiving HAS_VOLATILE(N, lvepoch) : M -> SC, SC sets

                SC.lvepoch[N] = lvepoch;

        E7. When min{SC.lvepoch[*]} changes, SC broadcasts

                MIN_VOLATILE(min{SC.lvepoch[*]}) : SC -> N

            to every node N.

Protocol E5--E7 implements a `stability algorithm'.

Clearly, stability algorithm aligns very well with the tree reduction [6]: in
a typical cluster clients will report their oldest volatile epochs to the
servers, that would compute minimum across their children and forward it
upward until the root node is reached, from where the global minimum is
propagated back.

S5: When a node N receives

        MIN_VOLATILE(E) : SC -> N

it can safely prune all epochs older than E from its undo logs.

    Proof: Imagine that some epoch earlier than E is somewhere volatile at the
    moment when N receives the message above, that is some node M has volatile
    update U such that U.epoch < E. Let Q be the node that originated U (this
    might be M or some other node). We have the following sequence of
    messages:

            HAS_VOLATILE(Q, lvepoch) : X -> SC
            MIN_VOLATILE(E) : SC -> N

    where the last such stability message from Q is meant. If X != Q, that is,
    Q has been evicted by a certain node X, then, by the definition of the
    eviction process (see below), the following sequence of messages took
    place:

            HAS_VOLATILE(M, M.lvepoch) : M ->> SC
            HAS_VOLATILE(Q, +infinity) : X ->> SC
            MIN_VOLATILE(E) : SC -> N

    and we have

            U.epoch >= M.lvepoch           ; by the definition of M.lvepoch
                    >= min{SC.lvepoch[*]}  ; by E6
                    == E                   ; by E7.

    Contradiction. 
                
    Hence, X == Q, and Q hasn't been evicted. If lvepoch > U.epoch, then by
    the definition of Q.lvepoch, Q has been informed by the servers (including
    M), that all updates in U.epoch, including U have been stabilized, which
    contradicts the initial assumption about U. Hence,

            U.epoch >= Q.lvepoch
                    >= min{SC.lvepoch[*]}  ; by E6
                    == E                   ; by E7.

    Contradiction. 

Redo logs:
==========

The problem of pruning redo logs, filled by O1 is much simpler: once a record
for an update U is discarded from the undo log, corresponding record can be
discarded from the redo log too, because if record is never undone, there will
never be a chance to redo it. This policy is conservative, because redo logs
can be pruned much more aggressively, yet, it is simple, and all
infrastructure for it already exists.

Recovery:
=========

Let's after all describe how the recovery process looks like.

There are two types of recovery:

        - eviction: it happens when a node without persistent storage
          fails. In this case, some other node takes the task of restoring
          consistent state, and

        - recovery (proper), that happens when a node with persistent storage
          fails. In this case failed node initiates distributed recovery
          algorithm when it restarts.

When a node N decides to evict a victim node V, it

        V1. sends EVICT_PREP(V) : N -> M to all nodes that might potentially
            keep volatile updates for V (typically, all servers, including N).

        V2. On receiving EVICT_PREP(V) : N -> M, node M

                - records that V is evicted, denying all future messages from
                  it,

                - sends HAS_VOLATILE(N, N.lvepoch) : N ->> SC.

                - finds all locks it granted to V,

                - finds in its undo log all records [U, OP] where U is
                  protected by these locks (U.node == V of course), and
                  adds them to the list L,

                - sends EVICT_ACK(V, L) : M -> N.

        V3. On receiving EVICT_ACK(V, L) : M -> N from all nodes, N

                - removes from every L all entries that together match
                  complete operation.

                - if all L lists are now empty, then all updates from all
                  operations reintegrated by V reached other nodes, and there is
                  nothing to do;

                - otherwise, some of the updates were lost, and other updates
                  from the same operations have to be undone, which might
                  require undoing yet other updates, including updates not
                  protected by the locks held by V, and updates made by other
                  clients. N initiates proper recovery (see below), that can be
                  started immediately from the step R4, by sending

                        RECOVERY_COMMIT(N, min{U.epoch | U in L}) : N ->> M.

        V4. In any case, eviction is finished by sending

                        HAS_VOLATILE(V, +infinity) : N ->> SC.

This algorithm is `obviously' correct, as it either

        - discards V volatile storage in the case when contents of this
          storage is duplicated on other nodes (thus global state is not
          changed), or

        - invokes proper recovery.

Many optimizations are possible:

        - M can omit `local' operations from L,

        - tree reduction of L construction,

        - nodes might force updates to the persistent storage
          (commit-on-eviction) to reduce the risk of future proper recovery
          failing due to missing V redo log.

The unfortunate fact that eviction might force undoing updates made by other
clients and, hence, cascading evictions is a direct consequence of a weaker
isolation level implied by O1 and O2, viz. an ability to read data modified by
an update that is a part of an operation other updates of which hasn't reached
their target nodes yet. This is similar to `cascading aborts' that arise due
to reads of uncommitted data [8], and can be addressed by a very simple
mechanism:

        O3: For any operation OP1 = (U(0), ... U(n)), a REINT(U(k)) message
            can be sent only once for any operation OP0 containing an update
            conflicting with any of U(i), replies to all OP0 reintegration
            messages have been received.

That is, new reintegration can start only after all conflicting reintegrations
fully completed, where `conflict' is understood to be between operations
rather than between individual updates.

With a modest decrease in reintegration concurrency, introduced by this
mechanism that we are going to call `volatile-on-share' (because on conflict
updates are forced to at least volatile storage of their target nodes, compare
with commit-on-share [11]), eviction algorithm can be simplified as following:

        V3'. On receiving EVICT_ACK(V, L) : M -> N from all nodes, N

                - removes from every L all entries that together match
                  complete operation.

                - for any non-empty L, N sends

                        EVICT_COMMIT(V, L) : N ->> M

        V4'. On receiving EVICT_COMMIT(V, L) : N ->> M, node M

                - undoes all updates in L, with O3 guaranteeing that no
                  conflicting updates exist.

                - releases all locks found in V2.

        V5'. N finishes eviction by sending

                        HAS_VOLATILE(V, +infinity) : N ->> SC.

Proper recovery.

We shall assume, that the transaction system on nodes with persistent storage
maintains commit ordering:

        If transactions T0 and T1 contain conflicting updates U0 and U1, U0
        precedes U1 in time and T1 has been committed to the persistent
        storage, then so is T0.

(If a pair of transactions has multiple conflicting updates, they all have to
be in the same order, otherwise transactions are not serializable.)

The rough recovery plan is to

        - find out which is the latest everywhere stable epoch (by running
          stability algorithm described above),

        - undo all epochs up to the epoch found, and

        - apply all available redo logs to restore as much state as possible.

Some node (presumably a node that failed and restarted) acts as a recovery
coordinator (RC). RC maintains `oldest somewhere volatile epoch' RC.svepoch as
described below.

The following protocol (two phase commit protocol [9] for RC.svepoch, in fact)
is executed:

        R1. RC sends RECOVERY_PREP(RC) : RC -> N to all nodes with the
        persistent storage.

        R2. On receiving RECOVERY_PREP(RC) : RC -> N, node N sends

                HAS_VOLATILE(N, N.lvepoch) : N -> RC

        R3. On receiving HAS_VOLATILE(N, lvepoch) : N -> RC, RC sets

                RC.svepoch = min(RC.svepoch, lvepoch).

        R4. Once RC received all HAS_VOLATILE messages from all servers, it
        broadcasts

                RECOVERY_COMMIT(RC, RC.svepoch) : RC ->> N

        R5. on receiving RECOVERY_COMMIT(RC, E), node N undoes all updates in
        has in its logs in all epochs starting from E.

Nodes might need to keep some persistent state to guarantee recovery progress
in the face of repeated failures, in the standard 2PC fashion.

Once undo-part of recovery is finished, clients are asked to push their redo
logs, starting from epoch RC.svepoch to servers, before they can start
requesting new reintegrations. Usual Lustre algorithm (version based recovery)
can be used here, with nodes evicted, when they cannot redo updates due to
some other client failure.

Belle Epoque:
=============

Proposed algorithm has the following advantages:

        - it is very simple. Surprisingly, with some effort, it even seems to
          be amendable to a more or less complete formal analysis;

        - it is non-blocking: in no event `normal processing' i.e.,
          reintegration has to block waiting for some epoch-related processing;

        - it is scalable, provided failures are relatively rare;

Its main disadvantage is that due to the clients participation in the
stabilization algorithm, a failed client can delay detection of everywhere
stable epochs, and, hence, lead to larger undo-redo lists, and a longer
recovery. It seems that in the worst case, a sequence of client failures can
delay detection of epoch stabilization by a timeout times some small constant.

References:
===========

[1] Lamport timestamps: http://en.wikipedia.org/wiki/Lamport_timestamps

[2] Vector clocks: http://en.wikipedia.org/wiki/Vector_clocks

[3] Two phase locking: http://en.wikipedia.org/wiki/Two_phase_locking

[4] Nurse:    Ah, well-a-day! he's dead, he's dead, he's dead!
              We are undone, lady, we are undone!

[5] Network topology: http://en.wikipedia.org/wiki/Network_topology

[6] Tree reduction: http://en.wikipedia.org/wiki/Graph_reduction

[7] Serializability: http://en.wikipedia.org/wiki/Serializability

[8] Recoverability: http://en.wikipedia.org/wiki/Schedule_(computer_science)#Avoids_cascading_aborts_.28rollbacks.29

[9] Two-phase commit: http://en.wikipedia.org/wiki/Two-phase_commit_protocol

[10] Cuts: http://arch.lustre.org/index.php?title=Cuts

[11] Commit on share: http://arch.lustre.org/index.php?title=Commit_on_Share
