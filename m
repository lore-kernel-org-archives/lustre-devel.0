From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:42 -0400
Subject: [lustre-devel] [PATCH 03/22] lustre: use BIT() macro where
 appropriate
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When accessing a bit in a bitmap/mask/flags-word it can be more
readable to use BIT(num) rather than "1 << num".

This patch makes that change to various places in lustre

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: ff09273feadc9 ("LU-6142 lustre: use BIT() macro where appropriate")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38377
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Gian-Carlo DeFazio <defazio1@llnl.gov>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_extent.c    | 4 ++--
 fs/lustre/ldlm/ldlm_resource.c  | 2 +-
 fs/lustre/llite/file.c          | 2 +-
 fs/lustre/lov/lov_cl_internal.h | 2 +-
 fs/lustre/osc/lproc_osc.c       | 4 ++--
 fs/lustre/ptlrpc/layout.c       | 6 +++---
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 3e0f7a2..7474c85 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -157,7 +157,7 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	LASSERT(RB_EMPTY_NODE(&lock->l_rb));
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
-	LASSERT(lock->l_granted_mode == 1 << idx);
+	LASSERT(lock->l_granted_mode == BIT(idx));
 	LASSERT(lock->l_granted_mode == res->lr_itree[idx].lit_mode);
 
 	tree = &res->lr_itree[idx];
@@ -202,7 +202,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 		return;
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
-	LASSERT(lock->l_granted_mode == 1 << idx);
+	LASSERT(lock->l_granted_mode == BIT(idx));
 	tree = &res->lr_itree[idx];
 
 	tree->lit_size--;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index a6572af..a461ca7 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1023,7 +1023,7 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 		/* Initialize interval trees for each lock mode. */
 		for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 			res->lr_itree[idx].lit_size = 0;
-			res->lr_itree[idx].lit_mode = 1 << idx;
+			res->lr_itree[idx].lit_mode = BIT(idx);
 			res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
 		}
 	}
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 871fa59..ce50fd9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4410,7 +4410,7 @@ int ll_have_md_lock(struct inode *inode, u64 *bits,
 
 	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING | LDLM_FL_TEST_LOCK;
 	for (i = 0; i < MDS_INODELOCK_NUMBITS && *bits != 0; i++) {
-		policy.l_inodebits.bits = *bits & (1 << i);
+		policy.l_inodebits.bits = *bits & BIT(i);
 		if (policy.l_inodebits.bits == 0)
 			continue;
 
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 9dd523f..6796d88 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -83,7 +83,7 @@
 struct lovsub_object;
 
 enum lov_device_flags {
-	LOV_DEV_INITIALIZED = 1 << 0
+	LOV_DEV_INITIALIZED = BIT(0),
 };
 
 /*
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index de35d32..9b43710 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -398,9 +398,9 @@ static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 		return 0;
 
 	for (i = 0; i < ARRAY_SIZE(cksum_name); i++) {
-		if (((1 << i) & obd->u.cli.cl_supp_cksum_types) == 0)
+		if ((BIT(i) & obd->u.cli.cl_supp_cksum_types) == 0)
 			continue;
-		if (obd->u.cli.cl_cksum_type == (1 << i))
+		if (obd->u.cli.cl_cksum_type == BIT(i))
 			seq_printf(m, "[%s] ", cksum_name[i]);
 		else
 			seq_printf(m, "%s ", cksum_name[i]);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 754c87d..1286547 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -817,17 +817,17 @@ enum rmf_flags {
 	/**
 	 * The field is a string, must be NUL-terminated.
 	 */
-	RMF_F_STRING = BIT(0),
+	RMF_F_STRING		= BIT(0),
 	/**
 	 * The field's buffer size need not match the declared @rmf_size.
 	 */
-	RMF_F_NO_SIZE_CHECK = BIT(1),
+	RMF_F_NO_SIZE_CHECK	= BIT(1),
 	/**
 	 * The field's buffer size must be a whole multiple of the declared
 	 * @rmf_size and the @rmf_swabber function must work on the declared
 	 * @rmf_size worth of bytes.
 	 */
-	RMF_F_STRUCT_ARRAY = BIT(2)
+	RMF_F_STRUCT_ARRAY	= BIT(2),
 };
 
 struct req_capsule;
-- 
1.8.3.1
