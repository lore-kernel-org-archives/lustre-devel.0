From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 1 May 2018 04:06:56 +0000
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
In-Reply-To: <1525128971-8946-1-git-send-email-wang6495@umn.edu>
References: <1525128971-8946-1-git-send-email-wang6495@umn.edu>
Message-ID: <BA97D240-2B0A-4AD4-B83B-201C285E4DEB@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wenwen Wang <wang6495@umn.edu>
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kangjie Lu <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Apr 30, 2018, at 16:56, Wenwen Wang <wang6495@umn.edu> wrote:
> 
> In ll_dir_ioctl(), the object lumv3 is firstly copied from the user space
> using Its address, i.e., lumv1 = &lumv3. If the lmm_magic field of lumv3 is
> LOV_USER_MAGIC_V3, lumv3 will be modified by the second copy from the user
> space. The second copy is necessary, because the two versions (i.e.,
> lov_user_md_v1 and lov_user_md_v3) have different data formats and lengths.
> However, given that the user data resides in the user space, a malicious
> user-space process can race to change the data between the two copies. By
> doing so, the attacker can provide a data with an inconsistent version,
> e.g., v1 version + v3 data. This can lead to logical errors in the
> following execution in ll_dir_setstripe(), which performs different actions
> according to the version specified by the field lmm_magic.
> 
> This patch rechecks the version field lmm_magic in the second copy.  If the
> version is not as expected, i.e., LOV_USER_MAGIC_V3, an error code will be
> returned: -EINVAL.
> 
> Signed-off-by: Wenwen Wang <wang6495@umn.edu>

Thanks for the updated patch.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/llite/dir.c | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index d10d272..80d44ca 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -1185,6 +1185,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> 		if (lumv1->lmm_magic == LOV_USER_MAGIC_V3) {
> 			if (copy_from_user(&lumv3, lumv3p, sizeof(lumv3)))
> 				return -EFAULT;
> +			if (lumv3.lmm_magic != LOV_USER_MAGIC_V3)
> +				return -EINVAL;
> 		}
> 
> 		if (is_root_inode(inode))
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
