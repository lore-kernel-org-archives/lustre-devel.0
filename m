From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:08 -0400
Subject: [lustre-devel] [PATCH v2 26/29] lustre: obdclass: remove
 unnecessary code from lustre_init_lsi()
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

After allocating a struct with kzalloc, there is no value
in setting a few of the fields to zero.

And as all fields were zero, it must be safe to kfree lmd_exclude,
whether lmd_exclude_count is zero or not.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/obd_mount.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 104e64b..4c86ca5 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -517,9 +517,6 @@ struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 		return NULL;
 	}
 
-	lsi->lsi_lmd->lmd_exclude_count = 0;
-	lsi->lsi_lmd->lmd_recovery_time_soft = 0;
-	lsi->lsi_lmd->lmd_recovery_time_hard = 0;
 	s2lsi_nocast(sb) = lsi;
 	/* we take 1 extra ref for our setup */
 	atomic_set(&lsi->lsi_mounts, 1);
@@ -546,8 +543,7 @@ static int lustre_free_lsi(struct super_block *sb)
 		kfree(lsi->lsi_lmd->lmd_fileset);
 		kfree(lsi->lsi_lmd->lmd_mgssec);
 		kfree(lsi->lsi_lmd->lmd_opts);
-		if (lsi->lsi_lmd->lmd_exclude_count)
-			kfree(lsi->lsi_lmd->lmd_exclude);
+		kfree(lsi->lsi_lmd->lmd_exclude);
 		kfree(lsi->lsi_lmd->lmd_mgs);
 		kfree(lsi->lsi_lmd->lmd_osd_type);
 		kfree(lsi->lsi_lmd->lmd_params);
-- 
1.8.3.1
