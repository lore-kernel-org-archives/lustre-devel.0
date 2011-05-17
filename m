From: Nic Henke <nic@cray.com>
Date: Tue, 17 May 2011 09:27:43 -0500
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <9BC94E70-4EB6-49D9-8AA1-B07E1455E51D@whamcloud.com>
References: <4DCBF565.3060602@cray.com>
	<9BC94E70-4EB6-49D9-8AA1-B07E1455E51D@whamcloud.com>
Message-ID: <4DD285DF.2000700@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/12/2011 12:27 PM, Andreas Dilger wrote:
> On May 12, 2011, at 08:57, Nic Henke wrote:
>> Just floating an idea... I'd much appreciate any feedback
>>

> One issue is that the Lustre OBD_PING RPC is not just detecting peer
> death.  It is also reporting the last_committed value to the RPC
> stack, so that clients can discard RPCs that were committed on the
> server.  It is also signalling to the server that this client is
> still alive, so that it doesn't get evicted.  If there are LNET
> routers in a system, the LNET peer health will only report the health
> of the routers, and not of the clients or servers behind the routers,
> so this isn't going to result in a working Lustre filesystem...
>

Good point, I had missed this. Pesky "working" filesystems...

>> Eric - I know this doesn't get us that far down the road toward
>> your new health network, but does solve a near term issue with
>> pinger rates on large systems.
>
> There would need to be at least some of the health network
> implemented in order to "pass through" the peer health on the
> routers, and also to broadcast some of the data, like last_rcvd.

Yeah, not sure how I thinko'd the LNet Router case. We'd need to add 
.lnd_notify into the LNDs and have them broadcast the failures at the 
router level. Not exactly ideal, and I think the use of lnd_notify has 
been dropped in favor of the newer LNet Peer Health.

Cheers,
Nic
