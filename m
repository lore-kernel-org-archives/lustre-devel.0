From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 11/24] lustre: discard current_n*groups
 macros.
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669046.10587.7089479780701336009.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Just open-code the access required.  This makes
the code clearer.
Also replace the 'memcpy' which violates typing
with a more correct for-loop.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |    3 ---
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   15 ++++++++++-----
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index bf86b0612b50..481eb4f31cfa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -39,9 +39,6 @@
 #include <linux/cred.h>
 #include <linux/module.h>
 
-#define current_ngroups current_cred()->group_info->ngroups
-#define current_groups current_cred()->group_info->small_block
-
 /*
  * OBD need working random driver, thus all our
  * initialization routines must be called after device
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index e193f3346e6f..9b60292370a7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -2215,7 +2215,7 @@ int sptlrpc_current_user_desc_size(void)
 {
 	int ngroups;
 
-	ngroups = current_ngroups;
+	ngroups = current_cred()->group_info->ngroups;
 
 	if (ngroups > LUSTRE_MAX_GROUPS)
 		ngroups = LUSTRE_MAX_GROUPS;
@@ -2226,6 +2226,9 @@ EXPORT_SYMBOL(sptlrpc_current_user_desc_size);
 int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset)
 {
 	struct ptlrpc_user_desc *pud;
+	int ngroups;
+	kgid_t *gid;
+	int g;
 
 	pud = lustre_msg_buf(msg, offset, 0);
 
@@ -2240,10 +2243,12 @@ int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset)
 	pud->pud_ngroups = (msg->lm_buflens[offset] - sizeof(*pud)) / 4;
 
 	task_lock(current);
-	if (pud->pud_ngroups > current_ngroups)
-		pud->pud_ngroups = current_ngroups;
-	memcpy(pud->pud_groups, current_cred()->group_info->gid,
-	       pud->pud_ngroups * sizeof(__u32));
+	ngroups = current_cred()->group_info->ngroups;
+	gid = current_cred()->group_info->gid;
+	if (pud->pud_ngroups > ngroups)
+		pud->pud_ngroups = ngroups;
+	for (g = 0; g < pud->pud_ngroups; g++)
+		pud->pud_groups[g] = from_kgid(&init_user_ns, gid[g]);
 	task_unlock(current);
 
 	return 0;
