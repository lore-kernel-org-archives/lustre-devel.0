From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:53 -0500
Subject: [lustre-devel] [PATCH 25/60] staging: lustre: llite: normal user
	can't set FS default stripe
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Current client doesn't check permission before updating filesystem
default stripe on MGS, which isn't secure and obvious.

Since we setattr on MDS first, and then set default stripe on MGS,
we can just return error upon setattr failure.

Now filesystem default stripe is stored in ROOT in MDT, so saving
it in system config is for compatibility with old servers, this
will be removed in the future.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8454
Reviewed-on: http://review.whamcloud.com/21612
Reviewed-on: http://review.whamcloud.com/22580
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 526fea2..13b3592 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -521,12 +521,15 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	rc = md_setattr(sbi->ll_md_exp, op_data, lump, lum_size, &req);
 	ll_finish_md_op_data(op_data);
 	ptlrpc_req_finished(req);
-	if (rc) {
-		if (rc != -EPERM && rc != -EACCES)
-			CERROR("mdc_setattr fails: rc = %d\n", rc);
-	}
+	if (rc)
+		return rc;
 
-	/* In the following we use the fact that LOV_USER_MAGIC_V1 and
+#if OBD_OCD_VERSION(2, 13, 53, 0) > LUSTRE_VERSION_CODE
+	/*
+	 * 2.9 server has stored filesystem default stripe in ROOT xattr,
+	 * and it's stored into system config for backward compatibility.
+	 *
+	 * In the following we use the fact that LOV_USER_MAGIC_V1 and
 	 * LOV_USER_MAGIC_V3 have the same initial fields so we do not
 	 * need to make the distinction between the 2 versions
 	 */
@@ -567,6 +570,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 end:
 		kfree(param);
 	}
+#endif
 	return rc;
 }
 
-- 
1.8.3.1
