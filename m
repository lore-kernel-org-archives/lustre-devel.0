From: Patrick Farrell <paf@cray.com>
Date: Tue, 18 Dec 2018 01:49:22 +0000
Subject: [lustre-devel] [PATCH 03/28] lustre: lov: merge lov_mds_md_v3
 and lov_mds_md_v1 handling
In-Reply-To: <87pntzae5m.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-4-git-send-email-jsimmons@infradead.org>,
 <87pntzae5m.fsf@notabene.neil.brown.name>
Message-ID: <MWHPR11MB14884ED0EA0E7BF9AE8E0C45CBBD0@MWHPR11MB1488.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Just throwing this in, I agree with Neil very strongly here.  I?ve seen some patches recently with ~20 lines of change and 200 lines of whitespace.

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Monday, December 17, 2018 6:09:57 PM
To: James Simmons; Andreas Dilger; Oleg Drokin; Bobi Jam; Jinshan Xiong
Cc: Lustre Development List
Subject: Re: [lustre-devel] [PATCH 03/28] lustre: lov: merge lov_mds_md_v3 and lov_mds_md_v1 handling

On Mon, Dec 17 2018, James Simmons wrote:

> From: Bobi Jam <bobijam@hotmail.com>
>
> Several of the struct lsm_operations functions for both v1 and v3
> are nearly identical. Let merge them together.
                        Let's

>
> -const struct lsm_operations lsm_v1_ops = {
> -     .lsm_free           = lsm_free_plain,
> -     .lsm_stripe_by_index    = lsm_stripe_by_index_plain,
> -     .lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
> -     .lsm_lmm_verify  = lsm_lmm_verify_v1,
> -     .lsm_unpackmd      = lsm_unpackmd_v1,
> +const static struct lsm_operations lsm_v1_ops = {
> +     .lsm_stripe_by_index    = lsm_stripe_by_index_plain,
> +     .lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
> +     .lsm_lmm_verify         = lsm_lmm_verify_v1,
> +     .lsm_unpackmd           = lsm_unpackmd_v1,

I *SO* wish you would stop combining white-spaces fixes with other
changes in the same patch!!!
The above hunk should just add the 'static' and remove the 'lsm_free'.
The rest is just noise and makes it harder to review the patch.


Thanks,
NeilBrown
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181218/62ee40ec/attachment-0001.html>
