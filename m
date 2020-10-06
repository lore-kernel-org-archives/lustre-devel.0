From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:06 -0400
Subject: [lustre-devel] [PATCH 27/42] lustre: mgc: Use IR for
 client->MDS/OST connections
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a target registers with the MGS, the MGS sends an IR log
to the client to speed up recovery.

The IR log contains the updated NID information on the target
which just registered.

This patch allows clients to update their imports with the latest
NIDs for the targets reported in the IR log. It also allows clients
to create new connections for targets which were not added via
the config log.

For example if a target reboots and comes up with a new NID, then
the client can continue using it.

This functionality is disabled by default and can be enabled by
setting a new file system specific module parameter, dynamic_nids.

    lctl set_param mgc.*.dynamic_nids=1

This parameters will need to be set on the clients and the MGS

WC-bug-id: https://jira.whamcloud.com/browse/LU-10360
Lustre-commit: 37be05eca3f4ae ("LU-10360 mgc: Use IR for client->MDS/OST connections")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39613
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h   |  4 +++
 fs/lustre/include/obd.h          |  3 ++-
 fs/lustre/include/obd_class.h    |  2 ++
 fs/lustre/ldlm/ldlm_lib.c        | 44 ++++++++++++++++++++++++++++++
 fs/lustre/mgc/lproc_mgc.c        | 30 +++++++++++++++++++++
 fs/lustre/mgc/mgc_request.c      | 58 +++++++++++++++++++++++++++++++---------
 fs/lustre/obdclass/lustre_peer.c | 37 ++++++++++++++++++++++---
 7 files changed, 160 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index d199121..1e7fe03 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2345,6 +2345,10 @@ int client_connect_import(const struct lu_env *env,
 int client_disconnect_export(struct obd_export *exp);
 int client_import_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 			   int priority);
+int client_import_dyn_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
+			       lnet_nid_t prim_nid, int priority);
+int client_import_add_nids_to_conn(struct obd_import *imp, lnet_nid_t *nids,
+				   int nid_count, struct obd_uuid *uuid);
 int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid);
 int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
 			    struct obd_uuid *uuid);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 083884c9f..39e3d51 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -564,7 +564,8 @@ struct obd_device {
 					    */
 		      obd_no_ir:1,	   /* no imperative recovery. */
 		      obd_process_conf:1,  /* device is processing mgs config */
-		      obd_checksum_dump:1; /* dump pages upon cksum error */
+		      obd_checksum_dump:1, /* dump pages upon cksum error */
+		      obd_dynamic_nids:1;  /* Allow dynamic NIDs on device */
 	/* use separate field as it is set in interrupt to don't mess with
 	 * protection of other bits using _bh lock
 	 */
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a22581d..1ac9fcf 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1694,6 +1694,8 @@ struct lwp_register_item {
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index);
 int class_add_uuid(const char *uuid, u64 nid);
 int class_del_uuid(const char *uuid);
+int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
+			   int nid_count);
 int class_check_uuid(struct obd_uuid *uuid, u64 nid);
 
 /* class_obd.c */
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 2698b93..713ca1c 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -140,6 +140,50 @@ int client_import_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 }
 EXPORT_SYMBOL(client_import_add_conn);
 
