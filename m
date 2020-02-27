From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:07 -0500
Subject: [lustre-devel] [PATCH 019/622] lustre: hsm: ignore compound_id
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Ignore request compound ids in the HSM coordinator. Compound ids
prevent batching of CDT to CT requests and degrade HSM
performance. Use CT/archive id compatabiliy when deciding which HSM
actions to put in a request.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10383
Lustre-commit: 9ee81f920bb3 ("LU-10383 hsm: ignore compound_id")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30949
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h  | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 4e1605a2..307feb3 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2508,7 +2508,7 @@ struct llog_agent_req_rec {
 						 */
 	__u32			arr_archive_id;	/**< backend archive number */
 	__u64			arr_flags;	/**< req flags */
-	__u64			arr_compound_id;/**< compound cookie */
+	__u64			arr_compound_id;/**< compound cookie, ignored */
 	__u64			arr_req_create;	/**< req. creation time */
 	__u64			arr_req_change;	/**< req. status change time */
 	struct hsm_action_item	arr_hai;	/**< req. to the agent */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 27501a2..5405e1b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1729,7 +1729,7 @@ static inline char *hai_dump_data_field(struct hsm_action_item *hai,
 struct hsm_action_list {
 	__u32 hal_version;
 	__u32 hal_count;	/* number of hai's to follow */
-	__u64 hal_compound_id;	/* returned by coordinator */
+	__u64 hal_compound_id;	/* returned by coordinator, ignored */
 	__u64 hal_flags;
 	__u32 hal_archive_id;	/* which archive backend */
 	__u32 padding1;
-- 
1.8.3.1
