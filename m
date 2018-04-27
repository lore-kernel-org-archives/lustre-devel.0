From: Wenwen Wang <wang6495@umn.edu>
Date: Fri, 27 Apr 2018 18:45:02 -0500
Subject: [lustre-devel] [PATCH] staging: luster: llite: fix a potential
 missing-check bug when copying lumv
Message-ID: <1524872704-13391-1-git-send-email-wang6495@umn.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wang6495@umn.edu
Cc: kjlu@umn.edu, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Evans <bevans@cray.com>, Aastha Gupta <aastha.gupta4104@gmail.com>, NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>, Luis de Bethencourt <luisbg@kernel.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

In ll_dir_ioctl(), the object lumv3 is firstly copied from the user space
using Its address, i.e., lumv1 = &lumv3. If the lmm_magic field of lumv3 is
LOV_USER_MAGIV_V3, lumv3 will be modified by the second copy from the user
space. The second copy is necessary, because the two versions (i.e.,
lov_user_md_v1 and lov_user_md_v3) have different data formats and lengths.
However, given that the user data resides in the user space, a malicious
user-space process can race to change the data between the two copies. By
doing so, the attacker can provide a data with an inconsistent version,
e.g., v1 version + v3 data. This can lead to logical errors in the
following execution in ll_dir_setstripe(), which performs different actions
according to the version specified by the field lmm_magic.

This patch rechecks the version field lmm_magic in the second copy.  If the
version is not as expected, i.e., LOV_USER_MAGIC_V3, an error code will be
returned: -EINVAL.

Signed-off-by: Wenwen Wang <wang6495@umn.edu>
---
 drivers/staging/lustre/lustre/llite/dir.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index d10d272..80d44ca 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1185,6 +1185,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (lumv1->lmm_magic == LOV_USER_MAGIC_V3) {
 			if (copy_from_user(&lumv3, lumv3p, sizeof(lumv3)))
 				return -EFAULT;
+			if (lumv3.lmm_magic != LOV_USER_MAGIC_V3)
+				return -EINVAL;
 		}
 
 		if (is_root_inode(inode))
-- 
2.7.4
