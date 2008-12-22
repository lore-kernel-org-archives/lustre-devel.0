From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Dec 2008 17:44:56 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18767.35839.133024.625896@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
Message-ID: <494FA7E8.7030200@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
>  > I find this relying on explicit request (lock in this case) as a disadvantage:
>  > lock can be taken long before reintegration meaning epoch might be pinned for
> 
> Hm.. a lock doesn't pin an epoch in any way.

well, I think it does as you don't want to use epoch received few minutes ago with lock.
if node is in WBC mode and granted some STL-like lock, then it may be sending few MBs
batch every, say, 5 minutes. there might be no interaction between batches. this means
client would need to refresh epoch. depending on workload it may happen that client
won't be able to send batch awaiting new epoch or client may refresh epoch with no real
batches after that.

> Locks are only needed to make proof of S2 possible. Once lockless
> operation or SNS guarantee in some domain-specific way that no epoch can
> depend on a future one, we are fine.

well, I guess "in some domain-specific way" means another complexity.

>  > this means client actually should maintain many epochs at same time as any lock
>  > enqueue can advance epoch.
> 
> I don't understand what is meant by "maintaining an epoch" here. Epoch
> is just a number. Surely a client will keep in its memory (in the redo
> log) a list of updates tagged by multiple epochs, but I don't see any
> problem with this.

the problem is that with out-of-order epochs sent to different servers client can't
use notion of "last_committed" anymore.

>  > I think having SC is also drawback:
>  > 1) choosing such node is additional complexity and delay
>  > 2) failing of such node would need global resend of states
>  > 3) many unrelated nodes can get stuck due to large redo logs
> 
> As I pointed out, only the simplest `1-level star' form of a stability
> algorithm was described for simplicity. This algorithms is amendable to
> a lot of optimization, because it, in effect, has to find a running
> minimum in a distributed array, and this can be done in a scalable way:

the bad think, IMHO, in all this is that all nodes making decision must
understand topology. server should separate epochs from different clients,
it's hard to send batches via some intermediate server/node.

> Note, that this requires _no_ additional rpcs from the clients.

disagree. at least for distributed operations client has to report non-volatile
epoch from time to time. in some cases we can use protocol like ping, in some - not.

>  > given current epoch can be advanced by lock enqueue, client can get many used
>  > epochs at same time, thus we'd have to track them all in the protocol.
> 
> I am not sure I understand this. _Any_ message (including lock enqueue,
> REINT, MIN_VOLATILE, CONNECT, EVICT, etc.) potentially updates the epoch
> of a receiving node.

correct, this means client may have many epochs to track. thus no last_committed anymore.

> Only until this node is evicted, and I think that no matter what is the
> pattern of failures, a single level of `tree reduction', can be delayed
> by no more than a single eviction timeout.

the problem is that may affect non-related nodes very easily.

> Actually, single-server operation can be discarded from a redo log as
> soon as it commits on the target server, because the later can always
> redo it (possibly after undo). Given that majority of operations are
> single server, redo logs won't be much larger than they are to-day.

undo to redo? even longer recovery?

thanks, Alex
