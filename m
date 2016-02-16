From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:49 -0500
Subject: [lustre-devel] [PATCH 17/45] staging/lustre/fid: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 14 +++++++-------
 drivers/staging/lustre/lustre/fid/lproc_fid.c   | 14 ++------------
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index ff8f38d..7ca65df 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -68,7 +68,7 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp), &RQF_SEQ_QUERY,
 					LUSTRE_MDS_VERSION, SEQ_QUERY);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	/* Init operation code */
@@ -226,8 +226,8 @@ int seq_client_alloc_fid(const struct lu_env *env,
 	wait_queue_t link;
 	int rc;
 
-	LASSERT(seq != NULL);
-	LASSERT(fid != NULL);
+	LASSERT(seq);
+	LASSERT(fid);
 
 	init_waitqueue_entry(&link, current);
 	mutex_lock(&seq->lcs_mutex);
@@ -292,7 +292,7 @@ void seq_client_flush(struct lu_client_seq *seq)
 {
 	wait_queue_t link;
 
-	LASSERT(seq != NULL);
+	LASSERT(seq);
 	init_waitqueue_entry(&link, current);
 	mutex_lock(&seq->lcs_mutex);
 
@@ -375,8 +375,8 @@ static int seq_client_init(struct lu_client_seq *seq,
 {
 	int rc;
 
-	LASSERT(seq != NULL);
-	LASSERT(prefix != NULL);
+	LASSERT(seq);
+	LASSERT(prefix);
 
 	seq->lcs_type = type;
 
@@ -438,7 +438,7 @@ int client_fid_fini(struct obd_device *obd)
 {
 	struct client_obd *cli = &obd->u.cli;
 
-	if (cli->cl_seq != NULL) {
+	if (cli->cl_seq) {
 		seq_client_fini(cli->cl_seq);
 		kfree(cli->cl_seq);
 		cli->cl_seq = NULL;
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 0320b6e..1f0e786 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -66,7 +66,7 @@ ldebugfs_fid_write_common(const char __user *buffer, size_t count,
 	int rc;
 	char kernbuf[MAX_FID_RANGE_STRLEN];
 
-	LASSERT(range != NULL);
+	LASSERT(range);
 
 	if (count >= sizeof(kernbuf))
 		return -EINVAL;
@@ -104,7 +104,6 @@ ldebugfs_fid_space_seq_write(struct file *file,
 	int rc;
 
 	seq = ((struct seq_file *)file->private_data)->private;
-	LASSERT(seq != NULL);
 
 	mutex_lock(&seq->lcs_mutex);
 	rc = ldebugfs_fid_write_common(buffer, count, &seq->lcs_space);
@@ -124,8 +123,6 @@ ldebugfs_fid_space_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	LASSERT(seq != NULL);
-
 	mutex_lock(&seq->lcs_mutex);
 	seq_printf(m, "[%#llx - %#llx]:%x:%s\n", PRANGE(&seq->lcs_space));
 	mutex_unlock(&seq->lcs_mutex);
@@ -143,7 +140,6 @@ ldebugfs_fid_width_seq_write(struct file *file,
 	int rc, val;
 
 	seq = ((struct seq_file *)file->private_data)->private;
-	LASSERT(seq != NULL);
 
 	rc = lprocfs_write_helper(buffer, count, &val);
 	if (rc)
@@ -172,8 +168,6 @@ ldebugfs_fid_width_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	LASSERT(seq != NULL);
-
 	mutex_lock(&seq->lcs_mutex);
 	seq_printf(m, "%llu\n", seq->lcs_width);
 	mutex_unlock(&seq->lcs_mutex);
@@ -186,8 +180,6 @@ ldebugfs_fid_fid_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	LASSERT(seq != NULL);
-
 	mutex_lock(&seq->lcs_mutex);
 	seq_printf(m, DFID "\n", PFID(&seq->lcs_fid));
 	mutex_unlock(&seq->lcs_mutex);
@@ -201,9 +193,7 @@ ldebugfs_fid_server_seq_show(struct seq_file *m, void *unused)
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 	struct client_obd *cli;
 
-	LASSERT(seq != NULL);
-
-	if (seq->lcs_exp != NULL) {
+	if (seq->lcs_exp) {
 		cli = &seq->lcs_exp->exp_obd->u.cli;
 		seq_printf(m, "%s\n", cli->cl_target_uuid.uuid);
 	}
-- 
2.1.0
