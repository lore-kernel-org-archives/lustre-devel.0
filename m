From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:38 -0500
Subject: [lustre-devel] [PATCH 530/622] lustre: llite: use wait_event in
 cl_object_put_last()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-531-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

cl_object_put_last() contains an open-coded version
of wait_event().
Replace it with the library macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: f963f19c94b5 ("LU-10467 llite: use wait_event in cl_object_put_last()")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36345
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lcommon_cl.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 3129316..76f76a0 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -221,7 +221,6 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
 {
 	struct lu_object_header *header = obj->co_lu.lo_header;
-	wait_queue_entry_t waiter;
 
 	if (unlikely(atomic_read(&header->loh_ref) != 1)) {
 		struct lu_site *site = obj->co_lu.lo_dev->ld_site;
@@ -229,18 +228,7 @@ static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
 
 		wq = lu_site_wq_from_fid(site, &header->loh_fid);
 
-		init_waitqueue_entry(&waiter, current);
-		add_wait_queue(wq, &waiter);
-
-		while (1) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			if (atomic_read(&header->loh_ref) == 1)
-				break;
-			schedule();
-		}
-
-		set_current_state(TASK_RUNNING);
-		remove_wait_queue(wq, &waiter);
+		wait_event(*wq, atomic_read(&header->loh_ref) == 1);
 	}
 
 	cl_object_put(env, obj);
-- 
1.8.3.1
