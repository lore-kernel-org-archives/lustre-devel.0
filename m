From: Olaf Weber <olaf@sgi.com>
Date: Fri, 16 Oct 2015 12:14:43 +0200
Subject: [lustre-devel] Multi-rail networking for Lustre
Message-ID: <5620CE13.8020706@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As some of you know, I held a presentation at the LAD'15 developers
meeting describing a proposal for implementing multi-rail networking
for Lustre. Some discussion on this list has referenced that talk.
The slides I used can be found here (1MB PDF):

   http://wiki.lustre.org/images/7/79/LAD15_Lustre_Interface_Bonding_Final.pdf

Since I grew up when a slide deck was a pile of transparencies, and
the rule was that you'd used too much text if people could get more
than the bare gist of your talk from the slides, the rest of this mail
is a slide-by-slide paraphrase of the talk. (There is no recording:
unless the other attendees weigh in this is the best you'll get.) A
few points are starred to indicate that they are after-the-talk
additions.


Slide 1: Lustre Interface Bonding

Title - boring.


Slide 2: Interface Bonding

Under various names multi-rail has been a longstanding wishlist
item. The various names do imply technical differences in how people
think about the problem and the solutions they propose. Despite the
title of the presentation, this proposal is best characterized by
"multi-rail", which is the term we've been using internally at SGI.

Fujitsu contributed an implementation at the level of the infiniband
LND. It wasn't landed, and some of the reviewers felt that an LNet-
level solution should be investigated instead. This code was a big
influence on how I ended up approaching the problem.

The current proposal is a collaboration between SGI and Intel. There
is in fact a contract and resources have been committed. Whether the
implementation will match this proposal is still an open question:
these are the early days, and your feedback is welcome and can be
taken into account.

The end goal is general availability.


Slide 3: Why Multi-Rail?

At SGI we care because our big systems can have tens of terabytes of
memory, and therefore need a fat connection to the rest of a Lustre
cluster.

An additional complication is that big systems have an internal
"network" (NUMAlink in SGI's case) and it can matter a lot for
performance whether memory is close or remote to an interface. So what
we want is to have multiple interfaces spread throughout a system, and
then be able to use whichever will be most efficient for a particular
I/O operation.


Slide 4: Design Constraints

These are a couple of constraints (or requirements if you prefer) that
the design tries to satisfy.

Mixed-version clusters: it should not be a requirement to update an
entire cluster because of a few multi-rail capable nodes. Moreover, in
mixed- vendor situations, it may not be possible to upgrade an entire
cluster in one fell swoop.

Simple configuration: creating and distributing configuration files,
and then keeping them in sync across a cluster, becomes tricky once
clusters get bigger. So I look for ways to have the systems configure
themselves.

Adaptable: autoconfiguration is nice, but there are always cases where
it doesn't get things quite right. There have to be ways to fine-tune
a system or cluster, or even to completely override the
autoconfiguration.

LNet-level implementation: there are three levels at which you can
reasonably implement multi-rail: LND, LNet, and PortalRPC. An
LND-level solution has as its main disadvantage that you cannot
balance I/O load between LNDs. A PortalRPC-level solution would
certainly follow a commonly design tenet in networking: "the upper
layers will take care of that". The upper layers just want a reliable
network, thankyouverymuch. LNet seems like the right spot for
something like this. It allows the implementation to be reasonably
self-contained within the LNet subsystem.


Slide 5: Example Lustre Cluster

A simple cluster, used to guide the discussion. Missing in the picture
is the connecting fabric. Note that the UV client is much bigger than
the other nodes.


Slide 6: Mono-rail Single Fabric

The kind of fabric we have today. The UV is starved for I/O.


Slide 7: LNets in a Single Fabric

You can make additional interfaces in the UV useful by defining
multiple LNets in the fabric, and then carefully setting up aliases on
the nodes with only a single interface. This can be done today, but
setting this up correctly is a bit tricky, and involves cluster-wide
configuration. It is not something you'd like to have to retrofit top
an existing cluster.


Slide 8: Multi-rail Single Fabric

An example of a fabric topology that we want to work well. Some nodes
have multiple interfaces, and when they do they can all be used to
talk to the other nodes.


Slide 9: Multi-rail Dual Fabric

Similar to previous slide, but now with more LNets. Here too the goal
is active-active use of the LNets and all interfaces.


Slide 10: Mixed-Version Clusters

This section of the presentation expands on the first item of Slide 4.


Slide 11: A Single Multi-Rail Node

Assume we install multi-rail capable Lustre only on the UV. Would that
work? It turns out that it should actually work, though there are some
limits to the functionality. In particular, the MGS/MDS/OSS nodes will
not be aware that they know the UV by a number of NIDs, and it may be
best to avoid this by ensuring that the UV always uses the same
interface to talk to a particular node. This gives us the same
functionality as the multiple LNet example of Slide 7, but with a much
less complicated configuration.


Slide 12: Peer Version Discovery

A multi-rail capable node would like to know if any peer node is also
multi-rail capable. The LNet protocol itself isn't properly versioned,
but the LNet ping protocol (not to be confused with the ptlrpc
pinger!) does transport a feature flags field. There are enough bits
available in that field that we can just steal one and use it to
indicate multi-rail capability in a ping reply.

Note that a ping request does not carry any information beyond the
source NID of the requesting node. In particular, it cannot carry
version information to the node being pinged.


Slide 13: Peer Version Discovery

A simple version discovery protocol can be built on LNet ping.

    1) LNet keeps track of all known peers
    2) On first communication, do an LNet ping
    3) The node now knows the peer version

