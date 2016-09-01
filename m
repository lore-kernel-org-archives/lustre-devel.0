From: James Simmons <jsimmons@infradead.org>
Date: Thu, 1 Sep 2016 02:59:21 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: hide unused variable
In-Reply-To: <20160829122023.3018966-2-arnd@arndb.de>
References: <20160829122023.3018966-1-arnd@arndb.de>
	<20160829122023.3018966-2-arnd@arndb.de>
Message-ID: <alpine.LFD.2.20.1609010258550.21057@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


> After a code cleanup, we get a harmless warning about a variable
> that is unused when CONFIG_FS_POSIX_ACL is disabled:
> 
> drivers/staging/lustre/lustre/llite/xattr.c: In function 'll_xattr_get_common':
> drivers/staging/lustre/lustre/llite/xattr.c:312:24: error: unused variable 'lli' [-Werror=unused-variable]
> 
> This puts the variable declaration into the same #ifdef.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 1e1f9ff406fd ("staging: lustre: llite: break ll_getxattr_common into 2 functions")

Reviewed-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lustre/llite/xattr.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index f252c26ec30f..7b8d4699a71a 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -309,7 +309,9 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
>  {
>  	char fullname[strlen(handler->prefix) + strlen(name) + 1];
>  	struct ll_sb_info *sbi = ll_i2sbi(inode);
> +#ifdef CONFIG_FS_POSIX_ACL
>  	struct ll_inode_info *lli = ll_i2info(inode);
> +#endif
>  	int rc;
>  
>  	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
> -- 
> 2.9.0
> 
> 
