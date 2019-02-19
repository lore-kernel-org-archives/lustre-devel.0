From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 16/37] lustre: obdclass: typo: Banlance ->
 Balance
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494567.24125.4188546775209627143.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix mistyped "Balance" in a comment.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/llog_obd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 2b6489e2632d..a89ec816b043 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -112,7 +112,7 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 	idx = ctxt->loc_idx;
 
 	/*
-	 * Banlance the ctxt get when calling llog_cleanup()
+	 * Balance the ctxt get when calling llog_cleanup()
 	 */
 	LASSERT(refcount_read(&ctxt->loc_refcount) < LI_POISON);
 	LASSERT(refcount_read(&ctxt->loc_refcount) > 1);
