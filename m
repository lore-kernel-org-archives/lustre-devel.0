From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:43 -0500
Subject: [lustre-devel] [PATCH 13/35] staging: lustre: llite: lookup master
	inode by ilookup5_nowait
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Do not lookup master inode by ilookup5, instead it should
use ilookup5_nowait, otherwise it will cause dead lock,

1. Client1 send chmod req to the MDT0, then on MDT0, it
   enqueues master and all of its slaves lock, (mdt_attr_set()
   ->mdt_lock_slaves()), after gets master and stripe0 lock,
   it will send the enqueue request(for stripe1) to MDT1, then
   MDT1 finds the lock has been granted to client2. Then MDT1
   sends blocking ast to client2.

2. At the same time, client2 tries to unlink the striped
   dir (rm -rf striped_dir), and during lookup, it will hold
   the master inode of the striped directory, whose inode state
   is NEW, then tries to revalidate all of its slaves,
   (ll_prep_inode()->ll_iget()->ll_read_inode2()->
   ll_update_inode().). And it will be blocked on the server
   side because of 1.

3. Then the client get the blocking_ast request, cancel the
   lock, but being blocked by ilookup5 in ll_md_blocking_ast(),
   because the inode state is still NEW.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5344
Reviewed-on: http://review.whamcloud.com/16066
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |   36 ++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index c268f32..9ea43e1 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -286,10 +286,38 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 
 				hash = cl_fid_build_ino(&lli->lli_pfid,
 							ll_need_32bit_api(ll_i2sbi(inode)));
-
-				master_inode = ilookup5(inode->i_sb, hash,
-							ll_test_inode_by_fid,
-							(void *)&lli->lli_pfid);
+				/*
+				 * Do not lookup the inode with ilookup5,
+				 * otherwise it will cause dead lock,
+				 *
+				 * 1. Client1 send chmod req to the MDT0, then
+				 * on MDT0, it enqueues master and all of its
+				 * slaves lock, (mdt_attr_set() ->
+				 * mdt_lock_slaves()), after gets master and
+				 * stripe0 lock, it will send the enqueue req
+				 * (for stripe1) to MDT1, then MDT1 finds the
+				 * lock has been granted to client2. Then MDT1
+				 * sends blocking ast to client2.
+				 *
+				 * 2. At the same time, client2 tries to unlink
+				 * the striped dir (rm -rf striped_dir), and
+				 * during lookup, it will hold the master inode
+				 * of the striped directory, whose inode state
+				 * is NEW, then tries to revalidate all of its
+				 * slaves, (ll_prep_inode()->ll_iget()->
+				 * ll_read_inode2()-> ll_update_inode().). And
+				 * it will be blocked on the server side because
+				 * of 1.
+				 *
+				 * 3. Then the client get the blocking_ast req,
+				 * cancel the lock, but being blocked if using
+				 * ->ilookup5()), because master inode state is
+				 *  NEW.
+				 */
+				master_inode = ilookup5_nowait(inode->i_sb,
+							       hash,
+							       ll_test_inode_by_fid,
+							       (void *)&lli->lli_pfid);
 				if (master_inode) {
 					ll_invalidate_negative_children(master_inode);
 					iput(master_inode);
-- 
1.7.1
