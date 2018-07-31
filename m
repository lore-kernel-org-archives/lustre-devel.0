From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:18 -0400
Subject: [lustre-devel] [PATCH 26/31] lustre: obd: remove unused data
 parameter from obd_notify()
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the unused data parameter from obd_notify() and related
functions.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-8403
Reviewed-on: https://review.whamcloud.com/24428
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |  4 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  | 25 ++++++++--------------
 drivers/staging/lustre/lustre/llite/lcommon_misc.c | 12 +++++------
 .../staging/lustre/lustre/llite/llite_internal.h   |  5 ++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  7 +++---
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 13 +++++------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  6 +++---
 drivers/staging/lustre/lustre/osc/osc_request.c    | 10 ++++-----
 8 files changed, 34 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 10e3bb8..333c703 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -502,7 +502,7 @@ enum obd_notify_event {
  */
 struct obd_notify_upcall {
 	int (*onu_upcall)(struct obd_device *host, struct obd_device *watched,
-			  enum obd_notify_event ev, void *owner, void *data);
+			  enum obd_notify_event ev, void *owner);
 	/* Opaque datum supplied by upper layer listener */
 	void *onu_owner;
 };
@@ -861,7 +861,7 @@ struct obd_ops {
 			    enum obd_import_event);
 
 	int (*notify)(struct obd_device *obd, struct obd_device *watched,
-		      enum obd_notify_event ev, void *data);
+		      enum obd_notify_event ev);
 
 	int (*health_check)(const struct lu_env *env, struct obd_device *);
 	struct obd_uuid *(*get_uuid)(struct obd_export *exp);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 647cc22..50d5ddb 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1074,8 +1074,7 @@ static inline void obd_import_event(struct obd_device *obd,
 
 static inline int obd_notify(struct obd_device *obd,
 			     struct obd_device *watched,
-			     enum obd_notify_event ev,
-			     void *data)
+			     enum obd_notify_event ev)
 {
 	int rc;
 
@@ -1094,35 +1093,29 @@ static inline int obd_notify(struct obd_device *obd,
 	}
 
 	OBD_COUNTER_INCREMENT(obd, notify);
-	rc = OBP(obd, notify)(obd, watched, ev, data);
+	rc = OBP(obd, notify)(obd, watched, ev);
 	return rc;
 }
 
 static inline int obd_notify_observer(struct obd_device *observer,
 				      struct obd_device *observed,
-				      enum obd_notify_event ev,
-				      void *data)
+				      enum obd_notify_event ev)
 {
-	int rc1;
-	int rc2;
-
 	struct obd_notify_upcall *onu;
+	int rc = 0;
+	int rc2 = 0;
 
 	if (observer->obd_observer)
-		rc1 = obd_notify(observer->obd_observer, observed, ev, data);
-	else
-		rc1 = 0;
+		rc = obd_notify(observer->obd_observer, observed, ev);
+
 	/*
 	 * Also, call non-obd listener, if any
 	 */
 	onu = &observer->obd_upcall;
 	if (onu->onu_upcall)
-		rc2 = onu->onu_upcall(observer, observed, ev,
-				      onu->onu_owner, NULL);
-	else
-		rc2 = 0;
+		rc2 = onu->onu_upcall(observer, observed, ev, onu->onu_owner);
 
-	return rc1 ? rc1 : rc2;
+	return rc ? rc : rc2;
 }
 
 static inline int obd_quotactl(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index a246b95..80563a2 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -76,14 +76,12 @@ int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 }
 
 /**
- * This function is used as an upcall-callback hooked by liblustre and llite
- * clients into obd_notify() listeners chain to handle notifications about
- * change of import connect_flags. See llu_fsswop_mount() and
- * lustre_common_fill_super().
+ * This function is used as an upcall-callback hooked llite clients
+ * into obd_notify() listeners chain to handle notifications about
+ * change of import connect_flags. See lustre_common_fill_super().
  */
-int cl_ocd_update(struct obd_device *host,
-		  struct obd_device *watched,
-		  enum obd_notify_event ev, void *owner, void *data)
+int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
+		  enum obd_notify_event ev, void *owner)
 {
 	struct lustre_client_ocd *lco;
 	struct client_obd	*cli;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f6c8daf..00fe706 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -669,9 +669,8 @@ static inline bool ll_sbi_has_fast_read(struct ll_sb_info *sbi)
 
 /* llite/lcommon_misc.c */
 int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp);
-int cl_ocd_update(struct obd_device *host,
-		  struct obd_device *watched,
-		  enum obd_notify_event ev, void *owner, void *data);
+int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
+		  enum obd_notify_event ev, void *owner);
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		     struct ll_grouplock *cg);
 void cl_put_grouplock(struct ll_grouplock *cg);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index bbb1ddf..55db904 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -140,7 +140,7 @@ static struct obd_uuid *lmv_get_uuid(struct obd_export *exp)
 }
 
 static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
