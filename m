From: Eric Barton <eeb@sun.com>
Date: Fri, 06 Jun 2008 12:13:18 +0100
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <20080606044135.GJ2961@webber.adilger.int>
References: <2D6B10E2-7BED-4390-A241-7E3D57C0CDF5@Sun.COM>
	<C46DFFAB.5883%peter.braam@sun.com>
	<20080606044135.GJ2961@webber.adilger.int>
Message-ID: <067b01c8c7c6$530dbb40$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Oleg's comments about congestion and the ORNL discussions I've been
involved in are effectively presenting arguments for allowing
expedited communications.  This is possible but comes at a cost.

The "proper" implementation effectively holds an uncongested network
in reserve for expedited communications.  That's a high price to pay
because it pretty well means doubling up all the LNET state - twice
the number of queues/sockets/queuepairs/connections.  That's
unavoidable since we're using these structures for backpressure and
once they're "full" you can only bypass with an additional connection.

You can go a long way towards the ideal by allowing prioritised
traffic to "overtake" everywhere apart from the wire - i.e. all
packets serialise once they have been passed to the comms APIs below
the LNDs, but take priority within the LNDs, LNET (including routers)
and ptlrpc.  

It's hard to say without further thought and/or experiment whether
either of these alternatives actually solves the problem in all
envisaged use cases and doesn't just shift it elsewhere.  For example,
even the "proper" implementation could end up with a logjam on both
low and high priority networks in pathalogical use cases.  And I'm not
ready to believe that increasing the number of priority levels can add
anything fundamental to the argument.

I think our best bet is to find a way to keep congestion to a minimum
in the first place so that peer ping latency in a single-priority
network can be bounded and kept relatively short (seconds, not
minutes).

Unfortunately, the current algorithms for exploiting network and disk
bandwidth are unbelievably simplistic and invite congestion.
Increasing the number of service threads until performance levels off
ignores completely the issue of service latency.  Allowing a single
client to post sufficient traffic to max the network is fine when it's
the only one, but mad when it's one of 100000.  We're tuning systems
to the point of instability, so of course timeouts have to become
unmanageable long.

Scheduling can be a subtle problem where "obvious" solutions can have
non-obvious consequences.  But it might be a start to give servers more
dynamic control over the number of concurrent requests individual clients
are allowed to submit so that when many clients are active individual
clients only submit one RPC at a time, and when few clients are active
concurrency on these clients can increase.  

    Cheers,
              Eric
