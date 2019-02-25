From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:19 +0000
Subject: [lustre-devel] [PATCH 20/37] lustre: convert rsi_sem to a
 spinlock.
In-Reply-To: <155053494585.24125.10207641299012244855.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494585.24125.10207641299012244855.stgit@noble.brown>
Message-ID: <19970218-0088-4873-B933-4F56FED1E6CC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> This lock is never held over code that sleeps, and is
> only ever held for short periods of time.
> So a simple spinlock is best.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index 27d73c95403d..aed33068ff3c 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1720,10 +1720,10 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
> 	if ((len == 4 && !strncmp(kernbuf, "NONE", len)) ||
> 	    (len == 5 && !strncmp(kernbuf, "clear", len))) {
> 		/* empty string is special case */
> -		down_write(&squash->rsi_sem);
> +		spin_lock(&squash->rsi_lock);
> 		if (!list_empty(&squash->rsi_nosquash_nids))
> 			cfs_free_nidlist(&squash->rsi_nosquash_nids);
> -		up_write(&squash->rsi_sem);
> +		spin_unlock(&squash->rsi_lock);
> 

> @@ -1740,11 +1740,11 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
> 	kfree(kernbuf);
> 	kernbuf = NULL;
> 
> -	down_write(&squash->rsi_sem);
> +	spin_lock(&squash->rsi_lock);
> 	if (!list_empty(&squash->rsi_nosquash_nids))
> 		cfs_free_nidlist(&squash->rsi_nosquash_nids);
> 	list_splice(&tmp, &squash->rsi_nosquash_nids);
> -	up_write(&squash->rsi_sem);
> +	spin_unlock(&squash->rsi_lock);


This is held here over cds_free_nidlist(), which has calls to kfree()
internally.  I don't think it is acceptable to hold a spinlock over
kfree() these days?

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
