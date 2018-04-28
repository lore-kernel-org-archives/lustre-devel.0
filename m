From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 28 Apr 2018 16:04:25 +0000
Subject: [lustre-devel] [PATCH] staging: luster: llite: fix a potential
 missing-check bug when copying lumv
In-Reply-To: <1524872704-13391-1-git-send-email-wang6495@umn.edu>
References: <1524872704-13391-1-git-send-email-wang6495@umn.edu>
Message-ID: <8E6ADED8-592E-4794-8CAB-913A325B1971@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wenwen Wang <wang6495@umn.edu>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Ben Evans <bevans@cray.com>, Jeff Layton <jlayton@redhat.com>, Aastha Gupta <aastha.gupta4104@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "kjlu@umn.edu" <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Apr 27, 2018, at 17:45, Wenwen Wang <wang6495@umn.edu> wrote:
> [PATCH] staging: luster: llite: fix potential missing-check bug when copying lumv

(typo) s/luster/lustre/

> In ll_dir_ioctl(), the object lumv3 is firstly copied from the user space
> using Its address, i.e., lumv1 = &lumv3. If the lmm_magic field of lumv3 is
> LOV_USER_MAGIV_V3, lumv3 will be modified by the second copy from the user

(typo) s/MAGIV/MAGIC/

> space. The second copy is necessary, because the two versions (i.e.,
> lov_user_md_v1 and lov_user_md_v3) have different data formats and lengths.
> However, given that the user data resides in the user space, a malicious
> user-space process can race to change the data between the two copies. By
> doing so, the attacker can provide a data with an inconsistent version,
> e.g., v1 version + v3 data. This can lead to logical errors in the
> following execution in ll_dir_setstripe(), which performs different actions
> according to the version specified by the field lmm_magic.

This isn't a serious bug in the end.  The LOV_USER_MAGIC_V3 check just copies
a bit more data from userspace (the lmm_pool field).  It would be more of a
problem if the reverse was possible (copy smaller V1 buffer, but change the
magic to LOV_USER_MAGIC_V3 afterward), but this isn't possible since the second
copy is not done if there is a V1 magic.  If the user changes from V3 magic
to V1 in a racy manner it means less data will be used than copied, which
is harmless.

> This patch rechecks the version field lmm_magic in the second copy.  If the
> version is not as expected, i.e., LOV_USER_MAGIC_V3, an error code will be
> returned: -EINVAL.

This isn't a bad idea in any case, since it verifies the data copied from
userspace is still valid.

Cheers, Andreas

> Signed-off-by: Wenwen Wang <wang6495@umn.edu>
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
