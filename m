From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 May 2018 14:30:35 +0300
Subject: [lustre-devel] [PATCH v2 1/5] staging: lustre: llite: add
 support set_acl method in inode operations
In-Reply-To: <1526350623-4616-2-git-send-email-jsimmons@infradead.org>
References: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
 <1526350623-4616-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20180515113034.ywxhai4nrrvxs7nr@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, May 14, 2018 at 10:16:59PM -0400, James Simmons wrote:
> +#ifdef CONFIG_FS_POSIX_ACL
>  struct posix_acl *ll_get_acl(struct inode *inode, int type)
>  {
>  	struct ll_inode_info *lli = ll_i2info(inode);
> @@ -3043,6 +3044,64 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
>  	return acl;
>  }
>  
> +int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
> +{
> +	struct ll_sb_info *sbi = ll_i2sbi(inode);
> +	struct ptlrpc_request *req = NULL;
> +	const char *name = NULL;
> +	size_t value_size = 0;
> +	char *value = NULL;
> +	int rc;

"rc" needs to be initialized to zero.  It's disapppointing that GCC
doesn't catch this.

> +
> +	switch (type) {
> +	case ACL_TYPE_ACCESS:
> +		name = XATTR_NAME_POSIX_ACL_ACCESS;
> +		if (acl)
> +			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
> +		break;
> +
> +	case ACL_TYPE_DEFAULT:
> +		name = XATTR_NAME_POSIX_ACL_DEFAULT;
> +		if (!S_ISDIR(inode->i_mode))
> +			rc = acl ? -EACCES : 0;
> +		break;
> +
> +	default:
> +		rc = -EINVAL;
> +		break;
> +	}
> +	if (rc)
> +		return rc;

Otherwise rc can be uninitialized here.

regards,
dan carpenter
