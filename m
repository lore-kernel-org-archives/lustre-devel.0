From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:30 -0400
Subject: [lustre-devel] [PATCH 02/64] staging: lustre: uapi: remove unused
	functions for lustre_fid.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The inline function fid_is_namespace_visible and ost_fid_from_resid
are only used for server code so we can remove it.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_fid.h | 29 ----------------------
 1 file changed, 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 6dc24a7..681f698 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -288,18 +288,6 @@ static inline int fid_is_quota(const struct lu_fid *fid)
 	       fid_seq(fid) == FID_SEQ_QUOTA_GLB;
 }
 
-static inline int fid_is_namespace_visible(const struct lu_fid *fid)
-{
-	const __u64 seq = fid_seq(fid);
-
-	/* Here, we cannot distinguish whether the normal FID is for OST
-	 * object or not. It is caller's duty to check more if needed.
-	 */
-	return (!fid_is_last_id(fid) &&
-		(fid_seq_is_norm(seq) || fid_seq_is_igif(seq))) ||
-	       fid_is_root(fid) || fid_is_dot_lustre(fid);
-}
-
 static inline int fid_seq_in_fldb(__u64 seq)
 {
 	return fid_seq_is_igif(seq) || fid_seq_is_norm(seq) ||
@@ -522,23 +510,6 @@ static inline void ost_fid_build_resid(const struct lu_fid *fid,
 	}
 }
 
-static inline void ost_fid_from_resid(struct lu_fid *fid,
-				      const struct ldlm_res_id *name,
-				      int ost_idx)
-{
-	if (fid_seq_is_mdt0(name->name[LUSTRE_RES_ID_VER_OID_OFF])) {
-		/* old resid */
-		struct ost_id oi;
-
-		ostid_set_seq(&oi, name->name[LUSTRE_RES_ID_VER_OID_OFF]);
-		ostid_set_id(&oi, name->name[LUSTRE_RES_ID_SEQ_OFF]);
-		ostid_to_fid(fid, &oi, ost_idx);
-	} else {
-		/* new resid */
-		fid_extract_from_res_name(fid, name);
-	}
-}
-
 /**
  * Flatten 128-bit FID values into a 64-bit value for use as an inode number.
  * For non-IGIF FIDs this starts just over 2^32, and continues without
-- 
1.8.3.1
