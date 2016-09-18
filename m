From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:00 -0400
Subject: [lustre-devel] [PATCH 061/124] staging: lustre: obd: cleanup struct
	md_op_data and uses
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-62-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Make the following changes in or around struct md_op_data:

 * rename enum op_cli_flags to enum md_cli_flags.

 * Change to type of the op_flags member from __u32 to enum
   md_op_flags.

 * Remove the used but never set member op_npages.

 * Remove the set but never used member op_stripe_offset (an alias for
   op_ioepoch).

 * Remove the op_max_pages alias for op_valid and add a op_max_pages
   member.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11734
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h     |   23 ++++++++++-------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    3 +--
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 8a7c803..2d25e40 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -736,6 +736,14 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 	return -EINVAL;
 }
 
+enum md_cli_flags {
+	CLI_SET_MEA	= BIT(0),
+	CLI_RM_ENTRY	= BIT(1),
+	CLI_HASH64	= BIT(2),
+	CLI_API32	= BIT(3),
+	CLI_MIGRATE	= BIT(4),
+};
+
 struct md_op_data {
 	struct lu_fid	   op_fid1; /* operation fid1 (usually parent) */
 	struct lu_fid	   op_fid2; /* operation fid2 (usually child) */
@@ -773,35 +781,24 @@ struct md_op_data {
 	__u64		   op_offset;
 
 	/* Used by readdir */
-	__u32		   op_npages;
+	__u32			op_max_pages;
 
 	/* used to transfer info between the stacks of MD client
 	 * see enum op_cli_flags
 	 */
-	__u32			op_cli_flags;
+	enum md_cli_flags	op_cli_flags;
 
 	/* File object data version for HSM release, on client */
 	__u64			op_data_version;
 	struct lustre_handle	op_lease_handle;
 };
 
-#define op_stripe_offset       op_ioepoch
-#define op_max_pages           op_valid
-
 struct md_callback {
 	int (*md_blocking_ast)(struct ldlm_lock *lock,
 			       struct ldlm_lock_desc *desc,
 			       void *data, int flag);
 };
 
-enum op_cli_flags {
-	CLI_SET_MEA	= 1 << 0,
-	CLI_RM_ENTRY	= 1 << 1,
-	CLI_HASH64	= BIT(2),
-	CLI_API32	= BIT(3),
-	CLI_MIGRATE	= BIT(4),
-};
-
 struct md_enqueue_info;
 /* metadata stat-ahead */
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8c2f6d6..166f0c4 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1264,8 +1264,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 		lu_pgs >>= LU_PAGE_SHIFT;
 		LASSERT(!(req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
 
-		CDEBUG(D_INODE, "read %d(%d)/%d pages\n", rd_pgs, lu_pgs,
-		       op_data->op_npages);
+		CDEBUG(D_INODE, "read %d(%d) pages\n", rd_pgs, lu_pgs);
 
 		mdc_adjust_dirpages(page_pool, rd_pgs, lu_pgs);
 
-- 
1.7.1
