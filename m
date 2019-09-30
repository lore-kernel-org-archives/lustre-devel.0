From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:22 -0400
Subject: [lustre-devel] [PATCH 063/151] lustre: lov: pack lsm_flags from
 layout
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-64-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Pack lsm_flags from compount layout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 9b74a75ecbdc ("LU-9771 lov: pack lsm_flags from layout")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29081
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_ea.c       | 1 +
 fs/lustre/lov/lov_internal.h | 3 ++-
 fs/lustre/lov/lov_pack.c     | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index e1630f6..8ecf3eb 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -446,6 +446,7 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 	lsm->lsm_magic = le32_to_cpu(lcm->lcm_magic);
 	lsm->lsm_layout_gen = le32_to_cpu(lcm->lcm_layout_gen);
 	lsm->lsm_entry_count = entry_count;
+	lsm->lsm_flags = le16_to_cpu(lcm->lcm_flags);
 	lsm->lsm_is_released = true;
 	lsm->lsm_maxbytes = LLONG_MIN;
 
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index e18ea8e..18fe92f 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -86,8 +86,9 @@ struct lov_stripe_md {
 	struct ost_id	lsm_oi;
 	u32		lsm_magic;
 	u32		lsm_layout_gen;
-	u32		lsm_entry_count;
+	u16		lsm_flags;
 	bool		lsm_is_released;
+	u32		lsm_entry_count;
 	struct lov_stripe_md_entry *lsm_entries[];
 };
 
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 269e61c..c8b55eb 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -185,6 +185,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	lcmv1->lcm_magic = cpu_to_le32(lsm->lsm_magic);
 	lcmv1->lcm_size = cpu_to_le32(lmm_size);
 	lcmv1->lcm_layout_gen = cpu_to_le32(lsm->lsm_layout_gen);
+	lcmv1->lcm_flags = cpu_to_le16(lsm->lsm_flags);
 	lcmv1->lcm_entry_count = cpu_to_le16(lsm->lsm_entry_count);
 
 	offset = sizeof(*lcmv1) + sizeof(*lcme) * lsm->lsm_entry_count;
-- 
1.8.3.1
