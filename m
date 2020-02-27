From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:08 -0500
Subject: [lustre-devel] [PATCH 140/622] lustre: class: use
 INIT_LIST_HEAD_RCU instead INIT_LIST_HEAD
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-141-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

Use INIT_LIST_HEAD_RCU to avoid compiler optimization too much
in some case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11453
Lustre-commit: 68bc3984975b ("LU-11453 class: use INIT_LIST_HEAD_RCU instead INIT_LIST_HEAD")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33317
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index da53572..4465dd9 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -821,7 +821,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 	spin_lock_init(&export->exp_uncommitted_replies_lock);
 	INIT_LIST_HEAD(&export->exp_uncommitted_replies);
 	INIT_LIST_HEAD(&export->exp_req_replay_queue);
-	INIT_LIST_HEAD(&export->exp_handle.h_link);
+	INIT_LIST_HEAD_RCU(&export->exp_handle.h_link);
 	INIT_LIST_HEAD(&export->exp_hp_rpcs);
 	class_handle_hash(&export->exp_handle, &export_handle_ops);
 	spin_lock_init(&export->exp_lock);
@@ -1018,7 +1018,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_replay_inflight, 0);
 	atomic_set(&imp->imp_inval_count, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
-	INIT_LIST_HEAD(&imp->imp_handle.h_link);
+	INIT_LIST_HEAD_RCU(&imp->imp_handle.h_link);
 	class_handle_hash(&imp->imp_handle, &import_handle_ops);
 	init_imp_at(&imp->imp_at);
 
-- 
1.8.3.1
