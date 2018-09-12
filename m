From: NeilBrown <neilb@suse.com>
Date: Wed, 12 Sep 2018 12:16:27 +1000
Subject: [lustre-devel] [PATCH 09/34] lnet: add list of cpts to lnet_net.
In-Reply-To: <5BB5FEA0-B2F8-4F61-8697-EB96B1CAAC92@cray.com>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137159.8267.921309094971745898.stgit@noble>
 <5BB5FEA0-B2F8-4F61-8697-EB96B1CAAC92@cray.com>
Message-ID: <87pnxjqx38.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 10 2018, Doug Oucharek wrote:

> I agree with a comment from James Simmons: __u32 should only be used when the variable is being shared with user space.  We need to start converting all uses of __uXX in LNet to just uXX.  Perhaps that should be a set of future patches once all of MR/DD has landed?
>

That seems reasonable.  I dont't think this series adds significant new
uses of __u32.
Changing them all to u32 should, as you suggest, come later.

> Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180912/5da806f7/attachment.sig>
