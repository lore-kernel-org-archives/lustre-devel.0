From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 12 May 2011 11:27:00 -0600
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <4DCBF565.3060602@cray.com>
References: <4DCBF565.3060602@cray.com>
Message-ID: <9BC94E70-4EB6-49D9-8AA1-B07E1455E51D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 12, 2011, at 08:57, Nic Henke wrote:
> Just floating an idea... I'd much appreciate any feedback
> 
> Given bug 12471 where the ptlrpc pinger traffic on a large system can approach the ridiculous (2.6M pings every 75s for 160 OSTs and 16K clients), I'd like to consider getting rid of the pings entirely.
> 
> The idea would be to extend the idea in the attached patch where we add an upper layer callback for lnet_notify() signaling a peer going down or up. The ptlrpc pinger code would be then changed to record the 'down' event for an import/export which would then start an eviction timer that started when the LNet peer was last_alive. If the nodes comes 'up' before the timer expires, no eviction. The eviction code would then only operate on nodes with 'down' events and trusting that the rest are all ok and functional.

One issue is that the Lustre OBD_PING RPC is not just detecting peer death.  It is also reporting the last_committed value to the RPC stack, so that clients can discard RPCs that were committed on the server.  It is also signalling to the server that this client is still alive, so that it doesn't get evicted.  If there are LNET routers in a system, the LNET peer health will only report the health of the routers, and not of the clients or servers behind the routers, so this isn't going to result in a working Lustre filesystem...

> Eric - I know this doesn't get us that far down the road toward your new health network, but does solve a near term issue with pinger rates on large systems.

There would need to be at least some of the health network implemented in order to "pass through" the peer health on the routers, and also to broadcast some of the data, like last_rcvd.

> Issues...
> 
> - lacks "proof" that peer nodes ptlrpc queues are moving forward, but not really sure that is all that important in terms of pinger evictions.
> 
> - LNet peer health is a bit "weird" in that it requires an upper layer sending a packet to trigger a node moving back to 'up'. We would need to address this for proper LNet peer health as it is.
> 
> - Might need some beefing up of the standard LNDs to ensure we have good peer health data.
> 
> Thoughts ?
> 
> Nic
> <register_notify.diff>_______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
