From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:56 -0400
Subject: [lustre-devel] [PATCH 5/9] staging: lustre: fid: packing ost_idx in
	IDIF
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

For a normal FID, we can know on which target the related object
is allocated via querying FLDB; but it is not true for an IDIF.

To locate the OST via the given IDIF, when the IDIF is generated,
we pack the OST index in it. Then for any given FID, in spite of
t is a normal FID or not, we has the method to know which target
it belongs to. That is useful for LFSCK.

For old IDIF, the OST index is not part of the IDIF, means that
ifferent OSTs may have the same IDIFs, that may cause the IFID
in LMA does not match the read FID. Under such case, we need to
make some compatible check to avoid to trigger unexpected.

tgt_validate_obdo() converts the ostid contained in the RPC body
to fid and changes the "struct ost_id" union, then the users can
access ost_id::oi_fid directly without call ostid_to_fid() again.

It also contains some other fixing and cleanup.

Signed-off-by: wang di <di.wang@intel.com>
Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3569
Reviewed-on: http://review.whamcloud.com/7053
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 76 +++++++++++++++-------
 drivers/staging/lustre/lustre/include/lustre_fid.h | 22 ++-----
 2 files changed, 57 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a70545a..9c53c17 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -584,7 +584,7 @@ static inline __u64 ostid_seq(const struct ost_id *ostid)
 	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
 		return FID_SEQ_OST_MDT0;
 
-	if (fid_seq_is_default(ostid->oi.oi_seq))
+	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))
 		return FID_SEQ_LOV_DEFAULT;
 
 	if (fid_is_idif(&ostid->oi_fid))
@@ -596,9 +596,12 @@ static inline __u64 ostid_seq(const struct ost_id *ostid)
 /* extract OST objid from a wire ost_id (id/seq) pair */
 static inline __u64 ostid_id(const struct ost_id *ostid)
 {
-	if (fid_seq_is_mdt0(ostid_seq(ostid)))
+	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
 		return ostid->oi.oi_id & IDIF_OID_MASK;
 
+	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))
+		return ostid->oi.oi_id;
+
 	if (fid_is_idif(&ostid->oi_fid))
 		return fid_idif_id(fid_seq(&ostid->oi_fid),
 				   fid_oid(&ostid->oi_fid), 0);
