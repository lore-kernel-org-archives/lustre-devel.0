From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Jun 2018 12:29:30 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
Message-ID: <874lifnxbp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Greg's patch to remove lustre has now landed in this staging-next tree,
so I suspect it will get to Linus before too long.  So I have to find a
new place to work on lustre.

I've added 2 branches to
   git://git.neil.brown.name/linux

lustre:
   is based on Greg's patch that removes lustre, and starts with a
   revert of the patch, followed by a merge of v4.17.
   I plan to merge each release and RC from Linus, and also
   add lustre patches that I think are "ready".  That will usually mean
   they have been posted to this list at least a week earlier, and
   have not had a credible negative response (Acks and Reviewed-by
   would be nice).
   I plan to update this branch about once a week, and to never rebase
   it.

lustre-testing:
   is based on 'lustre' and has most of my current lustre-related work.
   It includes assorted patches that are not specifically for lustre
   (rhashtables mostly at the moment).  Patches will move from here
   to 'lustre' or to mainline when they are ready.
   I plan to update this branch on most days that I work on Lustre,
   and expect it to rebase frequently.

I'm happy to review and, if acceptable, apply patches from other
developers.  I have fairly high standards, but if I don't accept your
patch I'll explain why and possible help fix it.
I'm happy to accept enhancements and new features, but these need
to be of a quality that would be accepted upstream.
I'm only interested in client-side code at present - nothing that is
only used on the server.  I do want to include server-side eventually,
but I need some focus for now.

I hope to get to a stage where the code is of suitable quality that I
can submit it to Linux as a new filesystem.  I hope that will happen
this year.

I hope we can continue to work together to make all this happen.
(That's enough hope for now, time to get back to code).

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180607/cee8d602/attachment.sig>
