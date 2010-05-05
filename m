From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Wed, 05 May 2010 08:38:58 -0400
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <4BE15CCF.5080308@sun.com>
Message-ID: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>LNet requires destination address of message to be same with address of 
>LNet NI (unless it's a router), I'm afraid it's not easy to make it  be 
>tunable.
>
>I would suggest to run lustre (lnet) router on the gateway (if your 
>gateway is Linux...)

Well, that's not really feasible, because a) many times we don't
control the gateway (think sitting in Starbucks; and while some people
would say that they don't want to use Lustre from Starbucks, I would
say, "Why not?"; with Kerberos authentication, I think it would be
perfectly reasonable), and b) even if you control the gateway, that
doesn't really scale, because while that might work for one person,
I don't see how you would do it for more than one person (how would
you configure the routing back if more than one person are using the
same NAT address range?).

I admit I have no love for NAT and I would prefer it if we were living
in a world where the end-to-end principle worked everywhere, but that
battle was lost years ago.

So, I did a little more work on this last night.  And I respectfully
disagree it would be hard to make those things tunable.  In fact, I
got Lustre working fine with a few simple client-only changes.

I ran into two issues.  First, in lib-move.c:lnet_parse(), the variable
for_me is set if the network interface nid matches the destination nid.
I simply set for_me to 1 all of the time, and that solved that problem.
That's a one-line change, and it would be easy to make that tunable.

However, that exposed another problem.  lnet_nid2ni_locked() would then
fail because it would try to look up the network interface associated
with the "external" address (I don't remember exactly who called this
right now, but I suppose it doesn't matter).  You have to be more
careful here, because if you just make lnet_nid2ni_locked() return the
first match you end up returning the loopback interface and that makes
other things unhappy.  What I settled on was just matching the first
interface that had the same network and type.

I made these two changes, and Lustre worked fine.  Okay, it wasn't
exactly an exhaustive test: I cd'd to the filesystem and ran "ls -l".
As noted before, the Lustre MacOS X client doesn't do any caching yet
so issues with AST notifications may come up.  But I think this shows
that making Lustre clients work from behind a NAT is not a set of huge
changes, at least for the simple case.

Are these changes appropriate for the general case?  No, and I wouldn't
suggest otherwise.  But I think the case of a client with a single
network interface from behind a NAT, these changes are reasonable; if
they are made tunable and default to being off, I can't see how it
would be harmful, and it might actually help some people.  I admit that
it occurs to me that I don't know what would happen if more than one
Lustre client was behind the same NAT in this situation.

--Ken
