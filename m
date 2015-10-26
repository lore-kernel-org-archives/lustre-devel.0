From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 26 Oct 2015 11:52:49 +0300
Subject: [lustre-devel] [PATCH] staging:lustre: Prevent duplicate CT
	registrations
In-Reply-To: <1445630357-27149-3-git-send-email-jsimmons@infradead.org>
References: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
	<1445630357-27149-3-git-send-email-jsimmons@infradead.org>
Message-ID: <20151026085249.GW7340@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Oct 23, 2015 at 03:59:14PM -0400, James Simmons wrote:
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 635a93c..d6d70d8 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -794,7 +794,9 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
>  static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
>  				 struct lustre_kernelcomm *lk, void *uarg)
>  {
> -	int	i, rc = 0;
> +	struct kkuc_ct_data *kcd = NULL;
> +	int rc = 0;
> +	__u32 i;

We have been introducing a lot of new __u32 types here and I just
assumed there was a reason for it but this one is clearly wrong.  The
new code implies that ->ld_tgt_count can overflow INT_MAX which is not
true and that this is code shared with userspace which might be true but
it's not described in the changelog.  Is this a static checker fix?
Stop using that broken static checker, because the correct type here is
int.

Anyway, stop making gratuitous unrelated changes (like the white space
changes to local declarations).  I feel like I have held off commenting
on this for a while and shown great restraint.  :P

> -	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
> +	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group, (void**)&kcd);
> +	if (kcd != NULL)
> +		kfree(kcd);

NULL check not needed.

> +
>  	return rc;
>  }
>  
>  static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
>  			       struct lustre_kernelcomm *lk, void *uarg)
>  {
> -	struct file	*filp;
> -	int		 i, j, err;
> -	int		 rc = 0;
> -	bool		 any_set = false;
> +	struct file *filp;
> +	__u32 i, j;
> +	int err, rc = 0;
> +	bool any_set = false;
> +	struct kkuc_ct_data *kcd;
>  
>  	/* All or nothing: try to register to all MDS.
>  	 * In case of failure, unregister from previous MDS,
> @@ -854,12 +860,25 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
>  
>  	/* at least one registration done, with no failure */
>  	filp = fget(lk->lk_wfd);
> -	if (filp == NULL) {
> +	if (filp == NULL)
>  		return -EBADF;
> -	}
> -	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group, lk->lk_data);
> -	if (rc != 0 && filp != NULL)
> +
> +	kcd = kzalloc(sizeof(*kcd), GFP_NOFS);
> +	if (kcd == NULL) {
>  		fput(filp);
> +		return -ENOMEM;
> +	}
> +	kcd->kcd_magic = KKUC_CT_DATA_MAGIC;
> +	kcd->kcd_uuid = lmv->cluuid;
> +	kcd->kcd_archive = lk->lk_data;
> +
> +	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group, kcd);
> +	if (rc != 0) {

These double negatives are a pet peev of mine.  "if (rc) {"  Comparing
with zero like this is idiomatic when you're talking about the number
zero or strcmp().  Can we use a goto for unwinding?  goto free_kcd;

> +		if (filp != NULL)

The earlier NULL check means this can't happen.

> +			fput(filp);
> +		kfree(kcd);
> +	}
> +
>  	return rc;

	return 0;

free_kcd:
	kfree(kcd);
put_filp:
	fput(filp);

	return rc;

regards,
dan carpenter
