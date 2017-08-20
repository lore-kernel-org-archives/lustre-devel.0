From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:25:57 -0400
Subject: [lustre-devel] [PATCH 03/64 v2] staging: lustre: uapi: return error
	code for ostid_set_id
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Currently the function ostid_set_id() just logs an error
and just keeps going. This function is also used by user
land tools so having special lustre kernel debugging
code is not desired. So instead just return an error
code and have the calling kernel code print the error
instead.

Signed-off-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/22712
Reviewed-on: https://review.whamcloud.com/24569
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 23 ++++++++--------------
 .../staging/lustre/lustre/obdecho/echo_client.c    |  7 +++++--
 drivers/staging/lustre/lustre/osc/osc_object.c     |  9 ++++++++-
 3 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 1e8ecdf..d70495d 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -515,32 +515,25 @@ static inline void ostid_set_seq_llog(struct ost_id *oi)
  * Note: we need check oi_seq to decide where to set oi_id,
  * so oi_seq should always be set ahead of oi_id.
  */
-static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
+static inline int ostid_set_id(struct ost_id *oi, __u64 oid)
 {
 	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
-		if (oid >= IDIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set MDT0 " DOSTID "\n",
-			       oid, POSTID(oi));
-			return;
-		}
+		if (oid >= IDIF_MAX_OID)
+			return -E2BIG;
 		oi->oi.oi_id = oid;
 	} else if (fid_is_idif(&oi->oi_fid)) {
-		if (oid >= IDIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set IDIF " DOSTID "\n",
-			       oid, POSTID(oi));
-			return;
-		}
+		if (oid >= IDIF_MAX_OID)
+			return -E2BIG;
 		oi->oi_fid.f_seq = fid_idif_seq(oid,
 						fid_idif_ost_idx(&oi->oi_fid));
 		oi->oi_fid.f_oid = oid;
 		oi->oi_fid.f_ver = oid >> 48;
 	} else {
-		if (oid >= OBIF_MAX_OID) {
-			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
-			return;
-		}
+		if (oid >= OBIF_MAX_OID)
+			return -E2BIG;
 		oi->oi_fid.f_oid = oid;
 	}
+	return 0;
 }
 
 static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index b3fbc3c..363d205 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1102,8 +1102,11 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 		return -EINVAL;
 	}
 
-	if (!ostid_id(&oa->o_oi))
-		ostid_set_id(&oa->o_oi, ++last_object_id);
+	if (!ostid_id(&oa->o_oi)) {
+		rc = ostid_set_id(&oa->o_oi, ++last_object_id);
+		if (rc)
+			goto failed;
+	}
 
 	rc = obd_create(env, ec->ec_exp, oa);
 	if (rc != 0) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index fa621bd..945ae6e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -369,7 +369,14 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 		oa->o_valid |= OBD_MD_FLGROUP;
 	}
 	if (flags & OBD_MD_FLID) {
-		ostid_set_id(&oa->o_oi, ostid_id(&oinfo->loi_oi));
+		int rc;
+
+		rc = ostid_set_id(&oa->o_oi, ostid_id(&oinfo->loi_oi));
+		if (rc) {
+			CERROR("Bad %llu to set " DOSTID " : rc %d\n",
+			       (unsigned long long)ostid_id(&oinfo->loi_oi),
+			       POSTID(&oa->o_oi), rc);
+		}
 		oa->o_valid |= OBD_MD_FLID;
 	}
 	if (flags & OBD_MD_FLHANDLE) {
-- 
1.8.3.1
