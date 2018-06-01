From: NeilBrown <neilb@suse.com>
Date: Sat, 02 Jun 2018 09:19:40 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <29ACF5A8-7608-46BB-8191-E3FEB77D0F24@cray.com>
References: <20180601091133.GA27521@kroah.com>
 <20180601114151.GA25225@infradead.org>
 <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
 <29ACF5A8-7608-46BB-8191-E3FEB77D0F24@cray.com>
Message-ID: <87h8mmrt6b.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <doucharek@cray.com>, Andreas Dilger <adilger@dilger.ca>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, "selinux@tycho.nsa.gov" <selinux@tycho.nsa.gov>, fsdevel <linux-fsdevel@vger.kernel.org>, lustre-devel <lustre-devel@lists.lustre.org>

On Fri, Jun 01 2018, Doug Oucharek wrote:

> Would it makes sense to land LNet and LNDs on their own first?  Get
> the networking house in order first before layering on the file
> system?

I'd like to turn that question on it's head:
  Do we need LNet and LNDs?  What value do they provide?
(this is a genuine question, not being sarcastic).

It is a while since I tried to understand LNet, and then it was a
fairly superficial look, but I think it is an abstraction layer
that provides packet-based send/receive with some numa-awareness
and routing functionality.  It sits over sockets (TCP) and IB and
provides a uniform interface.

That is almost a description of the xprt layer in sunrpc.  sunrpc
doesn't have routing, but it does have some numa awareness (for the
server side at least) and it definitely provides packet-based
send/receive over various transports - tcp, udp, local (unix domain),
and IB.
So: can we use sunrpc/xprt in place of LNet?  How much would we need to
enhance sunrpc/xprt for this to work?  What hooks would be needed to
implement the routing as a separate layer.

If LNet is, in some way, much better than sunrpc, then can we share that
superior functionality with our NFS friends by adding it to sunrpc?

Maybe the answer to this is "no", but I think LNet would be hard to sell
without a clear statement of why that was the answer.

One reason that I would like to see lustre stay in drivers/staging (so I
do not support Greg's patch) is that this sort of transition of Lustre
to using an improved sunrpc/xprt would be much easier if both were in
the same tree.  Certainly it would be easier for a larger community to
be participating in the work.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180602/953bfcbc/attachment.sig>