-		      enum obd_notify_event ev, void *data)
+		      enum obd_notify_event ev)
 {
 	struct obd_connect_data *conn_data;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -182,7 +182,7 @@ static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
 	 * Pass the notification up the chain.
 	 */
 	if (obd->obd_observer)
-		rc = obd_notify(obd->obd_observer, watched, ev, data);
+		rc = obd_notify(obd->obd_observer, watched, ev);
 
 	return rc;
 }
@@ -330,8 +330,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 		 * Tell the observer about the new target.
 		 */
 		rc = obd_notify(obd->obd_observer, mdc_exp->exp_obd,
-				OBD_NOTIFY_ACTIVE,
-				(void *)(tgt - lmv->tgts[0]));
+				OBD_NOTIFY_ACTIVE);
 		if (rc) {
 			obd_disconnect(mdc_exp);
 			return rc;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 85d3b29..07f6b1b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -121,7 +121,7 @@ static void lov_putref(struct obd_device *obd)
 static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 			      enum obd_notify_event ev);
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
-		      enum obd_notify_event ev, void *data);
+		      enum obd_notify_event ev);
 
 int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 		    struct obd_connect_data *data)
@@ -244,7 +244,7 @@ static int lov_connect(const struct lu_env *env,
 			continue;
 
 		rc = lov_notify(obd, lov->lov_tgts[i]->ltd_exp->exp_obd,
-				OBD_NOTIFY_CONNECT, (void *)&i);
+				OBD_NOTIFY_CONNECT);
 		if (rc) {
 			CERROR("%s error sending notify %d\n",
 			       obd->obd_name, rc);
@@ -423,7 +423,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 }
 
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
-		      enum obd_notify_event ev, void *data)
+		      enum obd_notify_event ev)
 {
 	int rc = 0;
 	struct lov_obd *lov = &obd->u.lov;
@@ -457,12 +457,10 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 			       obd_uuid2str(uuid), rc);
 			goto out_notify_lock;
 		}
-		/* active event should be pass lov target index as data */
-		data = &rc;
 	}
 
 	/* Pass the notification up the chain. */
-	rc = obd_notify_observer(obd, watched, ev, data);
+	rc = obd_notify_observer(obd, watched, ev);
 
 out_notify_lock:
 	up_read(&lov->lov_notify_lock);
@@ -590,8 +588,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	}
 
 	rc = lov_notify(obd, tgt->ltd_exp->exp_obd,
-			active ? OBD_NOTIFY_CONNECT : OBD_NOTIFY_INACTIVE,
-			(void *)&index);
+			active ? OBD_NOTIFY_CONNECT : OBD_NOTIFY_INACTIVE);
 
 out:
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index bfa07d7..c2f0a54 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2520,7 +2520,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		if (cli->cl_seq)
 			seq_client_flush(cli->cl_seq);
 
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE);
 		break;
 	}
 	case IMP_EVENT_INVALIDATE: {
@@ -2531,7 +2531,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		break;
 	}
 	case IMP_EVENT_ACTIVE:
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE);
 		/* redo the kuc registration after reconnecting */
 		if (rc == 0)
 			/* re-register HSM agents */
@@ -2540,7 +2540,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 						       (void *)imp);
 		break;
 	case IMP_EVENT_OCD:
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
 	case IMP_EVENT_DISCON:
 	case IMP_EVENT_DEACTIVATE:
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index b7f8e07..b2b55a7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2678,7 +2678,7 @@ static int osc_import_event(struct obd_device *obd,
 		break;
 	}
 	case IMP_EVENT_INACTIVE: {
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE);
 		break;
 	}
 	case IMP_EVENT_INVALIDATE: {
@@ -2704,7 +2704,7 @@ static int osc_import_event(struct obd_device *obd,
 		break;
 	}
 	case IMP_EVENT_ACTIVE: {
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE);
 		break;
 	}
 	case IMP_EVENT_OCD: {
@@ -2717,15 +2717,15 @@ static int osc_import_event(struct obd_device *obd,
 		if (ocd->ocd_connect_flags & OBD_CONNECT_REQPORTAL)
 			imp->imp_client->cli_request_portal = OST_REQUEST_PORTAL;
 
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
 	}
 	case IMP_EVENT_DEACTIVATE: {
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_DEACTIVATE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_DEACTIVATE);
 		break;
 	}
 	case IMP_EVENT_ACTIVATE: {
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVATE, NULL);
+		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVATE);
 		break;
 	}
 	default:
-- 
1.8.3.1
