From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:37:02 -0400
Subject: [lustre-devel] [PATCH 17/18] staging: lustre: fix 'no effect' errors
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'no effect' issues found by Coverity version 6.5.1:

Unsigned compared against 0 (NO_EFFECT)
This greater-than-or-equal-to-zero comparison of an unsigned value
is always true.

Remove useless cast.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3907
Reviewed-on: http://review.whamcloud.com/7166
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c |    3 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 6282478..6589108 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -423,8 +423,7 @@ getxattr_nocache:
 	if (rce && rce->rce_ops == RMT_LSETFACL) {
 		ext_acl_xattr_header *acl;
 
-		acl = lustre_posix_acl_xattr_2ext(
-					(posix_acl_xattr_header *)buffer, rc);
+		acl = lustre_posix_acl_xattr_2ext(buffer, rc);
 		if (IS_ERR(acl)) {
 			rc = PTR_ERR(acl);
 			goto out;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8bd2dc5..3969732 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -926,7 +926,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		struct obd_quotactl *oqctl;
 
 		if (qctl->qc_valid == QC_MDTIDX) {
-			if (qctl->qc_idx < 0 || count <= qctl->qc_idx)
+			if (count <= qctl->qc_idx)
 				return -EINVAL;
 
 			tgt = lmv->tgts[qctl->qc_idx];
-- 
1.7.1
