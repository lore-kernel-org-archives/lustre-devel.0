From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sun, 3 Jun 2018 20:34:52 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <87h8mmrt6b.fsf@notabene.neil.brown.name>
References: <20180601091133.GA27521@kroah.com>
 <20180601114151.GA25225@infradead.org>
 <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
 <29ACF5A8-7608-46BB-8191-E3FEB77D0F24@cray.com>
 <87h8mmrt6b.fsf@notabene.neil.brown.name>
Message-ID: <58123CDD-8424-4E1D-A11F-0F899970A49B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Doug Oucharek <doucharek@cray.com>, Andreas Dilger <adilger@dilger.ca>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Christoph Hellwig <hch@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "selinux@tycho.nsa.gov" <selinux@tycho.nsa.gov>, fsdevel <linux-fsdevel@vger.kernel.org>, lustre-devel <lustre-devel@lists.lustre.org>

On Jun 1, 2018, at 17:19, NeilBrown <neilb@suse.com> wrote:
> 
> On Fri, Jun 01 2018, Doug Oucharek wrote:
> 
>> Would it makes sense to land LNet and LNDs on their own first?  Get
>> the networking house in order first before layering on the file
>> system?
> 
> I'd like to turn that question on it's head:
>  Do we need LNet and LNDs?  What value do they provide?
> (this is a genuine question, not being sarcastic).
> 
> It is a while since I tried to understand LNet, and then it was a
> fairly superficial look, but I think it is an abstraction layer
> that provides packet-based send/receive with some numa-awareness
> and routing functionality.  It sits over sockets (TCP) and IB and
> provides a uniform interface.

LNet is originally based on a high-performance networking stack called
Portals (v3, http://www.cs.sandia.gov/Portals/), with additions for LNet
routing to allow cross-network bridging.

A critical part of LNet is that it is for RDMA and not packet-based
messages.  Everything in Lustre is structured around RDMA.  Of course,
RDMA is not possible with TCP so it just does send/receive under the
covers, though it can do zero copy data sends (and at one time zero-copy
receives, but those changes were rejected by the kernel maintainers).
It definitely does RDMA with IB, RoCE, OPA in the kernel, and other RDMA
network types not in the kernel (e.g. Cray Gemini/Aries, Atos/Bull BXI,
and previously older network types no longer supported).

Even with TCP it has some improvements for performance, such as using
separate sockets for send and receive of large messages, as well as
a socket for small messages that has Nagle disabled so that it does
not delay those packets for aggregation.

In addition to the RDMA support, there is also multi-rail support in
the out-of-tree version that we haven't been allowed to land, which
can aggregate network bandwidth.  While there exists channel bonding
for TCP connections, that does not exist for IB or other RDMA networks.

> That is almost a description of the xprt layer in sunrpc.  sunrpc
> doesn't have routing, but it does have some numa awareness (for the
> server side at least) and it definitely provides packet-based
> send/receive over various transports - tcp, udp, local (unix domain),
> and IB.
> So: can we use sunrpc/xprt in place of LNet?

No, that would totally kill the performance of Lustre.

> How much would we need to enhance sunrpc/xprt for this to work?  What
> hooks would be needed to implement the routing as a separate layer.
> 
> If LNet is, in some way, much better than sunrpc, then can we share that
> superior functionality with our NFS friends by adding it to sunrpc?

There was some discussion at NetApp about adding a Lustre/LNet transport
for pNFS, but I don't think it ever got beyond the proposal stage:

https://tools.ietf.org/html/draft-faibish-nfsv4-pnfs-lustre-layout-07

> Maybe the answer to this is "no", but I think LNet would be hard to sell
> without a clear statement of why that was the answer.

There are other users outside of the kernel tree that use LNet in addition
to just Lustre.  The Cray "DVS" I/O forwarding service[*] uses LNet, and
another experimental filesystem named Zest[+] also used LNet.

[*] https://www.alcf.anl.gov/files/Sugiyama-Wallace-Thursday16B-slides.pdf
[+] https://www.psc.edu/images/zest/zest-sc07-paper.pdf

> One reason that I would like to see lustre stay in drivers/staging (so I
> do not support Greg's patch) is that this sort of transition of Lustre
> to using an improved sunrpc/xprt would be much easier if both were in
> the same tree.  Certainly it would be easier for a larger community to
> be participating in the work.

I don't think the proposal to encapsulate all of the Lustre protocol into
pNFS made a lot of sense, since this would have only really been available
on Linux, at which point it would be better to use the native Lustre client
rather than funnel everything through pNFS.

However, _just_ using the LNet transport for (p)NFS might make sense.  LNet
is largely independent from Lustre (it used to be a separate source tree)
and is very efficient over the network.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
