From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:15 -0400
Subject: [lustre-devel] [PATCH 2/8] lustre: obdclass: remove cl_for_each
 defines
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

cl_for_each and cl_for_each_reverse are simply aliases
for list_for_each_entry and list_for_each_entry_reverse
There is no point to them so just get rid of them and
eliminate any confusion.

Signed-off-by: Ben Evans <bevans@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9575
Reviewed-on: https://review.whamcloud.com/27385
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 3a96d4a..879383ae 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -52,11 +52,6 @@
  *
  */
 
-#define cl_io_for_each(slice, io) \
-	list_for_each_entry((slice), &io->ci_layers, cis_linkage)
-#define cl_io_for_each_reverse(slice, io)		 \
-	list_for_each_entry_reverse((slice), &io->ci_layers, cis_linkage)
-
 static inline int cl_io_type_is_valid(enum cl_io_type type)
 {
 	return CIT_READ <= type && type < CIT_OP_NR;
@@ -343,13 +338,14 @@ int cl_io_lock(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(io->ci_state == CIS_IT_STARTED);
 	LINVRNT(cl_io_invariant(io));
 
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->op[io->ci_type].cio_lock)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_lock(env, scan);
 		if (result != 0)
 			break;
 	}
+
 	if (result == 0) {
 		cl_io_locks_sort(io);
 		result = cl_lockset_lock(env, io, &io->ci_lockset);
@@ -391,7 +387,7 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
 			link->cill_fini(env, link);
 	}
 
-	cl_io_for_each_reverse(scan, io) {
+	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
 		if (scan->cis_iop->op[io->ci_type].cio_unlock)
 			scan->cis_iop->op[io->ci_type].cio_unlock(env, scan);
 	}
@@ -416,7 +412,7 @@ int cl_io_iter_init(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	result = 0;
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->op[io->ci_type].cio_iter_init)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_iter_init(env,
@@ -443,7 +439,7 @@ void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(io->ci_state == CIS_UNLOCKED);
 	LINVRNT(cl_io_invariant(io));
 
-	cl_io_for_each_reverse(scan, io) {
+	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
 		if (scan->cis_iop->op[io->ci_type].cio_iter_fini)
 			scan->cis_iop->op[io->ci_type].cio_iter_fini(env, scan);
 	}
@@ -468,7 +464,7 @@ static void cl_io_rw_advance(const struct lu_env *env, struct cl_io *io,
 	io->u.ci_rw.crw_count -= nob;
 
 	/* layers have to be notified. */
-	cl_io_for_each_reverse(scan, io) {
+	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
 		if (scan->cis_iop->op[io->ci_type].cio_advance)
 			scan->cis_iop->op[io->ci_type].cio_advance(env, scan,
 								   nob);
@@ -536,7 +532,7 @@ int cl_io_start(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	io->ci_state = CIS_IO_GOING;
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->op[io->ci_type].cio_start)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_start(env, scan);
@@ -561,7 +557,7 @@ void cl_io_end(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(io->ci_state == CIS_IO_GOING);
 	LINVRNT(cl_io_invariant(io));
 
-	cl_io_for_each_reverse(scan, io) {
+	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
 		if (scan->cis_iop->op[io->ci_type].cio_end)
 			scan->cis_iop->op[io->ci_type].cio_end(env, scan);
 		/* TODO: error handling. */
@@ -584,7 +580,7 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
 	LINVRNT(cl_io_invariant(io));
 
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->cio_read_ahead)
 			continue;
 
@@ -609,7 +605,7 @@ int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 	const struct cl_io_slice *scan;
 	int result = 0;
 
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->cio_commit_async)
 			continue;
 		result = scan->cis_iop->cio_commit_async(env, scan, queue,
@@ -637,7 +633,7 @@ int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 	const struct cl_io_slice *scan;
 	int result = 0;
 
-	cl_io_for_each(scan, io) {
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
 		if (!scan->cis_iop->cio_submit)
 			continue;
 		result = scan->cis_iop->cio_submit(env, scan, crt, queue);
-- 
1.8.3.1