@@ -642,12 +645,22 @@ static inline void ostid_set_seq_llog(struct ost_id *oi)
  */
 static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 {
-	if (fid_seq_is_mdt0(ostid_seq(oi))) {
+	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
 		if (oid >= IDIF_MAX_OID) {
 			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
 			return;
 		}
 		oi->oi.oi_id = oid;
+	} else if (fid_is_idif(&oi->oi_fid)) {
+		if (oid >= IDIF_MAX_OID) {
+			CERROR("Bad %llu to set "DOSTID"\n",
+			       oid, POSTID(oi));
+			return;
+		}
+		oi->oi_fid.f_seq = fid_idif_seq(oid,
+						fid_idif_ost_idx(&oi->oi_fid));
+		oi->oi_fid.f_oid = oid;
+		oi->oi_fid.f_ver = oid >> 48;
 	} else {
 		if (oid > OBIF_MAX_OID) {
 			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
@@ -657,25 +670,31 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 	}
 }
 
-static inline void ostid_inc_id(struct ost_id *oi)
+static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
 {
-	if (fid_seq_is_mdt0(ostid_seq(oi))) {
-		if (unlikely(ostid_id(oi) + 1 > IDIF_MAX_OID)) {
-			CERROR("Bad inc "DOSTID"\n", POSTID(oi));
-			return;
+	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
+		CERROR("bad IGIF, "DFID"\n", PFID(fid));
+		return -EBADF;
+	}
+
+	if (fid_is_idif(fid)) {
+		if (oid >= IDIF_MAX_OID) {
+			CERROR("Too large OID %#llx to set IDIF "DFID"\n",
+			       (unsigned long long)oid, PFID(fid));
+			return -EBADF;
 		}
-		oi->oi.oi_id++;
+		fid->f_seq = fid_idif_seq(oid, fid_idif_ost_idx(fid));
+		fid->f_oid = oid;
+		fid->f_ver = oid >> 48;
 	} else {
-		oi->oi_fid.f_oid++;
+		if (oid > OBIF_MAX_OID) {
+			CERROR("Too large OID %#llx to set REG "DFID"\n",
+			       (unsigned long long)oid, PFID(fid));
+			return -EBADF;
+		}
+		fid->f_oid = oid;
 	}
-}
-
-static inline void ostid_dec_id(struct ost_id *oi)
-{
-	if (fid_seq_is_mdt0(ostid_seq(oi)))
-		oi->oi.oi_id--;
-	else
-		oi->oi_fid.f_oid--;
+	return 0;
 }
 
 /**
@@ -690,30 +709,34 @@ static inline void ostid_dec_id(struct ost_id *oi)
 static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 			       __u32 ost_idx)
 {
+	__u64 seq = ostid_seq(ostid);
+
 	if (ost_idx > 0xffff) {
 		CERROR("bad ost_idx, "DOSTID" ost_idx:%u\n", POSTID(ostid),
 		       ost_idx);
 		return -EBADF;
 	}
 
-	if (fid_seq_is_mdt0(ostid_seq(ostid))) {
+	if (fid_seq_is_mdt0(seq)) {
+		__u64 oid = ostid_id(ostid);
+
 		/* This is a "legacy" (old 1.x/2.early) OST object in "group 0"
 		 * that we map into the IDIF namespace.  It allows up to 2^48
 		 * objects per OST, as this is the object namespace that has
 		 * been in production for years.  This can handle create rates
 		 * of 1M objects/s/OST for 9 years, or combinations thereof.
 		 */
-		if (ostid_id(ostid) >= IDIF_MAX_OID) {
+		if (oid >= IDIF_MAX_OID) {
 			CERROR("bad MDT0 id, " DOSTID " ost_idx:%u\n",
 			       POSTID(ostid), ost_idx);
 			return -EBADF;
 		}
-		fid->f_seq = fid_idif_seq(ostid_id(ostid), ost_idx);
+		fid->f_seq = fid_idif_seq(oid, ost_idx);
 		/* truncate to 32 bits by assignment */
-		fid->f_oid = ostid_id(ostid);
+		fid->f_oid = oid;
 		/* in theory, not currently used */
-		fid->f_ver = ostid_id(ostid) >> 48;
-	} else /* if (fid_seq_is_idif(seq) || fid_seq_is_norm(seq)) */ {
+		fid->f_ver = oid >> 48;
+	} else if (likely(!fid_seq_is_default(seq))) {
 	       /* This is either an IDIF object, which identifies objects across
 		* all OSTs, or a regular FID.  The IDIF namespace maps legacy
 		* OST objects into the FID namespace.  In both cases, we just
@@ -1537,6 +1560,11 @@ static inline void lmm_oi_set_seq(struct ost_id *oi, __u64 seq)
 	oi->oi.oi_seq = seq;
 }
 
+static inline void lmm_oi_set_id(struct ost_id *oi, __u64 oid)
+{
+	oi->oi.oi_id = oid;
+}
+
 static inline __u64 lmm_oi_id(struct ost_id *oi)
 {
 	return oi->oi.oi_id;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index ab4a923..12e8b58 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -308,10 +308,10 @@ static inline int fid_seq_in_fldb(__u64 seq)
 	       fid_seq_is_root(seq) || fid_seq_is_dot(seq);
 }
 
-static inline void lu_last_id_fid(struct lu_fid *fid, __u64 seq)
+static inline void lu_last_id_fid(struct lu_fid *fid, __u64 seq, __u32 ost_idx)
 {
 	if (fid_seq_is_mdt0(seq)) {
-		fid->f_seq = fid_idif_seq(0, 0);
+		fid->f_seq = fid_idif_seq(0, ost_idx);
 	} else {
 		LASSERTF(fid_seq_is_norm(seq) || fid_seq_is_echo(seq) ||
 			 fid_seq_is_idif(seq), "%#llx\n", seq);
@@ -498,19 +498,6 @@ static inline void ostid_build_res_name(struct ost_id *oi,
 	}
 }
 
-static inline void ostid_res_name_to_id(struct ost_id *oi,
-					struct ldlm_res_id *name)
-{
-	if (fid_seq_is_mdt0(name->name[LUSTRE_RES_ID_SEQ_OFF])) {
-		/* old resid */
-		ostid_set_seq(oi, name->name[LUSTRE_RES_ID_VER_OID_OFF]);
-		ostid_set_id(oi, name->name[LUSTRE_RES_ID_SEQ_OFF]);
-	} else {
-		/* new resid */
-		fid_extract_from_res_name(&oi->oi_fid, name);
-	}
-}
-
 /**
  * Return true if the resource is for the object identified by this id & group.
  */
@@ -546,7 +533,8 @@ static inline void ost_fid_build_resid(const struct lu_fid *fid,
 }
 
 static inline void ost_fid_from_resid(struct lu_fid *fid,
-				      const struct ldlm_res_id *name)
+				      const struct ldlm_res_id *name,
+				      int ost_idx)
 {
 	if (fid_seq_is_mdt0(name->name[LUSTRE_RES_ID_VER_OID_OFF])) {
 		/* old resid */
@@ -554,7 +542,7 @@ static inline void ost_fid_from_resid(struct lu_fid *fid,
 
 		ostid_set_seq(&oi, name->name[LUSTRE_RES_ID_VER_OID_OFF]);
 		ostid_set_id(&oi, name->name[LUSTRE_RES_ID_SEQ_OFF]);
-		ostid_to_fid(fid, &oi, 0);
+		ostid_to_fid(fid, &oi, ost_idx);
 	} else {
 		/* new resid */
 		fid_extract_from_res_name(fid, name);
-- 
2.7.4
