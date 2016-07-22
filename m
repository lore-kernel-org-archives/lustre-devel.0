From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:31 -0400
Subject: [lustre-devel] [PATCH 38/58] staging: lustre: llite: enable clients
	to inject error for lfsck
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

This enables the client to inject an error by altering
the parent FID in order to test if the server side file
system checker behaves properly.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3951
Reviewed-on: http://review.whamcloud.com/7667
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/obd_support.h    |    1 +
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 845e64a..71bf844 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -474,6 +474,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LFSCK_CRASH		0x160a
 #define OBD_FAIL_LFSCK_NO_AUTO		0x160b
 #define OBD_FAIL_LFSCK_NO_DOUBLESCAN	0x160c
+#define OBD_FAIL_LFSCK_INVALID_PFID	0x1619
 
 /* UPDATE */
 #define OBD_FAIL_UPDATE_OBJ_NET			0x1700
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
index 9fe9d6c..0567a15 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -83,6 +83,8 @@ static void vvp_req_attr_set(const struct lu_env *env,
 	}
 	obdo_from_inode(oa, inode, valid_flags & flags);
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
+	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
+		oa->o_parent_oid++;
 	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
 	       JOBSTATS_JOBID_SIZE);
 }
-- 
1.7.1
