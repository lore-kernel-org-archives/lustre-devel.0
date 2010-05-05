From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 5 May 2010 10:48:55 -0500
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <201005051531.o45FVdNN009323@hedwig.cmf.nrl.navy.mil>
References: <E605710A-EB8D-4B51-8B1D-F3FECEA67045@oracle.com>
	<201005051531.o45FVdNN009323@hedwig.cmf.nrl.navy.mil>
Message-ID: <20100505154855.GY9429@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, May 05, 2010 at 11:31:39AM -0400, Ken Hornstein wrote:
> >I would think using VPN from outside into your Lustre-supplying LAN should
> >be enough to work around this problem somewhat easily with no code changes.

There's another option: make the gateway an LNet router.

> Sigh.  So, the official Oracle position in terms of LNet-NAT
> compatibility is to basically give up?  If that's the answer, then I'll
> shut up.  But really, do I have to justify this, or explain how VPNs
> aren't always an option?

I wouldn't say that's our "official" position.  For starters, you could
file an RFE.  You could also contribute a fix.  But it won't be simple
to fix.

Lustre is layered above LNet, and LNet is layered above "LNDs", with
each type of LND driving LNet over some type of network (IB, TCP/IP,
...).  LNet has no concept of connections.  Therefore the state of TCP
connections created by socklnd (the name of the TCP/IP LND) is
completely irrelevant to LNet.  Which means that when some server has to
send a message to a client... the server might have to establish a TCP
connection (or three) with the client, which means... that the server
must know how to connect to the client, and that is completely firewall-
unfriendly.  Note too that LNet has no idea about the state of the
services layered above it, so the socklnd cannot know if a particular
peer will be needing to send messages, so as to proactively maintain TCP
connections open with them so as to be able to receive those messages --
it can only assume.

The very statelessness of LNet makes NAT- and firewall-friendly-ness a
difficult proposition.

The fix, if it's at all possible, would require that clients's socklnds
try to keep TCP connections open at all times to all nodes that the
client has spoken to in the past.  That's pretty heavy-weight.  Consider
too that a server is usually also a client: socklnd shouldn't behave
that way in all cases, just in the cases of pure clients behind NATs.
The fix might also require changes to timeout handling, and/or maybe
even to LNet itself (to at least have a notion of peer node reachability
event notification, or something of the sort).

Nico
-- 
