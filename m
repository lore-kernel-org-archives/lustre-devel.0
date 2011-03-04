From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Thu, 03 Mar 2011 23:48:57 -0500
Subject: [Lustre-devel] lustre 1.8+ issues with automounter
Message-ID: <4D706F39.2070807@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ever since we moved from Lustre 1.6.6 to 1.8 I've seen issues with using
the automounter and Lustre.  I've finally got around to looking at what
the issue is, but I'm not quite sure what the correct way to resolve it
is.  I think the issue will remain in 2.0+ but I didn't look closely at
the code.  The issue is that lov_connect which calls lov_connect_obd is
an asynchronous connect that does not wait for all OSCs to be connected
before returning.  In the end lustre_fill_super can return before all
OSCs have been set active so any file operations that caused the
automount may return an error.  Many lov functions check to make sure
the lov_tgt_desc ltd_active flag is 1 or return -EIO. 

The following patch handles things correctly by waiting until all OSC's
that are set to be activated are active before returning from filling
the super block.  There are a few problems that I'm not sure of what the
expected results are with Lustre.  For example if an OST has not been
mounted the client will attempt to connect and end up returning -ENODEV
and setting the import_state as LUSTRE_IMP_DISCON.  Without the patch
the client mounts immediately even though the OSC is unavailable, with
it the mount would not return until the user kills the process, the OBD
is set inactive, or the state changes.  To provide the same
functionality an extra condition would need to be added to the
l_wait_event condition to monitor the import state is not connecting. 
However if I do that, I'm not sure things handle failover nodes
correctly.  So what I'm wondering is what are the expected actions for
the different conditions of OSTs.

Thanks,
Jeremy

diff --git a/lustre/include/obd.h b/lustre/include/obd.h
index e89805d..3046a5c 100644
--- a/lustre/include/obd.h
+++ b/lustre/include/obd.h
@@ -754,6 +754,8 @@ struct lov_tgt_desc {
         unsigned long       ltd_active:1,/* is this target up for
requests */
                             ltd_activate:1,/* should this target be
activated */
                             ltd_reap:1;  /* should this target be
deleted */
+    cfs_waitq_t         ltd_started; /* waitqueue to notify tgt has
been fully started
+                                      * so IO can start */
 };
 
 /* Pool metadata */
@@ -942,6 +944,8 @@ enum obd_notify_event {
         OBD_NOTIFY_ACTIVE,
         /* Device deactivated */
         OBD_NOTIFY_INACTIVE,
+        /* Device disconnected */
+        OBD_NOTIFY_DISCON,
         /* Connect data for import were changed */
         OBD_NOTIFY_OCD,
         /* Sync request */
diff --git a/lustre/lov/lov_obd.c b/lustre/lov/lov_obd.c
index 8b2d848..ff4a04a 100644
--- a/lustre/lov/lov_obd.c
+++ b/lustre/lov/lov_obd.c
@@ -222,7 +222,33 @@ static int lov_notify(struct obd_device *obd,
struct obd_device *watched,
                 }
                 /* active event should be pass lov target index as data */
                 data = &rc;
-        }
+        } else if (ev == OBD_NOTIFY_DISCON) {
+        struct lov_tgt_desc *tgt;
+        struct lov_obd *lov = &obd->u.lov;
+        int i;
+
+        LASSERT(watched);
+                if (strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME)) {
+                        CERROR("unexpected notification of %s %s!\n",
+                               watched->obd_type->typ_name,
+                               watched->obd_name);
+                        RETURN(-EINVAL);
+        }
+
+        obd_getref(obd);
+        for (i = 0; i < lov->desc.ld_tgt_count; i++) {
+            tgt = lov->lov_tgts[i];
+            if (!tgt || !tgt->ltd_exp)
+                continue;
+
+            if (obd_uuid_equals(&watched->u.cli.cl_target_uuid,
&tgt->ltd_uuid)) {
+                cfs_waitq_signal(&lov->lov_tgts[i]->ltd_started);
+                data = &i;
+                break;
+            }
+        }
+        obd_putref(obd);
+    }
 
         /* Pass the notification up the chain. */
         if (watched) {
@@ -424,6 +450,27 @@ static int lov_connect(struct lustre_handle *conn,
struct obd_device *obd,
                                obd->obd_name, rc);
                 }
         }
+
+    /* Wait for all the connections to complete before returning so
that all
+         * obds are set active that should be.  Otherwise IO that
happens immediately
+     * after mount could (autofs) could glimpse or touch objects before
the connecction
+     * is established */
+    for (i = 0; i < lov->desc.ld_tgt_count; i++) {
+        struct l_wait_info lwi = { 0 };
+
+        tgt = lov->lov_tgts[i];
+        if (!tgt || !tgt->ltd_exp || obd_uuid_empty(&tgt->ltd_uuid))
+            continue;
+
+        if (tgt->ltd_activate == tgt->ltd_active)
+            continue;
+
+        CDEBUG(D_CONFIG, "Target %s activate/active %d/%d, waiting on
state change\n",
+               tgt->ltd_obd->obd_name, tgt->ltd_activate, tgt->ltd_active);
+
+        l_wait_event(tgt->ltd_started, tgt->ltd_activate ==
tgt->ltd_active ||
+                     tgt->ltd_obd->u.cli.cl_import->imp_deactive, &lwi);
+    }
         obd_putref(obd);
 
         RETURN(0);
@@ -445,6 +492,9 @@ static int lov_disconnect_obd(struct obd_device
*obd, struct lov_tgt_desc *tgt)
                 tgt->ltd_active = 0;
                 lov->desc.ld_active_tgt_count--;
                 tgt->ltd_exp->exp_obd->obd_inactive = 1;
+
+        /* If state change wake up wait queue */
+        cfs_waitq_signal(&tgt->ltd_started);
         }
 
         lov_proc_dir = lprocfs_srch(obd->obd_proc_entry, "target_obds");
@@ -582,6 +632,9 @@ static int lov_set_osc_active(struct obd_device
*obd, struct obd_uuid *uuid,
         lov->lov_tgts[i]->ltd_qos.ltq_penalty = 0;
 
  out:
+    if (i >= 0)
+        cfs_waitq_signal(&lov->lov_tgts[i]->ltd_started);
+
         obd_putref(obd);
         RETURN(i);
 }
@@ -673,6 +726,8 @@ static int lov_add_target(struct obd_device *obd,
struct obd_uuid *uuidp,
         if (index >= lov->desc.ld_tgt_count)
                 lov->desc.ld_tgt_count = index + 1;
 
+    cfs_waitq_init(&tgt->ltd_started);
+
         mutex_up(&lov->lov_lock);
 
         CDEBUG(D_CONFIG, "idx=%d ltd_gen=%d ld_tgt_count=%d\n",
diff --git a/lustre/osc/osc_request.c b/lustre/osc/osc_request.c
index 7dd8667..cfc6ccf 100644
--- a/lustre/osc/osc_request.c
+++ b/lustre/osc/osc_request.c
@@ -4398,6 +4398,7 @@ static int osc_import_event(struct obd_device *obd,
                 cli->cl_lost_grant = 0;
                 client_obd_list_unlock(&cli->cl_loi_list_lock);
                 ptlrpc_import_setasync(imp, -1);
+        obd_notify_observer(obd, obd, OBD_NOTIFY_DISCON, NULL);
 
                 break;
         }
