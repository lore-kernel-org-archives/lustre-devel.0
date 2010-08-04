From: Eric Barton <eeb@whamcloud.com>
Date: Tue, 3 Aug 2010 22:30:55 -0700
Subject: [Lustre-devel] Lnet routing preferences
In-Reply-To: <2C7DE72B9BD00F44BAECA5B0CBB87395C3F4A6@hermes.terascala.com>
References: <2C7DE72B9BD00F44BAECA5B0CBB87395C3F4A6@hermes.terascala.com>
Message-ID: <007b01cb3396$3ae07290$b0a157b0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ben,

> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Ben Evans
> Sent: 27 July 2010 11:04 AM
> 
> I've been poking around and experimenting with the luster internals
> on my own, and ran into a question that I haven't been able to track
> down.
> 

> For MDS/OSS communications, where there are multiple possible paths
> (Ethernet, IB, etc.) how does LNET (or Lustre) decide which
> interface to send messages?

First a bit of explanation...

LNET node addressing is driven by the idea that since an arbitrary
network topology requires O(n**2) routing tables, it would be good to
limit the 'n' as much as possible :-)

When Peter Braam and I were discussing how to finesse this issue in
early implementations of LNET routing, we observed that since Lustre
is a cluster file system spanning compute clusters, storage clusters
and mixtures of both, a 2-level addressing scheme which assumes flat
connectivity within clusters but arbitrary connectivity between
clusters, limits the 'n' to the number of clusters rather than the
total number of nodes.  That's why an LNET NID is the concatenation of
the network and the node-within-network.

Now to your question...

When LNET routes a message, it first checks whether the destination
NID is in a local network.  If so, it passes the message to the local
interface on that network.

If the destination is not local, LNET looks up the destination network
in its route table.  The route table lists all the NIDs of LNET
routers on local networks that could forward the message to its
eventual destination with a minimum number of hops.  LNET then chooses
the router with the shortest queue.

> Ideally, I'd like to send server-to-server messages over a private
> network and let the clients communicate over the public network

Note that the choice of destination NID is in itself a routing
decision if there are potentially several to choose from.  For
example, if I have NIDs x1 at o2ib0 and y1 at tcp0 and you have NIDs
x2 at 02ib0 and y2 at o2ib0, then whether communications between us are
routed over o2ib0 or tcp0 is completely determined by the choice of
NID handed to LNET, not by LNET itself.

So if you want to communicate over a server-only network, you just
need to use server-only NIDs.

Note however that this requirement may conflict with the desire to do
link aggregation for performance/failover.  We've been considering
using NIDs in a way which is much more like conventional IP networks -
i.e. where the upper levels can specify any destination NID and LNET
takes a bigger part in the decision about which network to use.

Isaac Huang has been thinking about link aggregation for a while and
may care to comment on whether he has considered private networks like
this.

> I'm interested in finding out if there are any gains to be made from
> a setup like this.

Yes, you could benefit from avoiding any congestion created by client
communications.

But I must ask - what is it that you want to communicate between
servers like this and are you sure you're not introducing a scaling or
deadlock issue?

                Cheers,
                        Eric

Eric Barton
CTO Whamcloud Inc.
