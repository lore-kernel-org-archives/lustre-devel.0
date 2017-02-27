From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:54 -0500
Subject: [lustre-devel] [PATCH 29/34] staging: lustre: lnet: change
	lnet_ins_pos_t to proper enum
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_ins_pos_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h      | 4 ++--
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h | 2 +-
 drivers/staging/lustre/include/linux/lnet/types.h    | 6 +++---
 drivers/staging/lustre/lnet/lnet/lib-me.c            | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c           | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 5537097..125d5cb 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -97,7 +97,7 @@ int LNetMEAttach(unsigned int      portal,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
 		 enum lnet_unlink unlink_in,
-		 lnet_ins_pos_t    pos_in,
+		 enum lnet_ins_pos pos_in,
 		 struct lnet_handle_me *handle_out);
 
 int LNetMEInsert(struct lnet_handle_me current_in,
@@ -105,7 +105,7 @@ int LNetMEInsert(struct lnet_handle_me current_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
 		 enum lnet_unlink unlink_in,
-		 lnet_ins_pos_t    position_in,
+		 enum lnet_ins_pos position_in,
 		 struct lnet_handle_me *handle_out);
 
 int LNetMEUnlink(struct lnet_handle_me current_in);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index e21323f..2d684a7 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -538,7 +538,7 @@ struct list_head *lnet_mt_match_head(struct lnet_match_table *mtable,
 struct lnet_match_table *lnet_mt_of_attach(unsigned int index,
 					   struct lnet_process_id id,
 					   __u64 mbits, __u64 ignore_bits,
-					   lnet_ins_pos_t pos);
+					   enum lnet_ins_pos pos);
 int lnet_mt_match_md(struct lnet_match_table *mtable,
 		     struct lnet_match_info *info, struct lnet_msg *msg);
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 9010895..4fde723 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -352,20 +352,20 @@ enum lnet_unlink {
 };
 
 /**
- * Values of the type lnet_ins_pos_t are used to control where a new match
+ * Values of the type lnet_ins_pos are used to control where a new match
  * entry is inserted. The value LNET_INS_BEFORE is used to insert the new
  * entry before the current entry or before the head of the list. The value
  * LNET_INS_AFTER is used to insert the new entry after the current entry
  * or after the last item in the list.
  */
-typedef enum {
+enum lnet_ins_pos {
 	/** insert ME before current position or head of the list */
 	LNET_INS_BEFORE,
 	/** insert ME after current position or tail of the list */
 	LNET_INS_AFTER,
 	/** attach ME at tail of local CPU partition ME list */
 	LNET_INS_LOCAL
-} lnet_ins_pos_t;
+};
 
 /** @} lnet_me */
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index a944f1f..e9b3eed 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -72,7 +72,7 @@
 LNetMEAttach(unsigned int portal,
 	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
-	     enum lnet_unlink unlink, lnet_ins_pos_t pos,
+	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
 	     struct lnet_handle_me *handle)
 {
 	struct lnet_match_table *mtable;
@@ -143,7 +143,7 @@
 LNetMEInsert(struct lnet_handle_me current_meh,
 	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
-	     enum lnet_unlink unlink, lnet_ins_pos_t pos,
+	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
 	     struct lnet_handle_me *handle)
 {
 	struct lnet_me *current_me;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index fc67af0..63cce0c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -224,7 +224,7 @@
 
 struct lnet_match_table *
 lnet_mt_of_attach(unsigned int index, struct lnet_process_id id,
-		  __u64 mbits, __u64 ignore_bits, lnet_ins_pos_t pos)
+		  __u64 mbits, __u64 ignore_bits, enum lnet_ins_pos pos)
 {
 	struct lnet_portal *ptl;
 	struct lnet_match_table	*mtable;
-- 
1.8.3.1
