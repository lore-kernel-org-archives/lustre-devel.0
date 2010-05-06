From: Andreas Dilger <adilger@dilger.ca>
Date: Thu, 6 May 2010 02:02:12 -0400
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
References: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
Message-ID: <16BE2AB9-4948-4506-8ED7-B05BD6DBE305@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-05-05, at 08:38, Ken Hornstein wrote:
> So, I did a little more work on this last night.  And I respectfully
> disagree it would be hard to make those things tunable.  In fact, I
> got Lustre working fine with a few simple client-only changes.
> 
> I ran into two issues.  First, in lib-move.c:lnet_parse(), the variable
> for_me is set if the network interface nid matches the destination nid.
> I simply set for_me to 1 all of the time, and that solved that problem.
> That's a one-line change, and it would be easy to make that tunable.

The problem with setting "for_me = 1" all the time is that this would apparently break LNET routers completely because they would always think that the incoming message is for them, rather than something to be passed on to another peer (i.e. the "if (!the_lnet.ln_routing)" case).

It seems that if the "extra" error checks in the "if (!for_me)" code were instead moved earlier and set "for_me = 1" it might be OK:

       if (LNET_NIDNET(dest_nid) == LNET_NIDNET(ni->ni_nid)) {
                /* should have gone direct */
                for_me = 1;
       } else if (lnet_islocalnid(dest_nid)) {
                /* dest is another local NI; sender should have used
                 * this node's NID on its own network */
                for_me = 1;
       }

There still remains the issue with server-client reconnection, which will fail utterly for a NAT address, but as you wrote in another email, the pinger should keep the TCP connection open by virtue of sending messages often enough, or re-establish the connection if it fails.  There exists some possibility that the client could be evicted if the connection was lost at the time a lock callback was sent and the server couldn't re-establish the connection, but if you don't require 100% robustness (which you can't from Starbuck's WIFI anyway) then that is probably an acceptable outcome.

That said, take this answer with a pile of salt, I'm not an LNET expert at all and I'm just poking around here as you are.  I trust Liang and Isaac with the LNET code totally, and if they tell me this is fundamentally broken, then I'll believe them.  It may be that Liang was referring to the server-client reconnection issue when he wrote that it couldn't be done easily, but I'll let him clarify in his own words.

Cheers, Andreas
Just some guy poking in LNET
