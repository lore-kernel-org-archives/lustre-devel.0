From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 19/21] staging: lustre: fid: fix up debugfs
 access to ->lcs_space
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341819.25814.15953004503314348403.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

lcs_space can change while the lock is not held
if an RPC in underway.  This can be detected by
seq->ls_update being set.

In this case, reading or writing the value should return
-EBUSY.

Also, the D_INFO CDEBUG() which reports the lcs_space being
updated never fires, as it tests the wrong value -
ldebugfs_fid_write_common() returns 'count' on success.

Finally, this return value should be returned from
ldebugfs_fid_space_seq_write(), rather than always returning 'count',
so that errors can be detected.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/lproc_fid.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index e05487662afd..a1e5bf9f36ec 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -106,28 +106,35 @@ ldebugfs_fid_space_seq_write(struct file *file,
 	rc = ldebugfs_fid_write_common(buffer, count, &range);
 
 	spin_lock(&seq->lcs_lock);
+	if (seq->lcs_update)
+		/* An RPC call is active to update lcs_space */
+		rc = -EBUSY;
 	if (rc > 0)
 		seq->lcs_space = range;
 	spin_unlock(&seq->lcs_lock);
 
-	if (rc == 0) {
+	if (rc > 0) {
 		CDEBUG(D_INFO, "%s: Space: " DRANGE "\n",
 		       seq->lcs_name, PRANGE(&range));
 	}
 
-	return count;
+	return rc;
 }
 
 static int
 ldebugfs_fid_space_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
+	int rc = 0;
 
 	spin_lock(&seq->lcs_lock);
-	seq_printf(m, "[%#llx - %#llx]:%x:%s\n", PRANGE(&seq->lcs_space));
+	if (seq->lcs_update)
+		rc = -EBUSY;
+	else
+		seq_printf(m, "[%#llx - %#llx]:%x:%s\n", PRANGE(&seq->lcs_space));
 	spin_unlock(&seq->lcs_lock);
 
-	return 0;
+	return rc;
 }
 
 static ssize_t
