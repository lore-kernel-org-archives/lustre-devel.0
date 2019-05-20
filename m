From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:05 -0400
Subject: [lustre-devel] [PATCH v2 23/29] lustre: remove unused fields from
 struct obd_device
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

One field is set but never access.
Another is accessed but never set.
Other are never mentioned at all.

Also remove the comment
        /* use separate field as it is set in interrupt to don't mess with
         * protection of other bits using _bh lock
         */

This is not correct - were it used, obd_recovery_expired would be part
of the same 'unsigned long' as the other fields.

With the removal of obd_no_transno we can eliminate the ioctl
OBD_IOC_NO_TRANSNO which is server side only.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/obd.h                  | 33 ++++++++++++--------------------
 fs/lustre/mgc/mgc_request.c              |  4 ++--
 fs/lustre/obdclass/class_obd.c           | 27 +++++---------------------
 fs/lustre/obdclass/obd_config.c          |  1 -
 include/uapi/linux/lustre/lustre_ioctl.h |  1 -
 5 files changed, 19 insertions(+), 47 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 3bdde31..93a47cf 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -539,27 +539,18 @@ struct obd_device {
 	char			 obd_name[MAX_OBD_NAME];
 
 	/* bitfield modification is protected by obd_dev_lock */
-	unsigned long obd_attached:1,      /* finished attach */
-		      obd_set_up:1,	/* finished setup */
-		      obd_version_recov:1, /* obd uses version checking */
-		      obd_replayable:1,/* recovery is enabled; inform clients */
-		      obd_no_transno:1,  /* no committed-transno notification */
-		      obd_no_recov:1,      /* fail instead of retry messages */
-		      obd_stopping:1,      /* started cleanup */
-		      obd_starting:1,      /* started setup */
-		      obd_force:1,	 /* cleanup with > 0 obd refcount */
-		      obd_fail:1,	 /* cleanup with failover */
-		      obd_no_conn:1,       /* deny new connections */
-		      obd_inactive:1,      /* device active/inactive
-					    * (for sysfs status only!!)
-					    */
-		      obd_no_ir:1,	 /* no imperative recovery. */
-		      obd_process_conf:1,  /* device is processing mgs config */
-		      obd_checksum_dump:1; /* dump pages upon cksum error */
-	/* use separate field as it is set in interrupt to don't mess with
-	 * protection of other bits using _bh lock
-	 */
-	unsigned long obd_recovery_expired:1;
+	unsigned long obd_attached:1,	  /* finished attach */
+		      obd_set_up:1,	  /* finished setup */
+		      obd_no_recov:1,	  /* fail instead of retry messages */
+		      obd_stopping:1,	  /* started cleanup */
+		      obd_starting:1,	  /* started setup */
+		      obd_force:1,	  /* cleanup with > 0 obd refcount */
+		      obd_fail:1,	  /* cleanup with failover */
+		      obd_inactive:1,	  /* device active/inactive
+					   * (for sysfs status only!!)
+					   */
+		      obd_process_conf:1;/* device is processing mgs config */
+
 	/* uuid-export hash body */
 	struct rhashtable	 obd_uuid_hash;
 	wait_queue_head_t	 obd_refcount_waitq;
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 1eca81a..0d13b17 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -984,10 +984,10 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		if (vallen != sizeof(int))
 			return -EINVAL;
 		value = *(int *)val;
-		CDEBUG(D_MGC, "InitRecov %s %d/d%d:i%d:r%d:or%d:%s\n",
+		CDEBUG(D_MGC, "InitRecov %s %d/d%d:i%d:r%d:%s\n",
 		       imp->imp_obd->obd_name, value,
 		       imp->imp_deactive, imp->imp_invalid,
-		       imp->imp_replayable, imp->imp_obd->obd_replayable,
+		       imp->imp_replayable,
 		       ptlrpc_import_state_name(imp->imp_state));
 		/* Resurrect if we previously died */
 		if ((imp->imp_state != LUSTRE_IMP_FULL &&
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index b8fc740..8e7f7cd 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -516,29 +516,12 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		goto out;
 	}
 
-	switch (cmd) {
-	case OBD_IOC_NO_TRANSNO:
-		if (!obd->obd_attached) {
-			CERROR("Device %d not attached\n", obd->obd_minor);
-			err = -ENODEV;
-			goto out;
-		}
-		CDEBUG(D_HA, "%s: disabling committed-transno notification\n",
-		       obd->obd_name);
-		obd->obd_no_transno = 1;
-		err = 0;
-		break;
-
-	default:
-		err = obd_iocontrol(cmd, obd->obd_self_export, len, data, NULL);
-		if (err)
-			goto out;
-
-		if (copy_to_user((void __user *)arg, data, len))
-			err = -EFAULT;
-		break;
-	}
+	err = obd_iocontrol(cmd, obd->obd_self_export, len, data, NULL);
+	if (err)
+		goto out;
 
+	if (copy_to_user((void __user *)arg, data, len))
+		err = -EFAULT;
  out:
 	kvfree(data);
 	return err;
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 0da69f6..c96cd5c 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -487,7 +487,6 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 				LCONSOLE_WARN("Failing over %s\n",
 					      obd->obd_name);
 				obd->obd_fail = 1;
-				obd->obd_no_transno = 1;
 				obd->obd_no_recov = 1;
 				if (OBP(obd, iocontrol)) {
 					obd_iocontrol(OBD_IOC_SYNC,
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index 098b6451..a2774c2 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -165,7 +165,6 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE)
 
 /*	OBD_IOC_DEC_FS_USE_COUNT _IO('f', 139) */
-#define OBD_IOC_NO_TRANSNO	_IOW('f', 140, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_SET_READONLY	_IOW('f', 141, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_ABORT_RECOVERY	_IOR('f', 142, OBD_IOC_DATA_TYPE)
 /*	OBD_IOC_ROOT_SQUASH	_IOWR('f', 143, OBD_IOC_DATA_TYPE) */
-- 
1.8.3.1
