From: Isaac Huang <He.Huang@Sun.COM>
Date: Tue, 24 Feb 2009 14:09:16 -0500
Subject: [Lustre-devel] Credits, peer credits and concurrent sends
In-Reply-To: <FCCFA143-03D6-45C3-93EC-61F106BF8193@myri.com>
References: <FCCFA143-03D6-45C3-93EC-61F106BF8193@myri.com>
Message-ID: <20090224190916.GA12305@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Feb 24, 2009 at 01:32:25PM -0500, Scott Atchley wrote:
> Hi all,
> 
> I am updating MXLND. I am looking at O2IBLND as a reference and I am  
> wondering what is the difference between the above module parameters?
> 
> The o2iblnd_modparams.c file has:
> 
> static int credits = 64;
> CFS_MODULE_PARM(credits, "i", int, 0444,
>                  "# concurrent sends");
> 
> static int peer_credits = 8;
> CFS_MODULE_PARM(peer_credits, "i", int, 0444,
>                  "# concurrent sends to 1 peer");

These two controls LNet-layer send credits - how many LNet messages
could be sent concurrently over a NI and a peer, respectively.

> #if IBLND_MAP_ON_DEMAND
> static int concurrent_sends = IBLND_RX_MSGS;
> #else
> static int concurrent_sends = IBLND_MSG_QUEUE_SIZE;
> #endif
> CFS_MODULE_PARM(concurrent_sends, "i", int, 0444,
>                  "send work-queue sizing");
> 
> where IBLND_MSG_QUEUE_SIZE is 8.

The concurrent_sends controls the number of o2iblnd messages that
could be posted to a connection (and its QP) concurrently.

The difference between LNet messages and o2iblnd messages is: 1. A
LNet message is usually transfered by several o2iblnd messages (e.g.
setting up RDMA transfer). 2. Some o2iblnd messages have nothing to do
with LNet-layer messages (e.g. NOOP, which carries LND credits and
keepalive data).

The reason why we must limit the number of concurrent o2iblnd messages 
posted to a connection is very specific to this LND - it has something
to do with RDMA fragments and QP and CQ sizing. I wouldn't elaborate,
unless you're very interested, because it only applies to the o2iblnd
and probably wouldn't be an issue for the MXLND.

The peer_credits alone couldn't limit the concurrent o2iblnd messages
because some o2iblnd messages (like PUT_ACK, GET_DONE) are responses
to peer's requests and are thus not limited by LNet peer tx credits at
my side.

That's why we had to add concurrent_sends.

> Can anyone elaborate on differences and relationships (e.g. what does  
> it mean if concurrent_sends is greater than peer_credits or is that  
> not allowed)?

In theory, it's possible. It simply means that concurrent o2iblnd
messages allowed is more than concurrent LNet messages allowed.

On the other hand, some LNDs (like the o2iblnd) also implements
LND-layer tx credits, which seems very confusing together with the
LNet tx credits. One important difference between the two is, LNet tx
credits are returned when send operations complete locally and the
local message buffer could be reused, while LND tx credits are returned
by peers over the wire when my peers have reposted their receive buffers.
In short, LND tx credits usually protects remote buffers and LNet tx
credits prevent LNet from overcommitting an interface or a peer.

Hope this helps,
Isaac
