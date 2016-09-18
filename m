From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:24 -0400
Subject: [lustre-devel] [PATCH 085/124] staging: lustre: obdclass: change
	loop indexes to unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-86-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Cleanup warnings about comparison between signed and unsigned.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12387
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    6 +++---
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 6643e78..7894cf9 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1211,7 +1211,7 @@ void cl_req_page_add(const struct lu_env *env,
 {
 	struct cl_object  *obj;
 	struct cl_req_obj *rqo;
-	int i;
+	unsigned int i;
 
 	LASSERT(list_empty(&page->cp_flight));
 	LASSERT(!page->cp_req);
@@ -1258,7 +1258,7 @@ EXPORT_SYMBOL(cl_req_page_done);
  */
 int cl_req_prep(const struct lu_env *env, struct cl_req *req)
 {
-	int i;
+	unsigned int i;
 	int result;
 	const struct cl_req_slice *slice;
 
@@ -1291,7 +1291,7 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
 {
 	const struct cl_req_slice *slice;
 	struct cl_page	    *page;
-	int i;
+	unsigned int i;
 
 	LASSERT(!list_empty(&req->crq_pages));
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 91a5806..bd85455 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -377,7 +377,7 @@ static void cl_env_percpu_refill(void);
  */
 int cl_site_init(struct cl_site *s, struct cl_device *d)
 {
-	int i;
+	size_t i;
 	int result;
 
 	result = lu_site_init(&s->cs_lu, &d->cd_lu_dev);
@@ -411,7 +411,7 @@ static struct cache_stats cl_env_stats = {
  */
 int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 {
-	int i;
+	size_t i;
 	static const char *pstate[] = {
 		[CPS_CACHED]  = "c",
 		[CPS_OWNED]   = "o",
@@ -1126,7 +1126,7 @@ static void *cl_key_init(const struct lu_context *ctx,
 
 	info = cl0_key_init(ctx, key);
 	if (!IS_ERR(info)) {
-		int i;
+		size_t i;
 
 		for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i)
 			lu_ref_init(&info->clt_counters[i].ctc_locks_locked);
@@ -1138,7 +1138,7 @@ static void cl_key_fini(const struct lu_context *ctx,
 			struct lu_context_key *key, void *data)
 {
 	struct cl_thread_info *info;
-	int i;
+	size_t i;
 
 	info = data;
 	for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i)
@@ -1150,7 +1150,7 @@ static void cl_key_exit(const struct lu_context *ctx,
 			struct lu_context_key *key, void *data)
 {
 	struct cl_thread_info *info = data;
-	int i;
+	size_t i;
 
 	for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i) {
 		LASSERT(info->clt_counters[i].ctc_nr_held == 0);
-- 
1.7.1
