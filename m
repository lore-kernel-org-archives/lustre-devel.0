From: NeilBrown <neilb@suse.com>
Date: Fri, 09 Feb 2018 12:39:18 +1100
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
Message-ID: <87r2pvkkl5.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Aug 16 2016, James Simmons wrote:

>  
> +static inline bool
> +lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
> +{
> +	int idx;
> +
> +	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
> +	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
> +	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
> +	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
> +	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
> +	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
> +		return false;

Hi James and all,
 This patch (8f18c8a48b736c2f in linux) is different from the
 corresponding patch in lustre-release (60e07b972114df).

In that patch, the last clause in the 'if' condition is

+           strcmp(lsm1->lsm_md_pool_name,
+                     lsm2->lsm_md_pool_name) != 0)

Whoever converted it to "!strcmp()" inverted the condition.  This is a
perfect example of why I absolutely *loathe* the "!strcmp()" construct!!

This causes many tests in the 'sanity' test suite to return
-ENOMEM (that had me puzzled for a while!!).
This seems to suggest that no-one has been testing the mainline linux
lustre.
It also seems to suggest that there is a good chance that there
are other bugs that have crept in while no-one has really been caring.
Given that the sanity test suite doesn't complete for me, but just
hangs (in test_27z I think), that seems particularly likely.


So my real question - to anyone interested in lustre for mainline linux
- is: can we actually trust this code at all?
I'm seriously tempted to suggest that we just
  rm -r drivers/staging/lustre

drivers/staging is great for letting the community work on code that has
been "thrown over the wall" and is not openly developed elsewhere, but
that is not the case for lustre.  lustre has (or seems to have) an open
development process.  Having on-going development happen both there and
in drivers/staging seems a waste of resources.

Might it make sense to instead start cleaning up the code in
lustre-release so as to make it meet the upstream kernel standards.
Then when the time is right, the kernel code can be moved *out* of
lustre-release and *in* to linux.  Then development can continue in
Linux (just like it does with other Linux filesystems).

An added bonus of this is that there is an obvious path to getting
server support in mainline Linux.  The current situation of client-only
support seems weird given how interdependent the two are.

What do others think?  Is there any chance that the current lustre in
Linux will ever be more than a poor second-cousin to the external
lustre-release.  If there isn't, should we just discard it now and move
on?

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180209/c219fee6/attachment.sig>
