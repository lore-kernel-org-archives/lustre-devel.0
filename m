From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 16 Jan 2009 02:40:41 +0300
Subject: [Lustre-devel] global epochs vs fsync
In-Reply-To: <18767.18277.958956.959956@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
Message-ID: <496FC979.80802@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

here is another thought ...

whole distributed recovery can be divided into two parts:
* "purge" job, before recovery takes place, we write and purge undo records
* "undo" job, when recovery takes place and we rollback to some consistent state

global epochs do very well "purge job", because of constant overhead.
but when it comes to fsync, global epochs do not because to fsync some epoch
X, we need to wait till all nodes having unstable epochs Y < X report it
to SC and then we have to synchronously write new global stable epoch.
it's especially not very well from reliability point of view - having many
nodes to contribute makes this vulnerable for failures.

with dependencies we could implement more efficient fsync because all you need
is to sync _servers_ holding uncommitted updates for some object and updates it
depends on, we don't need to wait for other nodes, then write some record. IOW,
dependencies do well "undo job", because it's not a global undo of all unlucky
operations, but only really inconsistent ones. but dependencies do bad with "purge
job", because traffic overhead (in bytes) is order of distributed updates.

the question is .... could we use global epochs for "purge" and dependencies for
"undo" ? say, updates are tagged with an epoch and unique tag. for regular activity
global minimum is found in lazy manner. but during recovery we build chains of
dependencies using unique tags and do very selective rollback.

thanks, Alex


