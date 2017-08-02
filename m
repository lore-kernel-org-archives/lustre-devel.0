From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 0/6] dcache/namei fixes for lustre
Message-ID: <150164273003.13199.7841976922211510658.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This series is a revised version of two patches I sent
previously (one of which was sadly broken).
That patch has been broken into multiple parts for easy
review.  The other is included unchanged as the last of
this series.

I was drawn to look at this code due to the tests on
DCACHE_DISCONNECTED which are often wrong, and it turns out
they are used wrongly in lustre too.  Fixing one led to some
clean-up.  Fixing the other is straight forward.

A particular change here from the previous posting is
the first patch which tests for DCACHE_PAR_LOOKUP in ll_dcompare().
Without this patch, two threads can be looking up the same
name in a given directory in parallel.  This parallelism lead
to my concerns about needing improved locking in ll_splice_alias().
Instead of improving the locking, I now avoid the need for it
by fixing ll_dcompare.

This code passes basic "smoke tests".

Note that the cast to "struct dentry *" in the first patch is because
we have a "const struct dentry *" but d_in_lookup() requires a
pointer to a non-const structure.  I'll send a separate patch to
change d_in_lookup().

---

NeilBrown (6):
      staging: lustre: llite: handle DCACHE_PAR_LOOKUP in ll_dcompare
      staging: lustre: llite: use d_splice_alias for directories.
      staging: lustre: llite: remove directory-specific code from ll_find_alias()
      staging: lluste: llite: simplify ll_find_alias()
      staging: lustre: llite: refine ll_find_alias based on d_exact_alias
      staging: lustre: llite: fix incorrect DCACHE_DISCONNECTED test


 drivers/staging/lustre/lustre/llite/dcache.c       |   10 +++
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/namei.c        |   60 ++++++++++----------
 3 files changed, 40 insertions(+), 32 deletions(-)

--
Signature
