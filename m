From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:09:25 +1100
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: honor error code from
 ll_iget().
In-Reply-To: <151846966702.17168.15765227765350491300.stgit@noble>
References: <151846966702.17168.15765227765350491300.stgit@noble>
Message-ID: <151846976581.17168.2838881093184873250.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Commit 020ecc6f3229 ("staging: lustre: llite: Remove IS_ERR tests")
changed ll_prep_inode to assume any error from ll_iget() meant
-ENOMEM because at that time it only returned NULL for errors.
Commit c3397e7e677b ("staging: lustre: llite: add error handler in
inode prepare phase") changed ll_iget() to once again return
meaningful codes, but nobody told ll_prep_inode().

So change ll_prep_inode() back to using PTR_ERR(*inode).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6735a6f006d2..020f0faeb750 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2143,7 +2143,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 				md.posix_acl = NULL;
 			}
 #endif
-			rc = -ENOMEM;
+			rc = PTR_ERR(*inode);
 			CERROR("new_inode -fatal: rc %d\n", rc);
 			goto out;
 		}
