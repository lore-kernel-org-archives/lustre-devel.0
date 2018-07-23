From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 16:23:05 +1000
Subject: [lustre-devel] [PATCH 7/9] lustre: ll_fill_super() must put sb on
 all failure paths.
In-Reply-To: <153232696720.26222.9658151633697867322.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
Message-ID: <153232698499.26222.12345415044809848331.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lustre_fill_super() has comment saying:
	/*
	 * l_f_s will call lustre_common_put_super on failure, otherwise
	 * l_f_s will have taken another reference to the module
	 */

But this is not the case - ENOMEM error do not result in a 'put'.
So add appropriate calls to lustre_common_put_super().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |    5 ++++-
 drivers/staging/lustre/lustre/llite/mount.c     |    6 ++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e6348345505c..5c8d0fe7217e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -912,8 +912,10 @@ int ll_fill_super(struct super_block *sb)
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
-	if (!cfg)
+	if (!cfg) {
+		lustre_common_put_super(sb);
 		return -ENOMEM;
+	}
 
 	try_module_get(THIS_MODULE);
 
@@ -923,6 +925,7 @@ int ll_fill_super(struct super_block *sb)
 	if (!sbi) {
 		module_put(THIS_MODULE);
 		kfree(cfg);
+		lustre_common_put_super(sb);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/mount.c b/drivers/staging/lustre/lustre/llite/mount.c
index 85f0a7fdcd39..a560098689ac 100644
--- a/drivers/staging/lustre/lustre/llite/mount.c
+++ b/drivers/staging/lustre/lustre/llite/mount.c
@@ -1150,8 +1150,10 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 		}
 		/* Connect and start */
 		rc = ll_fill_super(sb);
-		/* l_f_s will call lustre_common_put_super on failure, otherwise
-		 * l_f_s will have taken another reference to the module */
+		/*
+		 * l_f_s will call lustre_common_put_super on failure, otherwise
+		 * l_f_s will have taken another reference to the module
+		 */
 	} else {
 		CERROR("This is client-side-only module, cannot handle server mount.\n");
 		rc = -EINVAL;
