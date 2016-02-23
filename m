From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:59 -0500
Subject: [lustre-devel] [PATCH 21/56] staging/lustre: Get rid of
	ldlm_ns_type_t typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ldlm_ns_type

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 0f229b9..ab40bc7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -318,7 +318,7 @@ enum {
 	LDLM_NSS_LAST
 };
 
-typedef enum {
+enum ldlm_ns_type {
 	/** invalid type */
 	LDLM_NS_TYPE_UNKNOWN    = 0,
 	/** mdc namespace */
@@ -333,7 +333,7 @@ typedef enum {
 	LDLM_NS_TYPE_MGC,
 	/** mgs namespace */
 	LDLM_NS_TYPE_MGT,
-} ldlm_ns_type_t;
+};
 
 /**
  * LDLM Namespace.
@@ -1177,7 +1177,7 @@ void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
 struct ldlm_namespace *
 ldlm_namespace_new(struct obd_device *obd, char *name,
 		   ldlm_side_t client, enum ldlm_appetite apt,
-		   ldlm_ns_type_t ns_type);
+		   enum ldlm_ns_type ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
 void ldlm_namespace_put(struct ldlm_namespace *ns);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index c22370b..d0ad28d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -241,7 +241,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	struct obd_uuid server_uuid;
 	int rq_portal, rp_portal, connect_op;
 	char *name = obddev->obd_type->typ_name;
-	ldlm_ns_type_t ns_type = LDLM_NS_TYPE_UNKNOWN;
+	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
 	int rc;
 
 	/* In a more perfect world, we would hang a ptlrpc_client off of
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 582cb21..9ab4452 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -554,7 +554,7 @@ static struct cfs_hash_ops ldlm_ns_fid_hash_ops = {
 };
 
 struct ldlm_ns_hash_def {
-	ldlm_ns_type_t  nsd_type;
+	enum ldlm_ns_type nsd_type;
 	/** hash bucket bits */
 	unsigned	nsd_bkt_bits;
 	/** hash bits */
@@ -622,7 +622,7 @@ static void ldlm_namespace_register(struct ldlm_namespace *ns,
 struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					  ldlm_side_t client,
 					  enum ldlm_appetite apt,
-					  ldlm_ns_type_t ns_type)
+					  enum ldlm_ns_type ns_type)
 {
 	struct ldlm_namespace *ns = NULL;
 	struct ldlm_ns_bucket *nsb;
-- 
2.1.0
