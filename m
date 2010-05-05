From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 5 May 2010 11:32:45 -0500
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <201005051613.o45GDuqr009910@hedwig.cmf.nrl.navy.mil>
References: <20100505154855.GY9429@oracle.com>
	<201005051613.o45GDuqr009910@hedwig.cmf.nrl.navy.mil>
Message-ID: <20100505163245.GA9429@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, May 05, 2010 at 12:13:56PM -0400, Ken Hornstein wrote:
> >> >I would think using VPN from outside into your Lustre-supplying LAN should
> >> >be enough to work around this problem somewhat easily with no code changes.
> >
> >There's another option: make the gateway an LNet router.
> 
> Did you see my previous message about this?  That simply isn't an option
> in many cases.

Yes, I did, but I was just adding a workaround that might work for
others (it might not -- haven't tested it).

> >I wouldn't say that's our "official" position.  For starters, you could
> >file an RFE.  You could also contribute a fix.  But it won't be simple
> >to fix.
> 
> Did you see my original message about this?  A simple fix (which I will
> fully admit I only did an extremely brief amount of testing on) was
> only six lines of changes.  Sure, it's not appropriate as general
> changes to LNet, but I think making it configurable would be perfectly
> reasonable.  But I wrote the code, so I will fully admit that I'm biased
> about it.

I did see that.  I hadn't followed it in detail, but just now I looked
at the code you mentioned, and, on a pure client I think that makes
sense.  See below.

>                                 [...].  But it seems the feedback I'm
> getting from the people at Oracle is, "Meh, don't bother".

Well, we (or our customers) might have no use for it at this time; or
perhaps it's just NAT hatred running in our veins (just kidding, though
I suspect most people who've come in contact with NAT love/hate it).
Doesn't mean we wouldn't take patches, or that we'd never have a use for
it.  But the first priority is to make sure that the fix, if you'll
contribute one, is sufficiently robust.  See below.

> >The fix, if it's at all possible, would require that clients's socklnds
> >try to keep TCP connections open at all times to all nodes that the
> >client has spoken to in the past.  That's pretty heavy-weight.
> 
> Actually, I will freely confess to not being the LNet expert ... but
> are socklnd TCP connections closed now when clients are idle?  With the
> pinger running (which is a requirement, from what I understand), it seems
> like you'd have a TCP connection going all of the time beween all clients
> and servers.  The pinger sends a packet every 20-25 seconds, right?

Perhaps my "that's pretty heavy-weight" comment was off the mark.
However, I know very little about socklnd, and the key is to make sure
it proactively re-connects in the face of timeouts so that servers can
always send messages to the NATted clients.

Nico
-- 
