From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:56 -0500
Subject: [lustre-devel] [PATCH 008/622] lustre: obdecho: turn on async flag
 only for mode 3
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Rahul Deshmukh <rahul_deshmukh@xyratex.com>

There are couple of problems in obdfilter-survey:
- Type of test brw i.e. "g" was not followed with npages,
- Target netdisk was not set properly and
- Turn ON async flag only for mode 3.

This patch fixes the last problem which is kernel side.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5031
Lustre-commit: 9f38647a7b24 ("LU-5031 tests: obdfilter-survey fixes")
Signed-off-by: Rahul Deshmukh <rahul_deshmukh@xyratex.com>
Reviewed-on: http://review.whamcloud.com/10264
Reviewed-by: Cliff White <cliff.white@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdecho/echo_client.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index ca963bb..3984cb4 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1425,7 +1425,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	struct obdo *oa = &data->ioc_obdo1;
 	struct echo_object *eco;
 	int rc;
-	int async = 1;
+	int async = 0;
 	long test_mode;
 
 	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
@@ -1438,14 +1438,14 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 
 	/* OFD/obdfilter works only via prep/commit */
 	test_mode = (long)data->ioc_pbuf1;
-	if (test_mode == 1)
-		async = 0;
-
 	if (!ed->ed_next && test_mode != 3) {
 		test_mode = 3;
 		data->ioc_plen1 = data->ioc_count;
 	}
 
+	if (test_mode == 3)
+		async = 1;
+
 	/* Truncate batch size to maximum */
 	if (data->ioc_plen1 > PTLRPC_MAX_BRW_SIZE)
 		data->ioc_plen1 = PTLRPC_MAX_BRW_SIZE;
-- 
1.8.3.1
