From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 02:04:47 +0000 (GMT)
Subject: [lustre-devel] [PATCH 03/28] lustre: lov: merge lov_mds_md_v3
 and lov_mds_md_v1 handling
In-Reply-To: <87pntzae5m.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-4-git-send-email-jsimmons@infradead.org>
 <87pntzae5m.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1812270202320.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > -const struct lsm_operations lsm_v1_ops = {
> > -	.lsm_free	    = lsm_free_plain,
> > -	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
> > -	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
> > -	.lsm_lmm_verify	 = lsm_lmm_verify_v1,
> > -	.lsm_unpackmd	   = lsm_unpackmd_v1,
> > +const static struct lsm_operations lsm_v1_ops = {
> > +	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
> > +	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
> > +	.lsm_lmm_verify		= lsm_lmm_verify_v1,
> > +	.lsm_unpackmd		= lsm_unpackmd_v1,
> 
> I *SO* wish you would stop combining white-spaces fixes with other
> changes in the same patch!!!
> The above hunk should just add the 'static' and remove the 'lsm_free'.
> The rest is just noise and makes it harder to review the patch.

I can do that for the next update. This is just the early verison. The 
reason that got in is often I do comparsion of the same files between the
LTS and linux client. For me I find that the easiest way to see if I do
a porting mistake. 
