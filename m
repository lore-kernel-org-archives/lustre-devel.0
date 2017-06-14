From: Joe Perches <joe@perches.com>
Date: Wed, 14 Jun 2017 11:25:06 -0700
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: lustre: fix all
 braces issues reported by checkpatch
In-Reply-To: <1497452481-31124-7-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-7-git-send-email-jsimmons@infradead.org>
Message-ID: <1497464706.18751.62.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> Cleanup all braces that was reported by checkpatch. The only
> issue not fixed up is in mdc_lock.c. Removing the braces in
> the case of mdc_lock.c will break the build.

[]

> diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
[]
> @@ -591,9 +591,10 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
>  	env = cl_env_get(&refcheck);
>  	if (!IS_ERR(env)) {
>  		sbi = f->private;
> -		if (sbi->ll_site->ls_obj_hash->hs_cur_bits > 64 - PGC_OBJ_SHIFT)
> +		if (sbi->ll_site->ls_obj_hash->hs_cur_bits >
> +		    64 - PGC_OBJ_SHIFT) {
>  			pos = ERR_PTR(-EFBIG);
> -		else {
> +		} else {
>  			*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev,
>  						*pos);
>  			if (*pos == ~0ULL)

Sometimes is nicer to rearrange the code with smaller
indentation by using early returns and/or goto <labels>.

Something like:

static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
{
	struct ll_sb_info *sbi;
	struct lu_env?????*env;
	u16 refcheck;

	sbi = f->private;

	env = cl_env_get(&refcheck);
	if (IS_ERR(env))
		return pos;

	sbi = f->private;
	if (sbi->ll_site->ls_obj_hash->hs_cur_bits > 64 - PGC_OBJ_SHIFT) {
		pos = ERR_PTR(-EFBIG);
		goto out;
	}

	*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev, *pos);
	if (*pos == ~0ULL)
		pos = NULL;

out:
	cl_env_put(env, &refcheck);

	return pos;
}
