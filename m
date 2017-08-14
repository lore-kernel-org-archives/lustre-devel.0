From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 16:01:17 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: Off by two in
	lmv_fid2path()
In-Reply-To: <20170728144227.uml3x27mqug3ciox@mwanda>
References: <20170728144227.uml3x27mqug3ciox@mwanda>
Message-ID: <alpine.LFD.2.20.1708141559060.14369@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> We want to concatonate join string one, a '/' character, string two and
> then a NUL terminator.  The destination buffer holds ori_gf->gf_pathlen
> characters.  The strlen() function returns the number of characters not
> counting the NUL terminator.  So we should be adding two extra spaces,
> one for the foward slash and one for the NUL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Not tested.  Please review this one carefully.

This is a real bug which is impacting users. The bug is being tracked
at https://jira.hpdd.intel.com/browse/LU-9863. It passed our test suite
and its being reviewed.
 
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 64fcaef0bacd..70c58291814d 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -657,8 +657,8 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
>  		char *ptr;
>  
>  		ori_gf = karg;
> -		if (strlen(ori_gf->gf_path) +
> -		    strlen(gf->gf_path) > ori_gf->gf_pathlen) {
> +		if (strlen(ori_gf->gf_path) + 1 +
> +		    strlen(gf->gf_path) + 1 > ori_gf->gf_pathlen) {
>  			rc = -EOVERFLOW;
>  			goto out_fid2path;
>  		}
> 
