From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 01:31:32 +0000 (GMT)
Subject: [lustre-devel] [PATCH 4/9] lustre: rename: DNE2 should return
 -EXDEV upon remote rename
In-Reply-To: <154295732797.2850.16990175697450002727.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732797.2850.16990175697450002727.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260130360.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Fri, 23 Nov 2018, NeilBrown wrote:

> From: Lai Siyao <lai.siyao@intel.com>
> 
> DNE2 MDS should return -EXDEV upon remote rename, so that old
> client can do rename with copy and delete, instead of fail
> with -EREMOTE.

Let me guess you were debugging the migration failures and fould this :-)
I was doing the same thing.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Lai Siyao <lai.siyao@intel.com>
> Change-Id: I68e8e99259065922f31bee5343be309380715674
> WC-bug-id: https://jira.whamcloud.com/browse/LU-6660
> Reviewed-on: http://review.whamcloud.com/15323
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: wangdi <di.wang@intel.com>
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 32bb9fca88c9..7e4ffeb15a63 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -1945,7 +1945,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
>  	}
>  
>  	rc = md_rename(target_exp, op_data, old, oldlen, new, newlen, request);
> -	if (rc && rc != -EREMOTE)
> +	if (rc && rc != -EXDEV)
>  		return rc;
>  
>  	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
> 
> 
> 
