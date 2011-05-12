From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 12 May 2011 10:37:51 -0700
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <4DCBF565.3060602@cray.com>
References: <4DCBF565.3060602@cray.com>
Message-ID: <4DCC1AEF.8020705@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think Eric's approach is the only sane way I've heard to reduce pings.

Here are some issues that I see with this:

1)  For your solution to work, you require that the lnet layer take on 
pinging duties.  Usually the network, be it IB, TCP, whatever, will not 
provide any active notification of a peer failure.  To notice that a 
peer has died, the lnet LND must, you guessed it, ping.

Usually the LNDs try to be smart.  They only generate their own pings if 
no traffic has been sent to the peer in a certain period of time.  So 
once you eliminate the higher-level pings, they will partly be replaced 
by lower-level pings.

2)  Doesn't work in a routed environment.  Would need a health network 
for clients behind routers to learn that a server has died, and vice versa.

On 05/12/2011 07:57 AM, Nic Henke wrote:
> Just floating an idea... I'd much appreciate any feedback
>
> Given bug 12471 where the ptlrpc pinger traffic on a large system can
> approach the ridiculous (2.6M pings every 75s for 160 OSTs and 16K
> clients), I'd like to consider getting rid of the pings entirely.
>
> The idea would be to extend the idea in the attached patch where we add
> an upper layer callback for lnet_notify() signaling a peer going down or
> up. The ptlrpc pinger code would be then changed to record the 'down'
> event for an import/export which would then start an eviction timer that
> started when the LNet peer was last_alive. If the nodes comes 'up'
> before the timer expires, no eviction. The eviction code would then only
> operate on nodes with 'down' events and trusting that the rest are all
> ok and functional.
>
> Eric - I know this doesn't get us that far down the road toward your new
> health network, but does solve a near term issue with pinger rates on
> large systems.
>
> Issues...
>
> - lacks "proof" that peer nodes ptlrpc queues are moving forward, but
> not really sure that is all that important in terms of pinger evictions.
>
> - LNet peer health is a bit "weird" in that it requires an upper layer
> sending a packet to trigger a node moving back to 'up'. We would need to
> address this for proper LNet peer health as it is.
>
> - Might need some beefing up of the standard LNDs to ensure we have good
> peer health data.
>
> Thoughts ?
>
> Nic
