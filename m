From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Tue, 24 May 2016 04:08:05 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: llite: drop acl from
	cache
In-Reply-To: <1464050108-28015-1-git-send-email-jsimmons@infradead.org>
References: <1464050108-28015-1-git-send-email-jsimmons@infradead.org>
Message-ID: <CAHpGcMJtzz4MYcRKkG-ybKgDArchQ_CFOtFjpJ8axe8Ls2G7rw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

2016-05-24 2:35 GMT+02:00 James Simmons <jsimmons@infradead.org>:
> Commit b8a7a3a6 change get_acl() for posix xattr to always cache
> the ACL which increases the reference count. That reference count
> can be reduced by have ll_get_acl() call forget_cached_acl() which
> it wasn't. When an inode gets deleted by Lustre the POSIX ACL
> reference count is tested to ensure its 1 and if not produces an error.

Lustre shouldn't assume that the VFS immediately drops the reference
it is passed. Please remove that check as well.

> Since forget_cached_acl() was not called Lustre started to complain.
> This patch changes ll_get_acl() to call forget_cached_acl().
>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

Reviewed-by: Andreas Gruenbacher <agruenba@redhat.com>

> ---
>  drivers/staging/lustre/lustre/llite/file.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index f47f2ac..0191945 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -3124,6 +3124,7 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
>         spin_lock(&lli->lli_lock);
>         /* VFS' acl_permission_check->check_acl will release the refcount */
>         acl = posix_acl_dup(lli->lli_posix_acl);
> +       forget_cached_acl(inode, type);
>         spin_unlock(&lli->lli_lock);
>
>         return acl;
> --
> 1.7.1
>
