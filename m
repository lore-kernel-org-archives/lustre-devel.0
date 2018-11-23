From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Nov 2018 18:15:28 +1100
Subject: [lustre-devel] [PATCH 8/9] lustre: statahead: skip agl for the file
 in restoring
In-Reply-To: <154295730810.2850.961218355189474016.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
Message-ID: <154295732808.2850.16445000176556176904.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

In case of restore, the MDT has the right size and has already sent
it back without granting the layout lock, inode is up-to-date. Then
AGL (async glimpse lock) is useless.

Also to glimpse we need the layout, in case of a running restore the
MDT holds the layout lock so the glimpse will block up to the end of
restore (statahead/agl will block).

Signed-off-by: Fan Yong <fan.yong@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9319
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: https://review.whamcloud.com/26501
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/statahead.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 28e85bfb9b82..3d71322aa1c7 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -504,6 +504,19 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 		return;
 	}
 
+	/* In case of restore, the MDT has the right size and has already
+	 * sent it back without granting the layout lock, inode is up-to-date.
+	 * Then AGL (async glimpse lock) is useless.
+	 * Also to glimpse we need the layout, in case of a runninh restore
+	 * the MDT holds the layout lock so the glimpse will block up to the
+	 * end of restore (statahead/agl will block)
+	 */
+	if (test_bit(LLIF_FILE_RESTORING, &lli->lli_flags)) {
+		lli->lli_agl_index = 0;
+		iput(inode);
+		return;
+	}
+
 	/* Someone is in glimpse (sync or async), do nothing. */
 	rc = down_write_trylock(&lli->lli_glimpse_sem);
 	if (rc == 0) {
