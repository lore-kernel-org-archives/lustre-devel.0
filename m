From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Feb 2018 09:09:33 +1100
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lmv: correctly iput
 lmo_root
In-Reply-To: <151933726925.16436.9827896439357574011.stgit@noble>
References: <151933726925.16436.9827896439357574011.stgit@noble>
Message-ID: <151933737384.16436.1999360148075400466.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Commit 8f18c8a48b73 ("staging: lustre: lmv: separate master object
with master stripe") changed how lmo_root inodes were managed,
particularly when LMV_HASH_FLAG_MIGRATION is not set.
Previously lsm_md_oinfo[0].lmo_root was always a borrowed
inode reference and didn't need to by iput().
Since the change, that special case only applies when
LMV_HASH_FLAG_MIGRATION is set

In the upstream (lustre-release) version of this patch [Commit
60e07b972114 ("LU-4690 lod: separate master object with master
stripe")] the for loop in the lmv_unpack_md() was changed to count
from 0 and to ignore entry 0 if LMV_HASH_FLAG_MIGRATION is set.
In the patch that got applied to Linux, that change was missing,
so lsm_md_oinfo[0].lmo_root is never iput().
This results in a "VFS: Busy inodes" warning at unmount.

Fixes: 8f18c8a48b73 ("staging: lustre: lmv: separate master object with master stripe")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 179651531862..e8a9b9902c37 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2695,7 +2695,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	if (lsm && !lmm) {
 		int i;
 
-		for (i = 1; i < lsm->lsm_md_stripe_count; i++) {
+		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 			/*
 			 * For migrating inode, the master stripe and master
 			 * object will be the same, so do not need iput, see
