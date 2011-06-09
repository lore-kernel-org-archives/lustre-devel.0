From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 9 Jun 2011 15:38:11 +0100
Subject: [Lustre-devel] discontiguous kiov pages
In-Reply-To: <58BFE163-3240-4C11-9088-6ABB05EB4646@whamcloud.com>
References: <4DE6F67B.6040207@cray.com>
	<002c01cc2127$ac5b7da0$051278e0$@com>	<B91FC92C-00B4-4C0B-A0D1-DA2E6912697D@whamcloud.com>	<4DEF9E8F.6070202@cray.com>
	<58BFE163-3240-4C11-9088-6ABB05EB4646@whamcloud.com>
Message-ID: <00f101cc26b2$dce80890$96b819b0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It seems to me that Jay's suggestion to put the niobufs into
separate RPCs is a good one - particularly since writing the 2nd
niobuf should only be attempted after the first to ensure the
file size is set correctly (BTW this means the 2nd RPC cannot
be posted until the first has completed - otherwise the RPCs
could get re-ordered in the network or at the server).  

However it would be nice to aggregate small, possibly unrelated
I/Os and if/when we do that this issue will crop up again.  If
we stick with the rule that MDs cannot have internal partial pages,
we're forced to use 1 MD for each niobuf.  Putting several of these
in 1 RPC requires separate matchbits for each niobuf to ensure
correct match of source and sink buffers independent of races in
the network.  This must be more efficient than scheduling multiple 
concurrent RPCs each with 1 niobuf, but by how much isn't clear,
since the bulk transfer phases of both schemes should cause identical
network traffic.  

So aggregation will probably require LNET/LND support for MDs with
internal partial pages.  At a guess, this will have strict limits
for some LNDs and probably can't be done without reducing the total
number of fragments in such messages.  Also, the interaction with
LNET routers needs to be considered since mismatched RDMA descriptors
can potentially double the number of actual RDMA fragments on the
wire.

          Cheers,
                   Eric
