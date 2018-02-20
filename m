From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Tue, 20 Feb 2018 10:50:25 +0000
Subject: [lustre-devel] [PATCH 14/21] staging: lustre: fix assorted
 checkpatch errors
In-Reply-To: <87lgfojb0d.fsf@notabene.neil.brown.name>
References: <151909308778.25814.9912662268627044409.stgit@noble>
 <151909341801.25814.16760126077741712102.stgit@noble>
 <9FC73D3DBECE0941BD2ED069D26863425CE8FF1E@irsmsx110.ger.corp.intel.com>
 <87lgfojb0d.fsf@notabene.neil.brown.name>
Message-ID: <9FC73D3DBECE0941BD2ED069D26863425CE8FF72@irsmsx110.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

> -----Original Message-----
> Thanks for the review.  Yes, you are correct.
> I had seen that end_dirent was initialized to NULL, and let myself
> believe that would make the transformation safe.
> In fact, that initialization to NULL is pointless as it is never used.
> 
> Maybe this would be better
> 
> @@ -1055,13 +1055,14 @@ static void mdc_adjust_dirpages(struct page
> **pages, int cfs_pgs, int lu_pgs)
>  		__u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
>  		__u32 flags = le32_to_cpu(dp->ldp_flags);
>  		struct lu_dirpage *first = dp;
> -		struct lu_dirent *end_dirent = NULL;
> -		struct lu_dirent *ent;
> 
>  		while (--lu_pgs > 0) {
> -			ent = lu_dirent_start(dp);
> -			for (end_dirent = ent; ent;
> -			     end_dirent = ent, ent = lu_dirent_next(ent));
> +			struct lu_dirent *end_dirent = NULL;
> +			struct lu_dirent *ent;
> +
> +			for (ent = lu_dirent_start(dp); ent;
> +			     ent = lu_dirent_next(ent))
> +				end_dirent = ent;
> 
>  			/* Advance dp to next lu_dirpage. */
>  			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
> ??

Thanks, I agree with this version.

Dmitry.

--------------------------------------------------------------------
Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park,
17 Krylatskaya Str., Bldg 4, Moscow 121614,
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
