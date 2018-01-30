From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 30 Jan 2018 02:04:23 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: llite: replace variable
 length array
In-Reply-To: <20180127214228.26986-1-sven.dziadek@gmx.de>
References: <20180127214228.26986-1-sven.dziadek@gmx.de>
Message-ID: <D887F611-EA3C-45CD-BEBC-3BA994048B59@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Dziadek <sven.dziadek@gmx.de>, James Simmons <jsimmons@infradead.org>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Eremin,
 Dmitry" <dmitry.eremin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, lustre-devel <lustre-devel@lists.lustre.org>

On Jan 27, 2018, at 14:42, Sven Dziadek <sven.dziadek@gmx.de> wrote:
> 
> The functionality of the removed variable length array is already
> implemented by the function xattr_full_name in fs/xattr.c
> 
> This fixes the sparse warning:
> warning: Variable length array is used.
> 
> Signed-off-by: Sven Dziadek <sven.dziadek@gmx.de>
> ---
> drivers/staging/lustre/lustre/llite/xattr.c | 12 ++++--------
> 1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index 532384c91447..4fd28213c6a1 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -87,7 +87,6 @@ ll_xattr_set_common(const struct xattr_handler *handler,
> 		    const char *name, const void *value, size_t size,
> 		    int flags)
> {
> -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> 	struct ll_sb_info *sbi = ll_i2sbi(inode);
> 	struct ptlrpc_request *req = NULL;
> 	const char *pv = value;
> @@ -141,9 +140,8 @@ ll_xattr_set_common(const struct xattr_handler *handler,
> 			return -EPERM;
> 	}
> 
> -	sprintf(fullname, "%s%s\n", handler->prefix, name);
> -	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
> -			 valid, fullname, pv, size, 0, flags,
> +	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid,
> +			 xattr_full_name(handler, name), pv, size, 0, flags,
> 			 ll_i2suppgid(inode), &req);

Hi Sven,
thanks for the patch.

Looking at the details of "xattr_full_name()", this seems quite risky.  This
is essentially returning the pointer _before_ "name" on the assumption that
it contains the full "prefix.name" string.  IMHO, that is not necessarily a
safe assumption to make several layers down in the code.

James, I thought you had a patch for this to use kasprintf() instead of the
on-stack "fullname" declaration?

Cheers, Andreas

> 	if (rc) {
> 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
> @@ -364,7 +362,6 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
> 			       struct dentry *dentry, struct inode *inode,
> 			       const char *name, void *buffer, size_t size)
> {
> -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> 	struct ll_sb_info *sbi = ll_i2sbi(inode);
> #ifdef CONFIG_FS_POSIX_ACL
> 	struct ll_inode_info *lli = ll_i2info(inode);
> @@ -411,9 +408,8 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
> 	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
> 		return -ENODATA;
> #endif
> -	sprintf(fullname, "%s%s\n", handler->prefix, name);
> -	return ll_xattr_list(inode, fullname, handler->flags, buffer, size,
> -			     OBD_MD_FLXATTR);
> +	return ll_xattr_list(inode, xattr_full_name(handler, name),
> +			     handler->flags, buffer, size, OBD_MD_FLXATTR);
> }
> 
> static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
> -- 
> 2.11.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
