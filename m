From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:32 -0400
Subject: [lustre-devel] [PATCH 033/124] staging: lustre: llite: remove mode
	from ll_create_it()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the unused mode parameter from ll_create_it().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10769
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2037c7c..8f92af4 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -47,8 +47,8 @@
 #include "../include/lustre_ver.h"
 #include "llite_internal.h"
 
-static int ll_create_it(struct inode *, struct dentry *,
-			int, struct lookup_intent *);
+static int ll_create_it(struct inode *dir, struct dentry *dentry,
+			struct lookup_intent *it);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -668,7 +668,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	if (!rc) {
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
-			rc = ll_create_it(dir, dentry, mode, it);
+			rc = ll_create_it(dir, dentry, it);
 			if (rc) {
 				/* We dget in ll_splice_alias. */
 				if (de)
@@ -754,7 +754,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
  * If the create succeeds, we fill in the inode information
  * with d_instantiate().
  */
-static int ll_create_it(struct inode *dir, struct dentry *dentry, int mode,
+static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it)
 {
 	struct inode *inode;
-- 
1.7.1
