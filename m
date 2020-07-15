From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:45 -0400
Subject: [lustre-devel] [PATCH 04/37] lustre: obdclass: remove init to 0
 from lustre_init_lsi()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

After allocating a struct with kzalloc, there is no value
in setting a few of the fields to zero.

And as all fields were zero, it must be safe to kfree lmd_exclude,
whether lmd_exclude_count is zero or not.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 513dde601d2e9 ("LU-9679 obdclass: remove init to 0 from lustre_init_lsi()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39135
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_mount.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 13e6521..ea5b469 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -515,9 +515,6 @@ struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 		return NULL;
 	}
 
-	lsi->lsi_lmd->lmd_exclude_count = 0;
-	lsi->lsi_lmd->lmd_recovery_time_soft = 0;
-	lsi->lsi_lmd->lmd_recovery_time_hard = 0;
 	s2lsi_nocast(sb) = lsi;
 	/* we take 1 extra ref for our setup */
 	atomic_set(&lsi->lsi_mounts, 1);
@@ -544,8 +541,7 @@ static int lustre_free_lsi(struct super_block *sb)
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
