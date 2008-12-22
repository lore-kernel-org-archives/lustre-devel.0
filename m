From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 22 Dec 2008 20:15:17 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <494FA7E8.7030200@sun.com>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
Message-ID: <18767.52005.485425.412677@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev writes:
 > Nikita Danilov wrote:
 > >  > I find this relying on explicit request (lock in this case) as a disadvantage:
 > >  > lock can be taken long before reintegration meaning epoch might be pinned for
 > > 
 > > Hm.. a lock doesn't pin an epoch in any way.
 > 
 > well, I think it does as you don't want to use epoch received few minutes ago with lock.

What is the problem with this?

 > 
 > > Locks are only needed to make proof of S2 possible. Once lockless
 > > operation or SNS guarantee in some domain-specific way that no epoch can
 > > depend on a future one, we are fine.
 > 
 > well, I guess "in some domain-specific way" means another complexity.

Any IO mechanism has to guarantee that operations are "serializable",
that is, no circular dependencies exist. This is what global epochs
need, they don't depend on DLM per se.

 > > I don't understand what is meant by "maintaining an epoch" here. Epoch
 > > is just a number. Surely a client will keep in its memory (in the redo
 > > log) a list of updates tagged by multiple epochs, but I don't see any
 > > problem with this.
 > 
 > the problem is that with out-of-order epochs sent to different servers client can't
 > use notion of "last_committed" anymore.

What do you mean by "out of order" here?

 > 
 > >  > I think having SC is also drawback:
 > >  > 1) choosing such node is additional complexity and delay
 > >  > 2) failing of such node would need global resend of states
 > >  > 3) many unrelated nodes can get stuck due to large redo logs
 > > 
 > > As I pointed out, only the simplest `1-level star' form of a stability
 > > algorithm was described for simplicity. This algorithms is amendable to
 > > a lot of optimization, because it, in effect, has to find a running
 > > minimum in a distributed array, and this can be done in a scalable way:
 > 
 > the bad think, IMHO, in all this is that all nodes making decision must
 > understand topology. server should separate epochs from different clients,
 > it's hard to send batches via some intermediate server/node.

Hm.. I would think that this is very easy, thanks to the good properties
of the minimum function (associativity, commutativity, etc.): client
piggy-backs its earliest volatile epoch to any message it sends to any
server, and server batches these data from clients and forwards them to
SC.

 > 
 > > Note, that this requires _no_ additional rpcs from the clients.
 > 
 > disagree. at least for distributed operations client has to report non-volatile
 > epoch from time to time. in some cases we can use protocol like ping, in some - not.

I agree with this, but I am not sure this is a problem. If client is
idle for seconds, pinging is not a big deal.

 > 
 > >  > given current epoch can be advanced by lock enqueue, client can get many used
 > >  > epochs at same time, thus we'd have to track them all in the protocol.
 > > 
 > > I am not sure I understand this. _Any_ message (including lock enqueue,
 > > REINT, MIN_VOLATILE, CONNECT, EVICT, etc.) potentially updates the epoch
 > > of a receiving node.
 > 
 > correct, this means client may have many epochs to track. thus no last_committed anymore.

Presicely the contrary: MIN_VOLATILE message returns something
equivalent to the cluster-wide global last_committed.

 > 
 > undo to redo? even longer recovery?

No, redo to undo. :-)

 > 
 > thanks, Alex

Nikita.
