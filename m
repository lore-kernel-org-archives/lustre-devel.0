From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:44 -0500
Subject: [lustre-devel] [PATCH 11/28] lustre: ptlrpc: remove unused code at
 pinger
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <alexander.boyko@hpe.com>

The timeout_list was previously used for grant shrinking,
but right now is dead code.

HPE-bug-id: LUS-8520
Fixes: abc88e83673c ("lustre: osc: depart grant shrinking from pinger")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14031
Lustre-commit: f022663059414 ("LU-14031 ptlrpc: remove unused code at pinger")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/40243
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |   5 --
 fs/lustre/ptlrpc/pinger.c      | 137 -----------------------------------------
 2 files changed, 142 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 1e7fe03..61be05c 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2369,11 +2369,6 @@ enum timeout_event {
 typedef int (*timeout_cb_t)(struct timeout_item *, void *);
 int ptlrpc_pinger_add_import(struct obd_import *imp);
 int ptlrpc_pinger_del_import(struct obd_import *imp);
-int ptlrpc_add_timeout_client(time64_t time, enum timeout_event event,
-			      timeout_cb_t cb, void *data,
-			      struct list_head *obd_list);
-int ptlrpc_del_timeout_client(struct list_head *obd_list,
-			      enum timeout_event event);
 struct ptlrpc_request *ptlrpc_prep_ping(struct obd_import *imp);
 int ptlrpc_obd_ping(struct obd_device *obd);
 void ptlrpc_pinger_ir_up(void);
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 9f57c61..e23ba3c 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -51,7 +51,6 @@
 
 struct mutex pinger_mutex;
 static LIST_HEAD(pinger_imports);
-static LIST_HEAD(timeout_list);
 
 struct ptlrpc_request *
 ptlrpc_prep_ping(struct obd_import *imp)
@@ -162,20 +161,8 @@ static inline time64_t ptlrpc_next_reconnect(struct obd_import *imp)
 
 static time64_t pinger_check_timeout(time64_t time)
 {
-	struct timeout_item *item;
 	time64_t timeout = PING_INTERVAL;
 
-	/* This list is sorted in increasing timeout order */
-	mutex_lock(&pinger_mutex);
-	list_for_each_entry(item, &timeout_list, ti_chain) {
-		time64_t ti_timeout = item->ti_timeout;
-
-		if (timeout > ti_timeout)
-			timeout = ti_timeout;
-		break;
-	}
-	mutex_unlock(&pinger_mutex);
-
 	return time + timeout - ktime_get_seconds();
 }
 
@@ -259,16 +246,12 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 static void ptlrpc_pinger_main(struct work_struct *ws)
 {
 	time64_t this_ping, time_after_ping, time_to_next_wake;
-	struct timeout_item *item;
 	struct obd_import *imp;
 
 	do {
 		this_ping = ktime_get_seconds();
 
 		mutex_lock(&pinger_mutex);
-		list_for_each_entry(item, &timeout_list, ti_chain) {
-			item->ti_cb(item, item->ti_cb_data);
-		}
 		list_for_each_entry(imp, &pinger_imports, imp_pinger_chain) {
 			ptlrpc_pinger_process_import(imp, this_ping);
 			/* obd_timeout might have changed */
@@ -323,15 +306,12 @@ int ptlrpc_start_pinger(void)
 	return 0;
 }
 
-static int ptlrpc_pinger_remove_timeouts(void);
-
 int ptlrpc_stop_pinger(void)
 {
 #ifdef CONFIG_LUSTRE_FS_PINGER
 	if (!pinger_wq)
 		return -EALREADY;
 
-	ptlrpc_pinger_remove_timeouts();
 	cancel_delayed_work_sync(&ping_work);
 	destroy_workqueue(pinger_wq);
 	pinger_wq = NULL;
@@ -398,123 +378,6 @@ int ptlrpc_pinger_del_import(struct obd_import *imp)
 }
 EXPORT_SYMBOL(ptlrpc_pinger_del_import);
 
-/**
- * Register a timeout callback to the pinger list, and the callback will
- * be called when timeout happens.
- */
-static struct timeout_item *ptlrpc_new_timeout(time64_t time,
-					       enum timeout_event event,
-					       timeout_cb_t cb, void *data)
-{
-	struct timeout_item *ti;
-
-	ti = kzalloc(sizeof(*ti), GFP_NOFS);
-	if (!ti)
-		return NULL;
-
-	INIT_LIST_HEAD(&ti->ti_obd_list);
-	INIT_LIST_HEAD(&ti->ti_chain);
-	ti->ti_timeout = time;
-	ti->ti_event = event;
-	ti->ti_cb = cb;
-	ti->ti_cb_data = data;
-
-	return ti;
-}
-
-/**
- * Register timeout event on the pinger thread.
- * Note: the timeout list is an sorted list with increased timeout value.
- */
-static struct timeout_item*
-ptlrpc_pinger_register_timeout(time64_t time, enum timeout_event event,
-			       timeout_cb_t cb, void *data)
-{
-	struct timeout_item *item, *tmp;
-
-	LASSERT(mutex_is_locked(&pinger_mutex));
-
-	list_for_each_entry(item, &timeout_list, ti_chain)
-		if (item->ti_event == event)
-			goto out;
-
-	item = ptlrpc_new_timeout(time, event, cb, data);
-	if (item) {
-		list_for_each_entry_reverse(tmp, &timeout_list, ti_chain) {
-			if (tmp->ti_timeout < time) {
-				list_add(&item->ti_chain, &tmp->ti_chain);
-				goto out;
-			}
-		}
-		list_add(&item->ti_chain, &timeout_list);
-	}
-out:
-	return item;
-}
-
-/* Add a client_obd to the timeout event list, when timeout(@time)
- * happens, the callback(@cb) will be called.
- */
-int ptlrpc_add_timeout_client(time64_t time, enum timeout_event event,
-			      timeout_cb_t cb, void *data,
-			      struct list_head *obd_list)
-{
-	struct timeout_item *ti;
-
-	mutex_lock(&pinger_mutex);
-	ti = ptlrpc_pinger_register_timeout(time, event, cb, data);
-	if (!ti) {
-		mutex_unlock(&pinger_mutex);
-		return -EINVAL;
-	}
-	list_add(obd_list, &ti->ti_obd_list);
-	mutex_unlock(&pinger_mutex);
-	return 0;
-}
-EXPORT_SYMBOL(ptlrpc_add_timeout_client);
-
-int ptlrpc_del_timeout_client(struct list_head *obd_list,
-			      enum timeout_event event)
-{
-	struct timeout_item *ti = NULL, *item;
-
-	if (list_empty(obd_list))
-		return 0;
-	mutex_lock(&pinger_mutex);
-	list_del_init(obd_list);
-	/**
-	 * If there are no obd attached to the timeout event
-	 * list, remove this timeout event from the pinger
-	 */
-	list_for_each_entry(item, &timeout_list, ti_chain) {
-		if (item->ti_event == event) {
-			ti = item;
-			break;
-		}
-	}
-	if (list_empty(&ti->ti_obd_list)) {
-		list_del(&ti->ti_chain);
-		kfree(ti);
-	}
-	mutex_unlock(&pinger_mutex);
-	return 0;
-}
-EXPORT_SYMBOL(ptlrpc_del_timeout_client);
-
-static int ptlrpc_pinger_remove_timeouts(void)
-{
-	struct timeout_item *item, *tmp;
-
-	mutex_lock(&pinger_mutex);
-	list_for_each_entry_safe(item, tmp, &timeout_list, ti_chain) {
-		LASSERT(list_empty(&item->ti_obd_list));
-		list_del(&item->ti_chain);
-		kfree(item);
-	}
-	mutex_unlock(&pinger_mutex);
-	return 0;
-}
-
 void ptlrpc_pinger_wake_up(void)
 {
 #ifdef CONFIG_LUSTRE_FS_PINGER
-- 
1.8.3.1
