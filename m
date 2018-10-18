From: NeilBrown <neilb@suse.com>
Date: Thu, 18 Oct 2018 15:40:26 +1100
Subject: [lustre-devel] [PATCH] lustre: lprocfs: fix return value of
 lprocfs_read_helper
Message-ID: <87y3avc1fp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


This should be 'ret', not zero.

Fixes: fdedd94509fd ("staging/lustre/lvfs: remove the lvfs layer")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index dc1d540e05c7..edac88440b41 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1509,7 +1509,7 @@ __s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 		break;
 	}
 
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(lprocfs_read_helper);
 
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181018/4d0fd838/attachment.sig>
