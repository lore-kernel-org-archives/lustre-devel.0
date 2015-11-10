From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:28:44 +0530
Subject: [lustre-devel] [PATCH v2 7/8] Staging: lustre: llite_close:
	Substitute function calls
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <391868d05a85377c8fb905578b9b01398c06adcb.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Substitute standard function kfree() in place of the function
ll_finish_md_op_data().

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/llite_close.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 3f348a3..c4f22ec 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -301,7 +301,7 @@ static void ll_done_writing(struct inode *inode)
 		CERROR("inode %lu mdc done_writing failed: rc = %d\n",
 		       inode->i_ino, rc);
 out:
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (och) {
 		md_clear_open_replay_data(ll_i2sbi(inode)->ll_md_exp, och);
 		kfree(och);
-- 
2.1.0
