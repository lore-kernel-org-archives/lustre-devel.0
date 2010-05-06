From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 06 May 2010 10:35:09 -0400
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <4BE28C8B.1070100@sun.com>
Message-ID: <201005061435.o46EZ9es021091@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Thanks for diving into code, :).
>As Andreas said, these changes may break rule of router easily (or 
>multiple interfaces setting in the future), so we have to be very 
>careful. Also, we may need more changes inside LNDs, I believe we have 
>more checking there.

Right, that's why I would only advocate turning off of those checks
conditionally on standalone clients.

>More interesting, I think you are using internal address to start LNet 
>on client, but servers are using external address to talk back to your 
>client (as you said, there is a message like : bad dst nid 1.2.3.4 at tcp, 
>which is external address). It's supposed to be broken at somewhere 
>because the socklnd connection should use source address in message 
>header which is internal (client should never know about the external 
>address),  but obviously it didn't, so I guess we probably have a 
>loophole in socklnd to even allow this happen, I will dig into code later.

From what I can tell (again, not being the LNet expert), the server
knows what the real address of the remote connection is (the external
address), but it associates a particular TCP connection with a NID
(which has the internal address), and it uses that TCP connection when
it wants to talk to the NID.  So it all ends up working out, even though
in theory it shouldn't.

>Anyway, you've already hacked out and it works fine,  so although need 
>more survey, I tend to agree it's possible for us to make this tunable 
>and bypass those checking at least for  LNet + socklnd,  if you don't 
>really care about server-client reconnection (Andreas, yes that's what I 
>meant)  and believe supporting one client with single NI behind NAT is 
>an important use-case even with limitations.

Actually, now that I think more about it, more than one client behind a
NAT might actually work fine.  What will probably fail is two clients
behind two different NATs but having the same internal address.

Let me code up a cleaner version of this patch (and make it adjustable)
and see how that works out.

--Ken
