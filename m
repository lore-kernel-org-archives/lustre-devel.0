From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:53 -0500
Subject: [lustre-devel] [PATCH 28/34] staging: lustre: lnet: change
	lnet_unlink_t to proper enum
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_unlink_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h       | 8 ++++----
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 2 +-
 drivers/staging/lustre/include/linux/lnet/types.h     | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-md.c             | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-me.c             | 4 ++--
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 7a67fd2..5537097 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -96,7 +96,7 @@ int LNetMEAttach(unsigned int      portal,
 		 struct lnet_process_id match_id_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
-		 lnet_unlink_t     unlink_in,
+		 enum lnet_unlink unlink_in,
 		 lnet_ins_pos_t    pos_in,
 		 struct lnet_handle_me *handle_out);
 
@@ -104,7 +104,7 @@ int LNetMEInsert(struct lnet_handle_me current_in,
 		 struct lnet_process_id match_id_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
-		 lnet_unlink_t     unlink_in,
+		 enum lnet_unlink unlink_in,
 		 lnet_ins_pos_t    position_in,
 		 struct lnet_handle_me *handle_out);
 
@@ -126,11 +126,11 @@ int LNetMEInsert(struct lnet_handle_me current_in,
  */
 int LNetMDAttach(struct lnet_handle_me current_in,
 		 struct lnet_md md_in,
-		 lnet_unlink_t     unlink_in,
+		 enum lnet_unlink unlink_in,
 		 struct lnet_handle_md *md_handle_out);
 
 int LNetMDBind(struct lnet_md md_in,
-	       lnet_unlink_t       unlink_in,
+	       enum lnet_unlink unlink_in,
 	       struct lnet_handle_md *md_handle_out);
 
 int LNetMDUnlink(struct lnet_handle_md md_in);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 81c93d4..b9f1bd2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -135,7 +135,7 @@ struct lnet_me {
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
 	__u64			 me_match_bits;
 	__u64			 me_ignore_bits;
-	lnet_unlink_t		 me_unlink;
+	enum lnet_unlink	 me_unlink;
 	struct lnet_libmd	*me_md;
 };
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 6a24189..9010895 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -346,10 +346,10 @@ struct lnet_process_id {
  * Specifies whether the match entry or memory descriptor should be unlinked
  * automatically (LNET_UNLINK) or not (LNET_RETAIN).
  */
-typedef enum {
+enum lnet_unlink {
 	LNET_RETAIN = 0,
 	LNET_UNLINK
-} lnet_unlink_t;
+};
 
 /**
  * Values of the type lnet_ins_pos_t are used to control where a new match
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 872f63f..f08e944 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -268,7 +268,7 @@
  */
 int
 LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
-	     lnet_unlink_t unlink, struct lnet_handle_md *handle)
+	     enum lnet_unlink unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
 	LIST_HEAD(drops);
@@ -350,7 +350,7 @@
  * LNetInvalidateHandle() on it.
  */
 int
-LNetMDBind(struct lnet_md umd, lnet_unlink_t unlink,
+LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
 	   struct lnet_handle_md *handle)
 {
 	struct lnet_libmd *md;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index d8f40de..a944f1f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -72,7 +72,7 @@
 LNetMEAttach(unsigned int portal,
 	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
-	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
+	     enum lnet_unlink unlink, lnet_ins_pos_t pos,
 	     struct lnet_handle_me *handle)
 {
 	struct lnet_match_table *mtable;
@@ -143,7 +143,7 @@
 LNetMEInsert(struct lnet_handle_me current_meh,
 	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
-	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
+	     enum lnet_unlink unlink, lnet_ins_pos_t pos,
 	     struct lnet_handle_me *handle)
 {
 	struct lnet_me *current_me;
-- 
1.8.3.1