+int client_import_dyn_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
+			       lnet_nid_t prim_nid, int priority)
+{
+	struct ptlrpc_connection *ptlrpc_conn;
+	int rc;
+
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, prim_nid);
+	if (!ptlrpc_conn) {
+		const char *str_uuid = obd_uuid2str(uuid);
+
+		rc = class_add_uuid(str_uuid, prim_nid);
+		if (rc) {
+			CERROR("%s: failed to add UUID '%s': rc = %d\n",
+			       imp->imp_obd->obd_name, str_uuid, rc);
+			return rc;
+		}
+	}
+	return import_set_conn(imp, uuid, priority, 1);
+}
+EXPORT_SYMBOL(client_import_dyn_add_conn);
+
+int client_import_add_nids_to_conn(struct obd_import *imp, lnet_nid_t *nids,
+				   int nid_count, struct obd_uuid *uuid)
+{
+	struct obd_import_conn *conn;
+	int rc = -ENOENT;
+
+	if (nid_count <= 0 || !nids)
+		return rc;
+
+	spin_lock(&imp->imp_lock);
+	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
+		if (class_check_uuid(&conn->oic_uuid, nids[0])) {
+			*uuid = conn->oic_uuid;
+			rc = class_add_nids_to_uuid(&conn->oic_uuid, nids,
+						    nid_count);
+			break;
+		}
+	}
+	spin_unlock(&imp->imp_lock);
+	return rc;
+}
+EXPORT_SYMBOL(client_import_add_nids_to_conn);
+
 int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
 {
 	struct obd_import_conn *imp_conn;
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index c22ec23..dd7ed0f 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -71,10 +71,40 @@ struct ldebugfs_vars lprocfs_mgc_obd_vars[] = {
 
 LUSTRE_RW_ATTR(ping);
 
+ssize_t dynamic_nids_show(struct kobject *kobj, struct attribute *attr,
+			  char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return scnprintf(buf, PAGE_SIZE, "%u\n", obd->obd_dynamic_nids);
+}
+
+ssize_t dynamic_nids_store(struct kobject *kobj, struct attribute *attr,
+			   const char *buffer, size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	spin_lock(&obd->obd_dev_lock);
+	obd->obd_dynamic_nids = val;
+	spin_unlock(&obd->obd_dev_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(dynamic_nids);
+
 static struct attribute *mgc_attrs[] = {
 	&lustre_attr_mgs_conn_uuid.attr,
 	&lustre_attr_conn_uuid.attr,
 	&lustre_attr_ping.attr,
+	&lustre_attr_dynamic_nids.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index cc3c82e..8133f27 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1107,10 +1107,14 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	int pos;
 	int rc = 0;
 	int off = 0;
+	unsigned long dynamic_nids;
 
 	LASSERT(cfg->cfg_instance);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
 
+	/* get dynamic nids setting */
+	dynamic_nids = mgc->obd_dynamic_nids;
+
 	inst = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!inst)
 		return -ENOMEM;
@@ -1127,7 +1131,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 	while (datalen > 0) {
 		int entry_len = sizeof(*entry);
-		int is_ost, i;
+		int is_ost;
 		struct obd_device *obd;
 		char *obdname;
 		char *cname;
@@ -1236,23 +1240,51 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 		/* iterate all nids to find one */
 		/* find uuid by nid */
-		rc = -ENOENT;
-		for (i = 0; i < entry->mne_nid_count; i++) {
-			rc = client_import_find_conn(obd->u.cli.cl_import,
-						     entry->u.nids[0],
-						     (struct obd_uuid *)uuid);
-			if (!rc)
-				break;
+		/* create import entries if they don't exist */
+		rc = client_import_add_nids_to_conn(obd->u.cli.cl_import,
+						    entry->u.nids,
+						    entry->mne_nid_count,
+						    (struct obd_uuid *)uuid);
+		if (rc == -ENOENT && dynamic_nids) {
+			/* create a new connection for this import */
+			char *primary_nid = libcfs_nid2str(entry->u.nids[0]);
+			int prim_nid_len = strlen(primary_nid) + 1;
+			struct obd_uuid server_uuid;
+
+			if (prim_nid_len > UUID_MAX)
+				goto fail;
+			strncpy(server_uuid.uuid, primary_nid, prim_nid_len);
+
+			CDEBUG(D_INFO, "Adding a connection for %s\n",
+			       primary_nid);
+
+			rc = client_import_dyn_add_conn(obd->u.cli.cl_import,
+							&server_uuid,
+							entry->u.nids[0], 1);
+			if (rc < 0) {
+				CERROR("%s: Failed to add new connection with NID '%s' to import: rc = %d\n",
+				       obd->obd_name, primary_nid, rc);
+				goto fail;
+			}
+			rc = client_import_add_nids_to_conn(obd->u.cli.cl_import,
+							    entry->u.nids,
+							    entry->mne_nid_count,
+							    (struct obd_uuid *)uuid);
+			if (rc < 0) {
+				CERROR("%s: failed to lookup UUID: rc = %d\n",
+				       obd->obd_name, rc);
+				goto fail;
+			}
 		}
-
+fail:
 		up_read(&obd->u.cli.cl_sem);
-		if (rc < 0) {
-			CERROR("mgc: cannot find uuid by nid %s\n",
-			       libcfs_nid2str(entry->u.nids[0]));
+		if (rc < 0 && rc != -ENOSPC) {
+			CERROR("mgc: cannot find UUID by nid '%s': rc = %d\n",
+			       libcfs_nid2str(entry->u.nids[0]), rc);
 			break;
 		}
 
-		CDEBUG(D_INFO, "Find uuid %s by nid %s\n",
+		CDEBUG(D_INFO, "Found UUID '%s' by NID '%s'\n",
 		       uuid, libcfs_nid2str(entry->u.nids[0]));
 
 		pos += strlen(uuid);
diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index 58b6e670..2675594 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -41,13 +41,11 @@
 #include <lustre_net.h>
 #include <lprocfs_status.h>
 
-#define NIDS_MAX	32
-
 struct uuid_nid_data {
 	struct list_head	un_list;
 	struct obd_uuid		un_uuid;
 	int			un_nid_count;
-	lnet_nid_t		un_nids[NIDS_MAX];
+	lnet_nid_t		un_nids[MTI_NIDS_MAX];
 };
 
 /* FIXME: This should probably become more elegant than a global linked list */
@@ -109,7 +107,7 @@ int class_add_uuid(const char *uuid, u64 nid)
 					break;
 
 			if (i == entry->un_nid_count) {
-				LASSERT(entry->un_nid_count < NIDS_MAX);
+				LASSERT(entry->un_nid_count < MTI_NIDS_MAX);
 				entry->un_nids[entry->un_nid_count++] = nid;
 			}
 			break;
@@ -128,6 +126,7 @@ int class_add_uuid(const char *uuid, u64 nid)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(class_add_uuid);
 
 /* Delete the nids for one uuid if specified, otherwise delete all */
 int class_del_uuid(const char *uuid)
@@ -171,6 +170,36 @@ int class_del_uuid(const char *uuid)
 	return 0;
 }
 
+int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
+			   int nid_count)
+{
+	struct uuid_nid_data *entry;
+	int i;
+
+	if (nid_count >= MTI_NIDS_MAX) {
+		CDEBUG(D_NET, "too many NIDs (%d) for UUID '%s'\n",
+		       nid_count, obd_uuid2str(uuid));
+		return -ENOSPC;
+	}
+
+	spin_lock(&g_uuid_lock);
+	list_for_each_entry(entry, &g_uuid_list, un_list) {
+		CDEBUG(D_NET, "Comparing %s with %s\n",
+		       obd_uuid2str(uuid), obd_uuid2str(&entry->un_uuid));
+
+		if (!obd_uuid_equals(&entry->un_uuid, uuid))
+			continue;
+		CDEBUG(D_NET, "Updating UUID '%s'\n", obd_uuid2str(uuid));
+		for (i = 0; i < nid_count; i++)
+			entry->un_nids[i] = nids[i];
+		entry->un_nid_count = nid_count;
+		break;
+	}
+	spin_unlock(&g_uuid_lock);
+	return 0;
+}
+EXPORT_SYMBOL(class_add_nids_to_uuid);
+
 /* check if @nid exists in nid list of @uuid */
 int class_check_uuid(struct obd_uuid *uuid, u64 nid)
 {
-- 
1.8.3.1
