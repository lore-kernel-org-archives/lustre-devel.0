From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:02 -0500
Subject: [lustre-devel] [PATCH 01/14] staging: lustre: llite: lower message
	level for ll_setattr_raw()
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Truncate and write can happen at the same time, so that a file can
be set modified even though the file is not restored from released
state, and ll_hsm_state_set() is not applicable for the file, and
it will return error in this case, we'd lower the error message level
in this case.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6817
Reviewed-on: http://review.whamcloud.com/15541
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b229cbc..34422df 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1513,6 +1513,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		 */
 		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
 		op_data->op_bias |= MDS_DATA_MODIFIED;
+		clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
 	}
 
 	rc = ll_md_setattr(dentry, op_data);
@@ -1560,8 +1561,15 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		int rc2;
 
 		rc2 = ll_hsm_state_set(inode, &hss);
+		/*
+		 * truncate and write can happen at the same time, so that
+		 * the file can be set modified even though the file is not
+		 * restored from released state, and ll_hsm_state_set() is
+		 * not applicable for the file, and rc2 < 0 is normal in this
+		 * case.
+		 */
 		if (rc2 < 0)
-			CERROR(DFID "HSM set dirty failed: rc2 = %d\n",
+			CDEBUG(D_INFO, DFID "HSM set dirty failed: rc2 = %d\n",
 			       PFID(ll_inode2fid(inode)), rc2);
 	}
 
-- 
1.8.3.1
