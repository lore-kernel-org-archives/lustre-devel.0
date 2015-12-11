From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:21 -0500
Subject: [lustre-devel] [PATCH v2 2/6] Fix set-but-unused whinge.
In-Reply-To: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449875065-35182-3-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

drivers/staging/lustre/lustre/fid/lproc_fid.c: In function 'ldebugfs_fid_write_common':
drivers/staging/lustre/lustre/fid/lproc_fid.c:67:6: warning: variable 'rc' set but not used [-Wunused-but-set-variable]
  int rc;

We fix it by *using* the return code to help bulletproof it.  It says it's
test code - it should be *more* bulletproof than production, not less.

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
 drivers/staging/lustre/lustre/fid/lproc_fid.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index ce90c1c54a63..eff011f30fa5 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -85,6 +85,8 @@ ldebugfs_fid_write_common(const char __user *buffer, size_t count,
 	rc = sscanf(kernbuf, "[%llx - %llx]\n",
 		    (unsigned long long *)&tmp.lsr_start,
 		    (unsigned long long *)&tmp.lsr_end);
+	if (rc != 2)
+		return -EINVAL;
 	if (!range_is_sane(&tmp) || range_is_zero(&tmp) ||
 	    tmp.lsr_start < range->lsr_start || tmp.lsr_end > range->lsr_end)
 		return -EINVAL;
-- 
2.6.3
