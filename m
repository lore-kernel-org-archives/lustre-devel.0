From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 13:52:37 +1000
Subject: [lustre-devel] [PATCH 03/18] lustre: fileset: add fileset mount
 support
In-Reply-To: <1530573875-20465-4-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-4-git-send-email-jsimmons@infradead.org>
Message-ID: <87zhz90yd6.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> From: Lai Siyao <lsiyao@whamcloud.com>
>
> This patch enables client to mount subdirectory as fileset.
>
> usage: mount -t lustre mgsname:/fsname/subdir /mount/point
>
>  * mdt lookup fileset fid and return to client during mount.
>  * `fid2path` support for fileset.
>

> @@ -2626,7 +2626,10 @@ struct getinfo_fid2path {
>  	__u64	   gf_recno;
>  	__u32	   gf_linkno;
>  	__u32	   gf_pathlen;
> -	char	    gf_path[0];
> +	union {
> +		char		gf_path[0];
> +		struct lu_fid	gf_root_fid[0];
> +	} gf_u;

If you just left the "gf_u" off here, you wouldn't need changes like:

> -		ptr = ori_gf->gf_path;
> +		ptr = ori_gf->gf_u.gf_path;

throughout the code.

I'll probably make this change before applying the patch.
The rest can come afterwards.

>  } __packed;
>  
>  /** path2parent request/reply structures */
> diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
> index 886e817..bd8fa71 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_disk.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
> @@ -78,6 +78,7 @@ struct lustre_mount_data {
>  	int	lmd_recovery_time_hard;
>  	char      *lmd_dev;	   /* device name */
>  	char      *lmd_profile;    /* client only */
> +	char	*lmd_fileset;	/* mount fileset */

Consistent indenting is so over-rated :-)
I really that there is *nothing* you could have done here to make
the indenting consistent without including irrelevant changes in the
patch, which is generally frowned upon.
This is why it is not unusually to have some clean-up patches first,
so that you functional changes can be applied to clean code.

>  
> +	if (fileset)
> +		req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
> +				     strlen(fileset) + 1);
> +	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GET_ROOT);
> +	if (rc) {
> +		ptlrpc_request_free(req);
> +		return rc;
> +	}
>  	mdc_pack_body(req, NULL, 0, 0, -1, 0);
> +	if (fileset) {
> +		char *name = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
> +
> +		memcpy(name, fileset, strlen(fileset));

Why isn't this strcpy()?
I realize that strcpy will add a nul that memcpy doesn't add so if I
could see the length being stored, I would understand.
But above I see the size passed to req_capsule_set_size() includes
the trailing nul.

Am I confused, or is the code confusing?


> @@ -1073,10 +1074,30 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
>  		/* Remove leading /s from fsname */
>  		while (*++s1 == '/')
>  			;
> +		s2 = s1;
> +		while (*s2 != '/' && *s2 != '\0')
> +			s2++;

 s2 = strchrnul(s1, '/');

(I only discovered strchrnul() a few days ago).

>  		/* Freed in lustre_free_lsi */
> -		lmd->lmd_profile = kasprintf(GFP_NOFS, "%s-client", s1);
> +		lmd->lmd_profile = kzalloc(s2 - s1 + 8, GFP_NOFS);
>  		if (!lmd->lmd_profile)
>  			return -ENOMEM;
> +
> +		strncat(lmd->lmd_profile, s1, s2 - s1);
> +		strncat(lmd->lmd_profile, "-client", 7);

  kasprintf(GFP_KERN, "%.*s-client", s2-s1, s1);

??

> +
> +		s1 = s2;
> +		s2 = s1 + strlen(s1) - 1;
> +		/* Remove padding /s from fileset */
> +		while (*s2 == '/')
> +			s2--;
> +		if (s2 > s1) {
> +			lmd->lmd_fileset = kzalloc(s2 - s1 + 2, GFP_NOFS);
> +			if (!lmd->lmd_fileset) {
> +				kfree(lmd->lmd_profile);
> +				return -ENOMEM;
> +			}
> +			strncat(lmd->lmd_fileset, s1, s2 - s1 + 1);

This probably deserves to be kasprintf() too.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/bddfa938/attachment.sig>
