From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:28 -0500
Subject: [lustre-devel] [PATCH 040/622] lustre: llite: decrease sa_running
 if fail to start statahead
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Otherwise the counter of ll_sb_info::ll_sa_running will leak as
to the umount process will be blocked for ever.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10992
Lustre-commit: 6b8638bf7920 ("LU-10992 llite: decrease sa_running if fail to start statahead")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: https://review.whamcloud.com/32287
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 4a61dac..122b9d8 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1566,6 +1566,7 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 		spin_lock(&lli->lli_sa_lock);
 		lli->lli_sai = NULL;
 		spin_unlock(&lli->lli_sa_lock);
+		atomic_dec(&ll_i2sbi(parent->d_inode)->ll_sa_running);
 		rc = PTR_ERR(task);
 		CERROR("can't start ll_sa thread, rc : %d\n", rc);
 		goto out;
-- 
1.8.3.1
