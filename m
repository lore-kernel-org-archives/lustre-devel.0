From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 03:37:51 +0000 (GMT)
Subject: [lustre-devel] [PATCH] lustre: accept suffix when parsing
 max_pages_per_rpc
In-Reply-To: <87va5p4c0s.fsf@notabene.neil.brown.name>
References: <87y3al4hb9.fsf@notabene.neil.brown.name>
 <87va5p4c0s.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810290332370.6811@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> upstream lustre allows size suffixes (K, M, G, etc) for
> max_pages_per_rpc.  We should too.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> This fixes test 101g.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
>  drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index edac88440b41..feba2ef5a3bc 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1868,11 +1868,12 @@ ssize_t max_pages_per_rpc_store(struct kobject *kobj, struct attribute *attr,
>  	struct obd_connect_data *ocd;
>  	unsigned long long val;
>  	int chunk_mask;
> +	char *endp;
>  	int rc;
>  
> -	rc = kstrtoull(buffer, 10, &val);
> -	if (rc)
> -		return rc;
> +	val = memparse(buffer, &endp);
> +	if (*endp)
> +		return -EINVAL;
>  
>  	/* if the max_pages is specified in bytes, convert to pages */
>  	if (val >= ONE_MB_BRW_SIZE)
> -- 
> 2.14.0.rc0.dirty
> 
> 
