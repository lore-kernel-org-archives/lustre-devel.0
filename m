From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:54 -0400
Subject: [lustre-devel] [PATCH 04/14] staging/lustre/llite: clear inode
	timestamps after losing UPDATE lock
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Niu Yawei <yawei.niu@intel.com>

Otherwise, those leftovers would interfere with new timestamps
especially when the timestamps are set back in time on the other
clients.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-on: http://review.whamcloud.com/22623
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8446
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/namei.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 74d9b73..c268f32 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -251,6 +251,16 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				       PFID(ll_inode2fid(inode)), rc);
 		}
 
+		if (bits & MDS_INODELOCK_UPDATE) {
+			struct ll_inode_info *lli = ll_i2info(inode);
+
+			spin_lock(&lli->lli_lock);
+			LTIME_S(inode->i_mtime) = 0;
+			LTIME_S(inode->i_atime) = 0;
+			LTIME_S(inode->i_ctime) = 0;
+			spin_unlock(&lli->lli_lock);
+		}
+
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
 			struct ll_inode_info *lli = ll_i2info(inode);
 
-- 
2.7.4
