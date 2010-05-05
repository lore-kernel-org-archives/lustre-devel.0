From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Wed, 05 May 2010 12:13:56 -0400
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <20100505154855.GY9429@oracle.com>
Message-ID: <201005051613.o45GDuqr009910@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> >I would think using VPN from outside into your Lustre-supplying LAN should
>> >be enough to work around this problem somewhat easily with no code changes.
>
>There's another option: make the gateway an LNet router.

Did you see my previous message about this?  That simply isn't an option
in many cases.

>> Sigh.  So, the official Oracle position in terms of LNet-NAT
>> compatibility is to basically give up?  If that's the answer, then I'll
>> shut up.  But really, do I have to justify this, or explain how VPNs
>> aren't always an option?
>
>I wouldn't say that's our "official" position.  For starters, you could
>file an RFE.  You could also contribute a fix.  But it won't be simple
>to fix.

Did you see my original message about this?  A simple fix (which I will
fully admit I only did an extremely brief amount of testing on) was
only six lines of changes.  Sure, it's not appropriate as general
changes to LNet, but I think making it configurable would be perfectly
reasonable.  But I wrote the code, so I will fully admit that I'm biased
about it.

>Lustre is layered above LNet, and LNet is layered above "LNDs", with
>each type of LND driving LNet over some type of network (IB, TCP/IP,
>...).  LNet has no concept of connections.
>[...]

I understand all of that.  Sure, it's easy to come up with cases where
this will fail.  But ... it looks like there are a few small changes
that can be made that will make it work in some circumstances, as
opposed to the current situation (where it will never work).  Maybe I'm
wrong and further testing will reveal that this is a lot more
complicated to make it work in even the simple case, but it seems a
shame to not even investigate further.  But it seems the feedback I'm
getting from the people at Oracle is, "Meh, don't bother".

>The fix, if it's at all possible, would require that clients's socklnds
>try to keep TCP connections open at all times to all nodes that the
>client has spoken to in the past.  That's pretty heavy-weight.

Actually, I will freely confess to not being the LNet expert ... but
are socklnd TCP connections closed now when clients are idle?  With the
pinger running (which is a requirement, from what I understand), it seems
like you'd have a TCP connection going all of the time beween all clients
and servers.  The pinger sends a packet every 20-25 seconds, right?

--Ken
