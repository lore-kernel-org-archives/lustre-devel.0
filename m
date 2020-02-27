From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:07 -0500
Subject: [lustre-devel] [PATCH 619/622] lustre: lustre: use LIST_HEAD() for
 local lists.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-620-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When declaring a local list head, instead of

   struct list_head list;
   INIT_LIST_HEAD(&list);

use
   LIST_HEAD(list);

which does both steps.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 0098396983e1 ("LU-9679 lustre: use LIST_HEAD() for local lists.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36955
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c | 3 +--
 fs/lustre/obdclass/lu_object.c      | 6 ++----
 fs/lustre/obdclass/obd_mount.c      | 3 +--
 fs/lustre/ptlrpc/client.c           | 3 +--
 fs/lustre/ptlrpc/service.c          | 3 +--
 5 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 325005d..b19a1bd 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1885,7 +1885,7 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 			     struct root_squash_info *squash, char *name)
 {
 	char *kernbuf = NULL, *errmsg;
-	struct list_head tmp;
+	LIST_HEAD(tmp);
 	int len = count;
 	int rc;
 
@@ -1924,7 +1924,6 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 		return count;
 	}
 
-	INIT_LIST_HEAD(&tmp);
 	if (cfs_parse_nidlist(kernbuf, count, &tmp) <= 0) {
 		errmsg = "can't parse";
 		rc = -EINVAL;
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 7ea9948..e328f89 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -361,7 +361,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 	struct lu_site *site;
 	struct lu_object *scan;
 	struct list_head *layers;
-	struct list_head splice;
+	LIST_HEAD(splice);
 
 	site = o->lo_dev->ld_site;
 	layers = &o->lo_header->loh_layers;
@@ -380,7 +380,6 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 	 * necessary, because lu_object_header is freed together with the
 	 * top-level slice.
 	 */
-	INIT_LIST_HEAD(&splice);
 	list_splice_init(layers, &splice);
 	while (!list_empty(&splice)) {
 		/*
@@ -408,7 +407,7 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	struct lu_object_header *h;
 	struct lu_object_header *temp;
 	struct lu_site_bkt_data *bkt;
-	struct list_head dispose;
+	LIST_HEAD(dispose);
 	int did_sth;
 	unsigned int start = 0;
 	int count;
@@ -418,7 +417,6 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_NO_LRU))
 		return 0;
 
-	INIT_LIST_HEAD(&dispose);
 	/*
 	 * Under LRU list lock, scan LRU list and move unreferenced objects to
 	 * the dispose list, removing them from LRU and hash table.
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 31f2f5b..206edde 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -982,7 +982,7 @@ static bool lmd_find_delimiter(char *buf, char **endh)
  */
 static int lmd_parse_nidlist(char *buf, char **endh)
 {
-	struct list_head nidlist;
+	LIST_HEAD(nidlist);
 	char *endp = buf;
 	int rc = 0;
 	char tmp;
@@ -1000,7 +1000,6 @@ static int lmd_parse_nidlist(char *buf, char **endh)
 	tmp = *endp;
 	*endp = '\0';
 
-	INIT_LIST_HEAD(&nidlist);
 	if (cfs_parse_nidlist(buf, strlen(buf), &nidlist) <= 0)
 		rc = 1;
 	cfs_free_nidlist(&nidlist);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 1714e66..424819e 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1715,13 +1715,12 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req, *next;
-	struct list_head comp_reqs;
+	LIST_HEAD(comp_reqs);
 	int force_timer_recalc = 0;
 
 	if (atomic_read(&set->set_remaining) == 0)
 		return 1;
 
-	INIT_LIST_HEAD(&comp_reqs);
 	list_for_each_entry_safe(req, next, &set->set_requests, rq_set_chain) {
 		struct obd_import *imp = req->rq_import;
 		int unregistered = 0;
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index f65d5c5..b10c61b 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1211,7 +1211,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
 	struct ptlrpc_request *rq, *n;
-	struct list_head work_list;
+	LIST_HEAD(work_list);
 	u32 index, count;
 	time64_t deadline;
 	time64_t now = ktime_get_real_seconds();
@@ -1244,7 +1244,6 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	 * We're close to a timeout, and we don't know how much longer the
 	 * server will take. Send early replies to everyone expiring soon.
 	 */
-	INIT_LIST_HEAD(&work_list);
 	deadline = -1;
 	div_u64_rem(array->paa_deadline, array->paa_size, &index);
 	count = array->paa_count;
-- 
1.8.3.1
