From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Apr 2018 11:38:54 +0300
Subject: [lustre-devel] [PATCH 19/22] staging: lustre: llite: add
 support set_acl method in inode operations
In-Reply-To: <1523852111-17321-20-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
 <1523852111-17321-20-git-send-email-jsimmons@infradead.org>
Message-ID: <20180417083854.7dgypv3eu4tc4e2c@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:15:08AM -0400, James Simmons wrote:
> +int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
> +{
> +	struct ll_sb_info *sbi = ll_i2sbi(inode);
> +	struct ptlrpc_request *req = NULL;
> +	const char *name = NULL;
> +	size_t value_size = 0;
> +	char *value = NULL;
> +	int rc;
> +
> +	switch (type) {
> +	case ACL_TYPE_ACCESS:
> +		name = XATTR_NAME_POSIX_ACL_ACCESS;
> +		if (acl) {
> +			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
> +			if (rc)
> +				goto out;
> +		}
> +
> +		break;
> +
> +	case ACL_TYPE_DEFAULT:
> +		name = XATTR_NAME_POSIX_ACL_DEFAULT;
> +		if (!S_ISDIR(inode->i_mode)) {
> +			rc = acl ? -EACCES : 0;
> +			goto out;

I just hate "goto out;" labels...  They're so impossible to review...
Why are we calling forget_cached_acl() when we haven't set anything?  I
have no idea.  Perhaps it's not even intentional.

> +		}
> +
> +		break;
> +
> +	default:
> +		rc = -EINVAL;
> +		goto out;

And on this path we're calling forget_cached_acl(inode, type) with an
invalid "type" so it will trigger a BUG()...  That's obviously not
intended...  Who knows what's going on when all the names are vague and
hand wavy.

regards,
dan carpenter
