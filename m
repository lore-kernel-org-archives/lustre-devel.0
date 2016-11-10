From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:46 -0500
Subject: [lustre-devel] [PATCH 16/35] staging: lustre: llite: support
	SELinux context labelling
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Wellington <andrew.wellington@anu.edu.au>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: Andrew Wellington <andrew.wellington@anu.edu.au>

SELinux contexts are applied by the kernel if mount options are
not binary. As we don't use any binary mount options in Lustre,
remove the binary mount option flag.

Signed-off-by: Andrew Wellington <andrew.wellington@anu.edu.au>
Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6950
Reviewed-on: http://review.whamcloud.com/15840
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Sebastien Buisson <sebastien.buisson@bull.net>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   12 ++++++++++++
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    3 +--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4a4741b..609db9b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -720,6 +720,18 @@ static int ll_options(char *options, int *flags)
 			*flags &= ~tmp;
 			goto next;
 		}
+		tmp = ll_set_opt("context", s1, 1);
+		if (tmp)
+			goto next;
+		tmp = ll_set_opt("fscontext", s1, 1);
+		if (tmp)
+			goto next;
+		tmp = ll_set_opt("defcontext", s1, 1);
+		if (tmp)
+			goto next;
+		tmp = ll_set_opt("rootcontext", s1, 1);
+		if (tmp)
+			goto next;
 		tmp = ll_set_opt("user_fid2path", s1, LL_SBI_USER_FID2PATH);
 		if (tmp) {
 			*flags |= tmp;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 1d13751..2283e92 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1216,8 +1216,7 @@ static void lustre_kill_super(struct super_block *sb)
 	.name	 = "lustre",
 	.mount	= lustre_mount,
 	.kill_sb      = lustre_kill_super,
-	.fs_flags     = FS_BINARY_MOUNTDATA | FS_REQUIRES_DEV |
-			FS_RENAME_DOES_D_MOVE,
+	.fs_flags	= FS_REQUIRES_DEV | FS_RENAME_DOES_D_MOVE,
 };
 MODULE_ALIAS_FS("lustre");
 
-- 
1.7.1
