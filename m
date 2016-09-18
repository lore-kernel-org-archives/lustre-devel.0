From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:48 -0400
Subject: [lustre-devel] [PATCH 109/124] staging: lustre: misc: remove
	unnecessary EXPORT_SYMBOL
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-110-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13321
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_lib.c     |    2 --
 drivers/staging/lustre/lustre/fld/fld_request.c |    2 --
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |    1 -
 drivers/staging/lustre/lustre/lov/lov_dev.c     |    1 -
 4 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 99ae7eb..4e49cb3 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -63,14 +63,12 @@ const struct lu_seq_range LUSTRE_SEQ_SPACE_RANGE = {
 	FID_SEQ_NORMAL,
 	(__u64)~0ULL
 };
-EXPORT_SYMBOL(LUSTRE_SEQ_SPACE_RANGE);
 
 /* Zero range, used for init and other purposes. */
 const struct lu_seq_range LUSTRE_SEQ_ZERO_RANGE = {
 	0,
 	0
 };
-EXPORT_SYMBOL(LUSTRE_SEQ_ZERO_RANGE);
 
 /* Lustre Big Fs Lock fid. */
 const struct lu_fid LUSTRE_BFL_FID = { .f_seq = FID_SEQ_SPECIAL,
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index ed7962e..0de72b7 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -219,7 +219,6 @@ int fld_client_del_target(struct lu_client_fld *fld, __u64 idx)
 	spin_unlock(&fld->lcf_lock);
 	return -ENOENT;
 }
-EXPORT_SYMBOL(fld_client_del_target);
 
 static struct dentry *fld_debugfs_dir;
 
@@ -454,7 +453,6 @@ void fld_client_flush(struct lu_client_fld *fld)
 {
 	fld_cache_flush(fld->lcf_cache);
 }
-EXPORT_SYMBOL(fld_client_flush);
 
 static int __init fld_init(void)
 {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 941981d..cccb645 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2804,7 +2804,6 @@ lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
 
 	return lmm_size;
 }
-EXPORT_SYMBOL(lmv_pack_md);
 
 static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 			    const struct lmv_mds_md_v1 *lmm1)
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index b1f260d..056ae2e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -516,6 +516,5 @@ struct lu_device_type lov_device_type = {
 	.ldt_ops      = &lov_device_type_ops,
 	.ldt_ctx_tags = LCT_CL_THREAD
 };
-EXPORT_SYMBOL(lov_device_type);
 
 /** @} lov */
-- 
1.7.1
