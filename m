From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:01 -0500
Subject: [lustre-devel] [PATCH 23/56] staging/lustre/llite: Get rid of
	se_stat_t typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum se_stat

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/statahead.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 4b215d3..db220f2 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -49,13 +49,13 @@
 
 #define SA_OMITTED_ENTRY_MAX 8ULL
 
-typedef enum {
+enum se_stat {
 	/** negative values are for error cases */
 	SA_ENTRY_INIT = 0,      /** init entry */
 	SA_ENTRY_SUCC = 1,      /** stat succeed */
 	SA_ENTRY_INVA = 2,      /** invalid entry */
 	SA_ENTRY_DEST = 3,      /** entry to be destroyed */
-} se_stat_t;
+};
 
 struct ll_sa_entry {
 	/* link into sai->sai_entries */
@@ -71,7 +71,7 @@ struct ll_sa_entry {
 	/* low layer ldlm lock handle */
 	__u64		   se_handle;
 	/* entry status */
-	se_stat_t	       se_stat;
+	enum se_stat	   se_stat;
 	/* entry size, contains name */
 	int		     se_size;
 	/* pointer to async getattr enqueue info */
@@ -366,7 +366,7 @@ ll_sa_entry_fini(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
  */
 static void
 do_sa_entry_to_stated(struct ll_statahead_info *sai,
-		      struct ll_sa_entry *entry, se_stat_t stat)
+		      struct ll_sa_entry *entry, enum se_stat stat)
 {
 	struct ll_sa_entry *se;
 	struct list_head	 *pos = &sai->sai_entries_stated;
@@ -392,7 +392,7 @@ do_sa_entry_to_stated(struct ll_statahead_info *sai,
  */
 static int
 ll_sa_entry_to_stated(struct ll_statahead_info *sai,
-		      struct ll_sa_entry *entry, se_stat_t stat)
+		      struct ll_sa_entry *entry, enum se_stat stat)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
 	int		   ret = 1;
-- 
2.1.0
