From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Tue, 04 May 2010 10:19:37 -0400
Subject: [Lustre-devel] lnet NAT friendliness
Message-ID: <201005041419.o44EJbee026119@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In my work with the MacOS X client, I did some work from home.  While
that had the added "benefit" of exposing the issues associated with the
lack of attribute caching from the MacOS X client, I noticed something
else: lnet is unfortunately rather NAT-unfriendly.

Obviously putting your servers behind a NAT is extremely challenging, but
I was operating in the not-so-uncommon situation where a client was behind
a NAT and the servers all had publically routable IP addresses.  Note that
I am aware that by default Lustre requires connections from reserved ports;
I worked around that issue (until I discovered the way to turn off that
check via a configuration knob).

Specifically, I can connect to the MGS okay, but after that initial
connection I get the following error from lnet_parse() on the client
(okay, I reconstructed this from memory, but I think it is reasonably
close)

src server.addr at tcp: bad dest nid 1.2.3.4 at tcp (should have been sent direct)

Where "1.2.3.4 at tcp" is the external address of my NAT box at home.  It
is worth noting that there are no other known networking issues with
this setup; if I put this machine on the external-facing network, I can
mount the Lustre filesystem in queston fine.

Obviously the problem here is that a message is being sent to my home
box, but instead of using the "internal" IP address as the destination NID,
the server is using the external address (the one it obviously is getting
from the TCP socket).

I haven't yet had a chance to play with this more, but it makes me wonder
if anyone else has tried out Lustre from behind a NAT (with 2.0-based
Lustre, obviously), and if they did, did it work for you?  I am perfectly
willing to believe this is an issue with the Mac client, but from looking
at the code it doesn't feel like it would be.

Also ... it seems like it would be easy to add a configuration knob that
would let you bypass this particular check, and that might make it work.
Anyone have any thoughts about that?

--Ken
