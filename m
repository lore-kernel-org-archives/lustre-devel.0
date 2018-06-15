From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 13/24] lustre: discard NO_QUOTA and QUOTA_OK
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669053.10587.9299734790900311212.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

They don't help readability.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |    7 -------
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    4 ++--
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    4 ++--
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 5e412fa8efbd..cb6e2aa35960 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -49,13 +49,6 @@
 #define module_init(a)     late_initcall(a)
 #endif
 
-#ifndef QUOTA_OK
-# define QUOTA_OK 0
-#endif
-#ifndef NO_QUOTA
-# define NO_QUOTA (-EDQUOT)
-#endif
-
 #if !defined(_ASM_GENERIC_BITOPS_EXT2_NON_ATOMIC_H_) && !defined(ext2_set_bit)
 # define ext2_set_bit	     __test_and_set_bit_le
 # define ext2_clear_bit	   __test_and_clear_bit_le
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index f26983004843..99de672fd078 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2404,8 +2404,8 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 		qid[USRQUOTA] = attr->cat_uid;
 		qid[GRPQUOTA] = attr->cat_gid;
-		if (rc == 0 && osc_quota_chkdq(cli, qid) == NO_QUOTA)
-			rc = -EDQUOT;
+		if (rc == 0)
+			rc = osc_quota_chkdq(cli, qid);
 		if (rc)
 			return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 723ec2fb18bf..25d06dec949e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -64,11 +64,11 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 			 */
 			CDEBUG(D_QUOTA, "chkdq found noquota for %s %d\n",
 			       type == USRQUOTA ? "user" : "grout", qid[type]);
-			return NO_QUOTA;
+			return -EDQUOT;
 		}
 	}
 
-	return QUOTA_OK;
+	return 0;
 }
 
 static void osc_quota_free(struct rcu_head *head)
