From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:54 -0500
Subject: [lustre-devel] [PATCH 20/28] lustre: lov: keep minimum LOVEA size
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

For a PFL file, some of its component could be un-instantiated, and
their lov_ost_data_v1 array is not needed, we should keep its LOVEA
as small as possible.

An unstantiated component's stripe offset should be set.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9489
Reviewed-on: https://review.whamcloud.com/27089
WC-bug-id: https://jira.whamcloud.com/browse/LU-9941
Reviewed-on: https://review.whamcloud.com/28845
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 5e3eae7..dd4dd24 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -96,6 +96,11 @@ static inline bool lsm_entry_inited(const struct lov_stripe_md *lsm, int index)
 	return lsme_inited(lsm->lsm_entries[index]);
 }
 
+static inline bool lsm_is_composite(u32 magic)
+{
+	return magic == LOV_MAGIC_COMP_V1;
+}
+
 static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 {
 	struct lov_stripe_md_entry *lsme;
@@ -110,8 +115,15 @@ static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 
 	size = sizeof(struct lov_comp_md_v1);
 	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
+		u16 stripe_count;
+
 		lsme = lsm->lsm_entries[entry];
 
+		if (lsme_inited(lsme))
+			stripe_count = lsme->lsme_stripe_count;
+		else
+			stripe_count = 0;
+
 		size += sizeof(*lsme);
 		size += lov_mds_md_size(lsme->lsme_stripe_count,
 					lsme->lsme_magic);
-- 
1.8.3.1
