From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Thu, 06 May 2010 17:31:55 +0800
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <16BE2AB9-4948-4506-8ED7-B05BD6DBE305@dilger.ca>
References: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
	<16BE2AB9-4948-4506-8ED7-B05BD6DBE305@dilger.ca>
Message-ID: <4BE28C8B.1070100@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ken, Andreas,

Thanks for diving into code, :).
As Andreas said, these changes may break rule of router easily (or 
multiple interfaces setting in the future), so we have to be very 
careful. Also, we may need more changes inside LNDs, I believe we have 
more checking there.

More interesting, I think you are using internal address to start LNet 
on client, but servers are using external address to talk back to your 
client (as you said, there is a message like : bad dst nid 1.2.3.4 at tcp, 
which is external address). It's supposed to be broken at somewhere 
because the socklnd connection should use source address in message 
header which is internal (client should never know about the external 
address),  but obviously it didn't, so I guess we probably have a 
loophole in socklnd to even allow this happen, I will dig into code later.
 
Anyway, you've already hacked out and it works fine,  so although need 
more survey, I tend to agree it's possible for us to make this tunable 
and bypass those checking at least for  LNet + socklnd,  if you don't 
really care about server-client reconnection (Andreas, yes that's what I 
meant)  and believe supporting one client with single NI behind NAT is 
an important use-case even with limitations.

Thanks
Liang


Andreas Dilger wrote:
> On 2010-05-05, at 08:38, Ken Hornstein wrote:
>   
>> So, I did a little more work on this last night.  And I respectfully
>> disagree it would be hard to make those things tunable.  In fact, I
>> got Lustre working fine with a few simple client-only changes.
>>
>> I ran into two issues.  First, in lib-move.c:lnet_parse(), the variable
>> for_me is set if the network interface nid matches the destination nid.
>> I simply set for_me to 1 all of the time, and that solved that problem.
>> That's a one-line change, and it would be easy to make that tunable.
>>     
>
> The problem with setting "for_me = 1" all the time is that this would apparently break LNET routers completely because they would always think that the incoming message is for them, rather than something to be passed on to another peer (i.e. the "if (!the_lnet.ln_routing)" case).
>
> It seems that if the "extra" error checks in the "if (!for_me)" code were instead moved earlier and set "for_me = 1" it might be OK:
>
>        if (LNET_NIDNET(dest_nid) == LNET_NIDNET(ni->ni_nid)) {
>                 /* should have gone direct */
>                 for_me = 1;
>        } else if (lnet_islocalnid(dest_nid)) {
>                 /* dest is another local NI; sender should have used
>                  * this node's NID on its own network */
>                 for_me = 1;
>        }
>
> There still remains the issue with server-client reconnection, which will fail utterly for a NAT address, but as you wrote in another email, the pinger should keep the TCP connection open by virtue of sending messages often enough, or re-establish the connection if it fails.  There exists some possibility that the client could be evicted if the connection was lost at the time a lock callback was sent and the server couldn't re-establish the connection, but if you don't require 100% robustness (which you can't from Starbuck's WIFI anyway) then that is probably an acceptable outcome.
>
> That said, take this answer with a pile of salt, I'm not an LNET expert at all and I'm just poking around here as you are.  I trust Liang and Isaac with the LNET code totally, and if they tell me this is fundamentally broken, then I'll believe them.  It may be that Liang was referring to the server-client reconnection issue when he wrote that it couldn't be done easily, but I'll let him clarify in his own words.
>
> Cheers, Andreas
> Just some guy poking in LNET
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
