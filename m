From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 12 Feb 2018 10:41:07 +0300
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87r2pvkkl5.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
Message-ID: <20180212074107.ulp52nikjv5m5mf2@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Feb 09, 2018 at 12:39:18PM +1100, NeilBrown wrote:
> On Tue, Aug 16 2016, James Simmons wrote:
> 
> >  
> > +static inline bool
> > +lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
> > +{
> > +	int idx;
> > +
> > +	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
> > +	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
> > +	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
> > +	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
> > +	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
> > +	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
> > +		return false;
> 
> Hi James and all,
>  This patch (8f18c8a48b736c2f in linux) is different from the
>  corresponding patch in lustre-release (60e07b972114df).
> 
> In that patch, the last clause in the 'if' condition is
> 
> +           strcmp(lsm1->lsm_md_pool_name,
> +                     lsm2->lsm_md_pool_name) != 0)
> 
> Whoever converted it to "!strcmp()" inverted the condition.  This is a
> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!

People think that "if (!strcmp()) " is prefered kernel style but it's
not.

	if (foo != NULL) {

The != NULL is a double negative.  I don't think it adds anything.
Some kernel developers like this style because it's explicit about the
type.  I have never seen any bugs caused by this format or solved by
this format.  Anyway checkpatch complains.

	if (ret != 0) {

In this situation "ret" is not a number, it's an error code.  The != 0
is a double negative and complicated to think about.  Btw, I sort of
prefer "if (ret)" to "if (ret < 0)", not because of style but it's
easier for Smatch.  No subsystems are totally consistent so the (by
definition inconsistent) "if (ret < 0)" checks cause false positives in
Smatch.

	if (len != 0)

This is OK.  "len" is a number.

	if (strcmp(one, two) != 0) {

With strcmp() I really prefer == 0 and != 0 because it works like this:

	strcmp(one, two) == 0  --> means one == two
	strcmp(one, two) < 0   --> means one < two
        strcmp(one, two) != 0  --> means one != two

Either style is accepted in the kernel but I think == 0 just makes so
much sense.  I mostly see bugs from this when people are "fixing" the
style from == 0 to !strcmp() so my sample is very biased.  Normally, if
the original author writes the code any bugs are caught in testing so
either way is going to be bug free.

But the only thing that checkpatch complains about is == NULL and
!= NULL.

regards,
dan carpenter
