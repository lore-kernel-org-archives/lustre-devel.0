From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:37 -0500
Subject: [lustre-devel] [PATCH 09/60] staging: lustre: lmv: Correctly
	generate target_obd
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Giuseppe Di Natale <dinatale2@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Giuseppe Di Natale <dinatale2@llnl.gov>

The target_obd debugfs file was not being generated correctly
in cases where nonconsecutive MDT indices were used when
generating a filesystem.

Signed-off-by: Giuseppe Di Natale <dinatale2@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8100
Reviewed-on: http://review.whamcloud.com/20336
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 20bbdfc..14fbc9c 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -147,7 +147,13 @@ static void *lmv_tgt_seq_start(struct seq_file *p, loff_t *pos)
 	struct obd_device       *dev = p->private;
 	struct lmv_obd	  *lmv = &dev->u.lmv;
 
-	return (*pos >= lmv->desc.ld_tgt_count) ? NULL : lmv->tgts[*pos];
+	while (*pos < lmv->tgts_size) {
+		if (lmv->tgts[*pos])
+			return lmv->tgts[*pos];
+		++*pos;
+	}
+
+	return  NULL;
 }
 
 static void lmv_tgt_seq_stop(struct seq_file *p, void *v)
@@ -159,8 +165,15 @@ static void *lmv_tgt_seq_next(struct seq_file *p, void *v, loff_t *pos)
 {
 	struct obd_device       *dev = p->private;
 	struct lmv_obd	  *lmv = &dev->u.lmv;
+
 	++*pos;
-	return (*pos >= lmv->desc.ld_tgt_count) ? NULL : lmv->tgts[*pos];
+	while (*pos < lmv->tgts_size) {
+		if (lmv->tgts[*pos])
+			return lmv->tgts[*pos];
+		++*pos;
+	}
+
+	return  NULL;
 }
 
 static int lmv_tgt_seq_show(struct seq_file *p, void *v)
-- 
1.8.3.1
