From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:56 -0400
Subject: [lustre-devel] [PATCH 11/18] staging: lustre: llite: Delaying
	creation of client side proc entries.
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gaurav Mahajan <gmahajan@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Gaurav Mahajan <gmahajan@ddn.com>

In client_common_fill_super() proc entries are created before
before cl_sb_init() and therefore lu_site is not allocated resulting
in client crash when tried reading lu_site stats.
Delaying creation of proc entries after creation of all required data
structures fixed the problem.

Signed-off-by: Gaurav Mahajan <gmahajan@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2941
Reviewed-on: http://review.whamcloud.com/6852
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 95c55c3..9571742 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -166,12 +166,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		return -ENOMEM;
 	}
 
-	if (llite_root) {
-		err = ldebugfs_register_mountpoint(llite_root, sb, dt, md);
-		if (err < 0)
-			CERROR("could not register mount in <debugfs>/lustre/llite\n");
-	}
-
 	/* indicate the features supported by this client */
 	data->ocd_connect_flags = OBD_CONNECT_IBITS    | OBD_CONNECT_NODEVOH  |
 				  OBD_CONNECT_ATTRFID  |
@@ -552,6 +546,15 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	kfree(data);
 	kfree(osfs);
 
+	if (llite_root) {
+		err = ldebugfs_register_mountpoint(llite_root, sb, dt, md);
+		if (err < 0) {
+			CERROR("%s: could not register mount in debugfs: "
+			       "rc = %d\n", ll_get_fsname(sb, NULL, 0), err);
+			err = 0;
+		}
+	}
+
 	return err;
 out_root:
 	iput(root);
@@ -570,7 +573,6 @@ out_md:
 out:
 	kfree(data);
 	kfree(osfs);
-	ldebugfs_unregister_mountpoint(sbi);
 	return err;
 }
 
-- 
1.7.1