And we get a list of the peer's interfaces for free.


Slide 14: Easy Configuration

This section of the presentation expands on the second item of Slide 4.


Slide 15: Peer Interface Discovery

The list of interfaces of a peer is all we need to know for the simple
cases. With that we know the peer under all its aliases, and can
determine whether any of the other local interfaces (for example those
on different LNets) can talk to the same peer.

Now the peer also needs to know the node's interfaces. It would be
nice if there was a reliable way to get the peer to issue an LNet ping
to the node. For the most basic situation this works, but once I
looked at more complex situations it became clear that this cannot be
done reliably. So instead I propose to just have the node push a list
of its interfaces to the peer.


Slide 16: Peer Interface Discovery

The push of the list is much like an LNet ping, except it does an
LNetPut() instead of an LNetGet().

This should be safe on several grounds. An LNet router doesn't do deep
inspection of Put/Get requests, so even a downrev router will be able
to forward them. If such a Put somehow ends up at a downrev peer, the
peer will silently drop the message. (The slide says a protocol error
will be returned, which is wrong.)


Slide 17: Configuring Interfaces on a Node

How does a node know its own interfaces? This can be done in a way
similar to the current methods: kernel module parameters and/or
DLC. These use the same in-kernel parser, so the syntax is similar in
either case.

     networks=o2ib(ib0,ib1)

This is an example where two interfaces are used in the same LNet.

     networks=o2ib(ib0[2],ib1[6])[2,6]

The same example annotated with CPT information. This refers back to
Slide 3: on a big NUMA system it matters to be able to place the
helper threads for an interface close to that interface.

* Of course that information is also available in the kernel, and with
    a few extensions to the CPT mechanism, the kernel could itself find
    the node to which an interface is connected, then find the/a CPT
    that contains CPUs on that node.


Slide 18: Configuring Interfaces on a Node

LNet uses credits to determine whether a node can send something
across an interface or to a peer. These credits are assigned
per-interface, for both local and peer credits. So more interfaces
means more credits overall. The defaults for credit-related tunables
can stay the same. On LNet routers, which do have multiple interfaces,
these tunables are already interpreted per interface.


Slide 19: Dynamic Configuration

There is some scope for supporting hot-plugging interfaces. When
adding an interface, enable then push. When removing an interface,
push then disable.

Note that removing the interface with the NID by which a node is known
to the MGS (MDS/...) might not be a good idea. If additional
interfaces are present then existing connections can remain active,
but establishing new ones becomes a problem.

* This is a weakness of this proposal.


Slide 20: Adaptable

This section of the presentation expands on the third item of Slide 4.


Slide 21: Interface Selection

Selecting a local interface to send from, and a peer interface to send
to can use a number of rules.

- Direct connection preferred: by default, don't go through an LNet
    router unless there is no other path. Note that today an LNet router
    will refuse to forward traffic if it believes there is a direct
    connection between the node and the peer.

- LNet network type: since using TCP only is the default, it also
    makes sense to have a default rule that if a non-TCP network has been
    configured, then that network should be used first. (As with all such
    rules, it must be possible to override this default.)