Nikita Danilov wrote:
> Hello,
> 
> a few proposals for a distributed recovery for the upcoming CMD release
> of Lustre were discussed recently. In my opinion, many of them
> (including the clients-epoch approach that I advocated) are very
> complex, and a simpler solution, that can be fully understood is
> needed. The following is an attempt to provide such a solution.
> 
> Nikita.
> 
> 								 * * *
> 
> This is a strawman proposal. At least it would help us to settle the
> terminology.
> 
> The following describes an alternative distributed recovery mechanism. As this
> proposal is somewhat radically alternative, exposition is rather abstract,
> please bear with it.
> 
> The summary is that the original `global epochs' [10] proposal is modified to
> involve all cluster nodes, including clients. This seeks to fix what is seen
> as a major drawback of the said algorithm: its reliance on a master-slave
> processing.
> 
> Definitions:
> ============
> 
> A _cluster_ consists of _nodes_. Every node has a volatile storage. Some nodes
> have persistent storage. Persistent means `surviving any failure considered in
> the model'.
> 
> Nodes exchange _messages_. A message X with a parameter Y, sent from a node N
> to a node M is denoted as
> 
>         X(Y) : N -> M
> 
> Synchronous message send is denoted as
> 
>         X(Y) : N ->> M
> 
> It is, in reality, a sequence
> 
>         X(Y) : N -> M
>         RepX : M -> N
> 
> of a send and a reply.
> 
> Nodes _join_ the cluster, and _part_ from the cluster. A node can be forcibly
> parted from the cluster---_evicted_.
> 
> An _operation_ is a `primitive' distributed modification of state, that moves
> distributed state from one consistent state to another consistent
> state. `Primitive' because without such a qualification a valid sequence of
> operations would be an operation itself.
> 
> An operation OP consists of _updates_ of a state of every node involved in
> this operation: OP = (U(0), ... U(n)), where U(k) is an update for a node
> U(k).node.
> 
> A _reintegration_ of an operation is a process by which a node (by sending
> messages) requests other nodes to _execute_ updates of a given operation,
> i.e., to effect corresponding state change in the node storage (volatile or
> persistent). Details of reintegration are described below.
> 
> A node with a persistent storage supports _transactions_, which are means to
> declare that a sequence of updates, executed in a volatile storage, must reach
> persistent storage atomically.
> 
> Two updates are _conflicting_ if their results (including success or failure
> indication) and the final state are depending on the order of their
> execution.
> 
> For a given update U, a node N can send a message to U.node, requesting a
> _lock_ that will delay requests for locks for conflicting updates requested
> from other nodes until the lock is either released by another message or when
> N leaves the cluster. (In reality locks are taken on objects, but introducing
> them would complicate the exposition.)
> 
> Epoch Basics:
> =============
> 
> The core epochs algorithm is very simple.
> 
> Every node N keeps in its volatile storage an _epoch number_, denoted
> N.epoch. Every message X is tagged with an epoch number that is denoted as
> X.epoch. These epoch numbers are maintained according to the following
> protocol:
> 
>         E1. On receiving X : M -> N, N sets
> 
>                 N.epoch = max(N.epoch, X.epoch);
> 
>         E2. On sending X : N -> M, N sets
> 
>                 X.epoch = N.epoch;
> 
> Assignments in E1 and E2 must be mutually atomic. Compare this with `Lamport
> timestamps' [1] and `vector clocks' [2].
> 
> Progressing toward new epochs will be described later, for now assume that
> there are multiple epoch numbers at the same time stored in the node memories
> and traversing the network in messages.
> 
> Operations:
> ===========
> 
>         O1. To reintegrate an operation OP = (U(0), ... U(n)), a node N
> 
>                 - sends lock requests: LOCK(U(k)) : N ->> U(k).node;
> 
>                 - sends reintegration messages: REINT(U(k)) : N -> U(k).node
>                   atomically w.r.t. E1.
> 
>                 - adds U to the volatile `redo log'.
> 
> O1 doesn't require all LOCK messages to be synchronous and serialized: it's
> only necessary that replies to all LOCK messages are received before first
> REINT message is sent.
> 
> We denote REINT(U).epoch as U.epoch (well-defined), and say that update U `is
> in the epoch U.epoch', and that corresponding undo record (see O2) is a record
> `in epoch U.epoch'.
> 
>         O2. On receiving REINT(U) : M -> N (where N == U.node), 
>             node N transactionally
> 
>                 - executes U in the volatile storage, and
> 
>                 - adds to the `undo log' a record [U, OP]
> 
>             Note that U.epoch can be less than N.epoch at the time of
>             execution (it cannot be greater than the latter due to E1).
> 
> We consider only single-level reintegration, where execution of an update
> requires no further reintegrations. Generalization to the multi-level case is
> left as an exercise for a curious reader.
> 
> Correctness:
> ============
> 
> We can now prove a number of very simple statements:
> 
> S0: For a node N, N.epoch increases monotonically in time.  
> 
>     Proof: The only place where N.epoch is modified is E1, and this is
>     obviously a non-decreasing function.
> 
> S1: A collection of all updates in a given epoch is presicely a collection of
> updates for some set of operations (i.e., epoch contains no partial
> operations).
> 
>     Proof: Obvious from O1: all updates for a given operation are sent in the
>     same epoch.
> 
> S2: For any sequence of conflicting updates (U{0}, ... U{n}), the sequence
> (U{0}.epoch, ..., U{n}.epoch) is monotonically increasing.
> 
>     Proof: Consider conflicting updates U{k} and U{k+1}. From O1 and the
>     definition of locking it is immediately clear that the following sequence
>     of message sends took place:
> 
>             LOCK(U{k})      : N -> S   ; request a lock for U{k}
>             RepLOCK(U{k})   : S -> N   ; get the lock for U{k}
> 
>         (*) REINT(U{k})     : N -> S   ; reintegrate U{k}
> 
>             LOCK(U{k+1})    : M -> S   ; conflicting lock is requested by M
> 
>         (*) UNLOCK(U{k})    : N -> S   ; N yields the lock
> 
>         (*) RepLOCK(U{k+1}) : S -> M   ; M get the lock
> 
>         (*) REINT(U{k+1})   : M -> S   ; reintegrate U{k+1}
> 
>      Only ordering of messages marked with (*) matters, the rest is just for
>      completeness. Then
> 
>      U{k}.epoch == REINT(U{k}).epoch       ; by definition
>                 <= UNLOCK(U{k}).epoch      ; by S0 for N and E2
>                 <= RepLOCK(U{k+1})         ; by S0 for S and E2
>                 <= REINT(U{k+1})           ; by S0 for M
>                 == U{k+1}.epoch            ; by definition
> 
> In the essence, S2 states that epoch ordering is compatible with the causal
> ordering of updates. An important consequence of this is that an epoch cannot
> `depend' on a previous epoch. Note that the proof of S2 is very similar to the
> proof of serializability [7] of the database schedules under the two-phase
> locking (2PL) protocol [3].
> 
>>From S0, S1 and S2 it seems very plausible to conclude that
> 
> S3: For any epoch E, a collection of updates in all epochs up to and including
> E is presicely a collection of updates in some prefix of execution
> history. That is, for every node N, said collection contains updates from all
> operations reintegrated by N before some moment T in N's physical time, and no
> updates from operations reintegrated by N after T. Alternatively, `an epoch
> boundary is a consistent state snapshot'.
> 
> We won't prove S3, as this requires formalizing the notions of global and
> local histories, distributed schedules, etc., which is more formalism than is
> tolerable at the moment.
> 
> Intermezzo:
> ===========
> 
> S3 is the main weapon in achieving correct distributed recovery: it claims
> that restoring the distributed state as of on an epoch boundary results in a
> globally consistent state. The key observation is that due to O2 every node
> with a persistent storage has enough information to individually restore its
> state to the boundary of _any_ epoch, all updates from which it has on its
> persistent storage, even in the face of failures. Once all such nodes agreed
> on a common epoch number, they restore their state independently. It is this
> agreeing on a single number instead of agreeing on a common set of updates
> that greatly simplifies recovery.
> 
> Advancing epochs:
> =================
> 
> So far no way to progress to the next epoch was introduced. If algorithms
> described above were ran as is, there would be only one epoch boundary: an
> initial file system state (as created by mkfs), and it would be the only point
> to which epoch-based recovery could restore the system up to.
> 
> A switch to the next epoch can be initiated by any node N, and is effected by
> 
>         E3. N.epoch++;
> 
> That's all. That is, multiple nodes can advance epochs completely
> independently without any communication whatsoever. To understand why this is
> sound recall the proof of S3: all it relies on is that epochs monotonically
> increase across a chain _dependent_ messages, and to be involved into
> dependent operation nodes communicate (through another node perhaps), and
> their epoch numbers are synchronized by E1 and E2.
> 
> E3 is executed atomically w.r.t. E1 and E2. Note that E3 doesn't break epoch
> monotonicity assumed by S0.
> 
> To speed up announcement of a new epoch, N
> 
>         E4. (optionally) sends null messages to some nodes.
> 
> The more, if any, null messages are sent to other nodes, the faster news about
> new epoch are spread across the cluster. In the extreme case, N broadcasts
> announcement to the whole cluster. Note that there is no synchrony
> requirements for the null messages: it is perfectly valid, for example, that N
> is still sending them when another node already started sending the next round
> of announcements.
> 
