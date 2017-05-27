From: Oleg Drokin <green@linuxhacker.ru>
Date: Fri, 26 May 2017 23:40:33 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/lov: remove set_fs() call
	from lov_getstripe()
Message-ID: <20170527034033.223677-1-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, "John L . Hammond" <john.hammond@intel.com>

lov_getstripe() calls set_fs(KERNEL_DS) so that it can handle a struct
lov_user_md pointer from user- or kernel-space.  This changes the
behavior of copy_from_user() on SPARC and may result in a misaligned
access exception which in turn oopses the kernel.  In fact the
relevant argument to lov_getstripe() is never called with a
kernel-space pointer and so changing the address limits is unnecessary
and so we remove the calls to save, set, and restore the address
limits.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/6150
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3221
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Li Wei <wei.g.li@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 2e1bd47..e6727ce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -293,18 +293,10 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	size_t lmmk_size;
 	size_t lum_size;
 	int rc;
-	mm_segment_t seg;
 
 	if (!lsm)
 		return -ENODATA;
 
-	/*
-	 * "Switch to kernel segment" to allow copying from kernel space by
-	 * copy_{to,from}_user().
-	 */
-	seg = get_fs();
-	set_fs(KERNEL_DS);
-
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
 		CERROR("bad LSM MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
 		       lsm->lsm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
@@ -406,6 +398,5 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 out_free:
 	kvfree(lmmk);
 out:
-	set_fs(seg);
 	return rc;
 }
-- 
2.9.3