- NUMA criteria: pick a local interface that (i) can reach the peer,
    (ii) is close to the memory used for the I/O, and (iii) close to the
    CPU driving the I/O.

- Local credits: pick a local interface depending on the availability
    of credits. Credits are a useful indicator for how busy an interface
    is. Systematically choosing the interface with the most available
    credits should get you something resembling a round-robin
    strategy. And this can even be used to balance across heterogeneous
    interfaces/fabrics.

- Peer credits: pick a peer interface depending on the availability of
    peer credits. Then pick a local interface that connects to this peer
    interface.

- Other criteria, namely...


Slice 22: Routing Enhancements

The fabric connecting nodes in a cluster can have a complicated
topology. So can have cases where a node has two interfaces N1,N2, and
a peer has two interfaces P1,P2, all on the same LNet, yet N1-P1 and
N2-P2 are preferred paths, while N1-P2 and N2-P1 should be avoided.

So there should be ways to define preferred point-to-point connections
within an LNet. This solves the N1-P1 problem mentioned above.

There also need to be ways to define a preference for using one LNet
over another, possibly for a subset of NIDs. This is the mechanism by
which the "anything but TCP" default can be overruled.

The existing syntax for LNet routing can easily(?) be extended to
cover these cases.


Slide 23: Extra Considerations

As you may have noticed, I'm looking for ways to be NUMA friendly. But
one thing I want to avoid is having Lustre nodes know too much about
the topology of their peers. How much is too much? I draw the line at
them knowing anything at all.

At the PortalRPC level each RPC is a request/response pair. (This in
contrast to the LNet level put/ack and get/reply pairs that make up
the request and the response.)

The PortalRPC layer is told the originating interface of a request. It
then sends the response to that same interface. The node sending the
request is usually a client -- especially when a large data transfer is
involved -- and this is a simple way to ensure that whatever NUMA-aware
policies it used to select the originating interface are also honored
when the response arrives.


Slide 24: Extra Considerations

If for some reason the peer cannot send a message to the originating
interface, then any other interface will do. This is an event worth
logging, as it indicates a malfunction somewhere, and after that just
keeping the cluster going should be the prime concern.

Trying all local-remote interface pairs might not be a good idea:
there can be too many combinations and the cumulative timeouts become
a problem.

To avoid timeouts at the PortalRPC level, LNet may already need to
start resending a message long before the "offical" below-LND-level
timeout for message arrival has expired.

The added network resiliency is limited. As noted for Slide 19, if the
interface that fails is has the NID by which a node is primarily
known, establishing new connections to that node becomes impossible.


Slide 25: Extra Considerations

Failing nodes can be used to construct some very creative
scenarios. For example if a peer reboots with downrev software LNet on
a node will not be able to tell by itself. But in this case the
PortalRPC layer can signal to LNet that it needs to re-check the peer.

NID reuse by different nodes is also a scenario that introduces a lot
complications. (Arguably it does do this already today.)

If needed, it might be possible to sneak a 32 bit identifying cookie
into the NID each node reports on the loopback network. Whether this
would actually be useful (and for that matter how such cookies would
be assigned) is not clear.


Slide 26: LNet-level Implementation

This section of the presentation expands on the fourth item of Slide 4.


Slide 27-29: Implementation Notes

A staccato of notes on how to implement bits and pieces of the above.
There's too much text in the slides already, so I'm not paraphrasing.


Slide 30: Implementation Notes

This slide gives a plausible way to cut the work into smaller pieces
that can be implemented as self-contained bits.

     1) Split lnet_ni
     2) Local interface selection
     *) Routing enhancements for local interface selection
     3) Split lnet_peer
     4) Ping on connect
     5) Implement push
     6) Peer interface selection
     7) Resending on failure
     8) Routing enhancements

There's of course no guarantee that this division will survive the
actual coding. But if it does, then note that after step 2 is
implemented, the configuration of Slide 11 (single multi-rail node)
should already be working.


Slide 31: Feedback & Discussion

Looking forward to further feedback & discussion here.


Slide 32:

End title - also boring.


Olaf

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696796
                            Veldzigt 2b       Fax:    +31(0)30-6696799
Sr Software Engineer       3454 PW de Meern  Vnet:   955-6796
Storage Software           The Netherlands   Email:  olaf at sgi.com
