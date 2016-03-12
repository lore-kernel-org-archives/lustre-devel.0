From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:44 -0500
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: fix spacing issues
	checkpatch reported in lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove any extra spacing as reported by checkpatch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c |    6 +++---
 drivers/staging/lustre/lnet/selftest/console.c  |    6 +++---
 drivers/staging/lustre/lnet/selftest/selftest.h |    2 +-
 drivers/staging/lustre/lnet/selftest/timer.h    |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 7bfc0db..18c7422 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -194,12 +194,12 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 		return 0;
 
 	if (pattern == LST_BRW_CHECK_SIMPLE) {
-		data = *((__u64 *) addr);
+		data = *((__u64 *)addr);
 		if (data != magic)
 			goto bad_data;
 
 		addr += PAGE_CACHE_SIZE - BRW_MSIZE;
-		data = *((__u64 *) addr);
+		data = *((__u64 *)addr);
 		if (data != magic)
 			goto bad_data;
 
@@ -208,7 +208,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 
 	if (pattern == LST_BRW_CHECK_FULL) {
 		for (i = 0; i < PAGE_CACHE_SIZE / BRW_MSIZE; i++) {
-			data = *(((__u64 *) addr) + i);
+			data = *(((__u64 *)addr) + i);
 			if (data != magic)
 				goto bad_data;
 		}
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 9f1838f..b0c9acd 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -207,7 +207,7 @@ lstcon_group_alloc(char *name, lstcon_group_t **grpp)
 
 	grp->grp_ref = 1;
 	if (name) {
-		if (strlen(name) > sizeof(grp->grp_name)-1) {
+		if (strlen(name) > sizeof(grp->grp_name) - 1) {
 			LIBCFS_FREE(grp, offsetof(lstcon_group_t,
 				    grp_ndl_hash[LST_NODE_HASHSIZE]));
 			return -E2BIG;
@@ -525,7 +525,7 @@ lstcon_group_add(char *name)
 	lstcon_group_t *grp;
 	int rc;
 
-	rc = lstcon_group_find(name, &grp) ? 0: -EEXIST;
+	rc = lstcon_group_find(name, &grp) ? 0 : -EEXIST;
 	if (rc) {
 		/* find a group with same name */
 		lstcon_group_decref(grp);
@@ -1746,7 +1746,7 @@ lstcon_session_new(char *name, int key, unsigned feats,
 	console_session.ses_timeout = (timeout <= 0) ?
 				      LST_CONSOLE_TIMEOUT : timeout;
 
-	if (strlen(name) > sizeof(console_session.ses_name)-1)
+	if (strlen(name) > sizeof(console_session.ses_name) - 1)
 		return -E2BIG;
 	strncpy(console_session.ses_name, name,
 		sizeof(console_session.ses_name));
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 9669088..b605f7f 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -415,7 +415,7 @@ typedef struct sfw_test_case {
 srpc_client_rpc_t *
 sfw_create_rpc(lnet_process_id_t peer, int service,
 	       unsigned features, int nbulkiov, int bulklen,
-	       void (*done) (srpc_client_rpc_t *), void *priv);
+	       void (*done)(srpc_client_rpc_t *), void *priv);
 int sfw_create_test_rpc(sfw_test_unit_t *tsu,
 			lnet_process_id_t peer, unsigned features,
 			int nblk, int blklen, srpc_client_rpc_t **rpc);
diff --git a/drivers/staging/lustre/lnet/selftest/timer.h b/drivers/staging/lustre/lnet/selftest/timer.h
index 2affecf..39327bb 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.h
+++ b/drivers/staging/lustre/lnet/selftest/timer.h
@@ -41,7 +41,7 @@
 struct stt_timer {
 	struct list_head stt_list;
 	time64_t         stt_expires;
-	void             (*stt_func) (void *);
+	void             (*stt_func)(void *);
 	void             *stt_data;
 };
 
-- 
1.7.1
