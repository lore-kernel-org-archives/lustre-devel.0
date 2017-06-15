From: James Simmons <jsimmons@infradead.org>
Date: Thu, 15 Jun 2017 17:38:32 +0100 (BST)
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: lustre: fix all
 braces issues reported by checkpatch
In-Reply-To: <1497464706.18751.62.camel@perches.com>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-7-git-send-email-jsimmons@infradead.org>
	<1497464706.18751.62.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1706151708230.11322@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> > Cleanup all braces that was reported by checkpatch. The only
> > issue not fixed up is in mdc_lock.c. Removing the braces in
> > the case of mdc_lock.c will break the build.
> 
> []
> 
> > diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> []
> > @@ -591,9 +591,10 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
> >  	env = cl_env_get(&refcheck);
> >  	if (!IS_ERR(env)) {
> >  		sbi = f->private;
> > -		if (sbi->ll_site->ls_obj_hash->hs_cur_bits > 64 - PGC_OBJ_SHIFT)
> > +		if (sbi->ll_site->ls_obj_hash->hs_cur_bits >
> > +		    64 - PGC_OBJ_SHIFT) {
> >  			pos = ERR_PTR(-EFBIG);
> > -		else {
> > +		} else {
> >  			*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev,
> >  						*pos);
> >  			if (*pos == ~0ULL)
> 
> Sometimes is nicer to rearrange the code with smaller
> indentation by using early returns and/or goto <labels>.

Do you mind if I submit a separate patch for this? It would be nice to
land the current cleanups as is. Looking at the code I see where more
simplication along this line can be done. I submitted a patch for our
test harness:

https://review.whamcloud.com/#/c/27664

In the near future it will be pushed here.

> Something like:
> 
> static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
> {
> 	struct ll_sb_info *sbi;
> 	struct lu_env?????*env;
> 	u16 refcheck;
> 
> 	sbi = f->private;
> 
> 	env = cl_env_get(&refcheck);
> 	if (IS_ERR(env))
> 		return pos;
> 
> 	sbi = f->private;
> 	if (sbi->ll_site->ls_obj_hash->hs_cur_bits > 64 - PGC_OBJ_SHIFT) {
> 		pos = ERR_PTR(-EFBIG);
> 		goto out;
> 	}
> 
> 	*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev, *pos);
> 	if (*pos == ~0ULL)
> 		pos = NULL;
> 
> out:
> 	cl_env_put(env, &refcheck);
> 
> 	return pos;
> }
> 
> 
