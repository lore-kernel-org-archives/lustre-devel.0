From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 19:55:30 +1100
Subject: [lustre-devel] [PATCH 14/21] staging: lustre: fix assorted
 checkpatch errors
In-Reply-To: <9FC73D3DBECE0941BD2ED069D26863425CE8FF1E@irsmsx110.ger.corp.intel.com>
References: <151909308778.25814.9912662268627044409.stgit@noble>
 <151909341801.25814.16760126077741712102.stgit@noble>
 <9FC73D3DBECE0941BD2ED069D26863425CE8FF1E@irsmsx110.ger.corp.intel.com>
Message-ID: <87lgfojb0d.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eremin, Dmitry" <dmitry.eremin@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James
 Simmons <jsimmons@infradead.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Tue, Feb 20 2018, Eremin, Dmitry wrote:

> Hello Neil,
>
>> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> index ab48746ce433..bde27acb0dd3 100644
>> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> @@ -1060,8 +1060,10 @@ static void mdc_adjust_dirpages(struct page
>> **pages, int cfs_pgs, int lu_pgs)
>> 
>>  		while (--lu_pgs > 0) {
>>  			ent = lu_dirent_start(dp);
>> -			for (end_dirent = ent; ent;
>> -			     end_dirent = ent, ent = lu_dirent_next(ent));
>> +			while (ent) {
>> +				end_dirent = ent;
>> +				ent = lu_dirent_next(ent);
>> +			}
>> 
>>  			/* Advance dp to next lu_dirpage. */
>>  			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
>
> I doubt this is correct replacement. In original code end_dirent is
> set always in the begin of outer loop (while (--lu_pgs > 0)). But in
> new code this is missed. Therefore in case of second iteration and
> (ent = lu_dirent_start(dp)) == NULL the end_dirent will contain a
> value from previous iteration which is not correct.

Thanks for the review.  Yes, you are correct.
I had seen that end_dirent was initialized to NULL, and let myself
believe that would make the transformation safe.
In fact, that initialization to NULL is pointless as it is never used.

Maybe this would be better

@@ -1055,13 +1055,14 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 		__u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
 		__u32 flags = le32_to_cpu(dp->ldp_flags);
 		struct lu_dirpage *first = dp;
-		struct lu_dirent *end_dirent = NULL;
-		struct lu_dirent *ent;
 
 		while (--lu_pgs > 0) {
-			ent = lu_dirent_start(dp);
-			for (end_dirent = ent; ent;
-			     end_dirent = ent, ent = lu_dirent_next(ent));
+			struct lu_dirent *end_dirent = NULL;
+			struct lu_dirent *ent;
+
+			for (ent = lu_dirent_start(dp); ent;
+			     ent = lu_dirent_next(ent))
+				end_dirent = ent;
 
 			/* Advance dp to next lu_dirpage. */
 			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);


??

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180220/d548aefe/attachment.sig>
