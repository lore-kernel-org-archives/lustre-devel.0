From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:29 -0400
Subject: [lustre-devel] [PATCH 19/32] staging/lustre/ldlm: Remove unused
	ldlm_pool_get_clv()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 16 ----------------
 2 files changed, 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 4d81e73..1b5f298 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1401,7 +1401,6 @@ int ldlm_pool_setup(struct ldlm_pool *pl, int limit);
 int ldlm_pool_recalc(struct ldlm_pool *pl);
 __u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
 __u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
-__u64 ldlm_pool_get_clv(struct ldlm_pool *pl);
 __u32 ldlm_pool_get_limit(struct ldlm_pool *pl);
 void ldlm_pool_set_slv(struct ldlm_pool *pl, __u64 slv);
 void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 1c9d67f..cbe4b7b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -1023,22 +1023,6 @@ void ldlm_pool_set_slv(struct ldlm_pool *pl, __u64 slv)
 EXPORT_SYMBOL(ldlm_pool_set_slv);
 
 /**
- * Returns current \a pl CLV.
- *
- * \pre ->pl_lock is not locked.
- */
-__u64 ldlm_pool_get_clv(struct ldlm_pool *pl)
-{
-	__u64 slv;
-
-	spin_lock(&pl->pl_lock);
-	slv = pl->pl_client_lock_volume;
-	spin_unlock(&pl->pl_lock);
-	return slv;
-}
-EXPORT_SYMBOL(ldlm_pool_get_clv);
-
-/**
  * Sets passed \a clv to \a pl.
  *
  * \pre ->pl_lock is not locked.
-- 
2.1.0
