From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 09:50:38 +1000
Subject: [lustre-devel] [PATCH 09/24] lustre: don't use spare bits in
 iattr.ia_valid
In-Reply-To: <alpine.LFD.2.21.1806242129180.28698@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669036.10587.17899565981649604892.stgit@noble>
 <alpine.LFD.2.21.1806210233170.3886@casper.infradead.org>
 <87fu1gdb4w.fsf@notabene.neil.brown.name>
 <871sczd0fi.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806242129180.28698@casper.infradead.org>
Message-ID: <87r2kvagmp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

>
> Okay I did some more testing and found I get this error with or without
> this patch. Its due to a regression from an earlier patch. Can't figure
> out where its coming from. I looked at the d_lock usage and it seems
> balanced. So all but the first patch for the lustre_compact* header
> changes seem okay. BTW they need a rebasing. Also since I have separated
> out your libcfs tracefile fixes which I will push your okay with it so
> it might be best to break the patches into two series.

I've changed the problematic lustre_compat patch after a closer look at
the code.  I'll post the result shortly.

I don't understand your comment about "break the patches into two
series".
The goal for these patches isn't to make series', it is to apply them to
the "lustre" branch, when they are ready.  Some are ready (thanks for
the confirmation), some aren't.  The ones that aren't will get revised
and reposted.

I'm okay with you posting any patches that are useful, whether or not
they conflict with anything in my lustre-testing branch.  My tendency
will be to apply your patches first, then rebase my outstanding
lustre-testing patches on top of them.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/f89db3e4/attachment.sig>
