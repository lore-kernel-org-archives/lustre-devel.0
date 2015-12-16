From: Shraddha <shraddha.6596@gmail.com>
Date: Wed, 16 Dec 2015 23:10:15 +0530
Subject: [lustre-devel] [PATCH 1/3] Staging: lustre: include: Remove unused
	llog_backup declaration
In-Reply-To: <1450287617-7682-1-git-send-email-shraddha.6596@gmail.com>
References: <1450287617-7682-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450287617-7682-2-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Function llog_backup is declared in header file but not used.
Thus remove it.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre_log.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 1de0c4d..35196c4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -94,9 +94,6 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	      struct llog_handle **lgh, struct llog_logid *logid,
 	      char *name, enum llog_open_param open_param);
 int llog_close(const struct lu_env *env, struct llog_handle *cathandle);
-int llog_backup(const struct lu_env *env, struct obd_device *obd,
-		struct llog_ctxt *ctxt, struct llog_ctxt *bak_ctxt,
-		char *name, char *backup);
 
 /* llog_process flags */
 #define LLOG_FLAG_NODEAMON 0x0001
-- 
2.1.4
