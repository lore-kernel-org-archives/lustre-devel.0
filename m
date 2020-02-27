From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:23 -0500
Subject: [lustre-devel] [PATCH 455/622] lustre: dom: manual OST-to-DOM
 migration via mirroring
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-456-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Allow DOM mirroring, update LOV/LOD code to check not just
first component for DOM pattern but cycle through all mirrors
if any. Sanity checks allows one DOM component in a mirror
and it should be the first one. Multiple DOM components are
allowed only with the same for now.

Do OST file migration to MDT by using FLR. That can't be done
by layout swapping, because MDT data will be tied to temporary
volatile file but we want to keep data with the original file.
The mirroring allows that with the following steps:
- extent layout with new mirror on MDT, no data is copied but
  new mirror stays in 'stale' state. The reason is the same
  problem with volatile file.
- resync mirrors, now new DOM layout is filled with data.
- remove first mirror

WC-bug-id: https://jira.whamcloud.com/browse/LU-11421
Lustre-commit: 44a721b8c106 ("LU-11421 dom: manual OST-to-DOM migration via mirroring")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35359
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 52d8c30..5c4d8f9 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -543,7 +543,13 @@ static int lov_init_dom(const struct lu_env *env, struct lov_device *dev,
 	u32 idx = 0;
 	int rc;
 
-	LASSERT(index == 0);
+	/* DOM entry may be not zero index due to FLR but must start from 0 */
+	if (unlikely(lle->lle_extent->e_start != 0)) {
+		CERROR("%s: DOM entry must be the first stripe in a mirror\n",
+		       lov2obd(dev->ld_lov)->obd_name);
+		dump_lsm(D_ERROR, lov->lo_lsm);
+		return -EINVAL;
+	}
 
 	/* find proper MDS device */
 	rc = lov_fld_lookup(dev, fid, &idx);
@@ -636,6 +642,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	int result = 0;
 	unsigned int seq;
 	int i, j;
+	bool dom_size = 0;
 
 	LASSERT(lsm->lsm_entry_count > 0);
 	LASSERT(!lov->lo_lsm);
@@ -679,6 +686,18 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			lle->lle_comp_ops = &raid0_ops;
 			break;
 		case LOV_PATTERN_MDT:
+			/* Allowed to have several DOM stripes in different
+			 * mirrors with the same DoM size.
+			 */
+			if (!dom_size) {
+				dom_size = lle->lle_lsme->lsme_extent.e_end;
+			} else if (dom_size !=
+				   lle->lle_lsme->lsme_extent.e_end) {
+				CERROR("%s: DOM entries with different sizes\n",
+				       lov2obd(dev->ld_lov)->obd_name);
+				dump_lsm(D_ERROR, lsm);
+				return -EINVAL;
+			}
 			lle->lle_comp_ops = &dom_ops;
 			break;
 		default:
@@ -869,7 +888,8 @@ static void lov_fini_composite(const struct lu_env *env,
 		struct lov_layout_entry *entry;
 
 		lov_foreach_layout_entry(lov, entry)
-			entry->lle_comp_ops->lco_fini(env, entry);
+			if (entry->lle_comp_ops)
+				entry->lle_comp_ops->lco_fini(env, entry);
 
 		kvfree(comp->lo_entries);
 		comp->lo_entries = NULL;
-- 
1.8.3.1
