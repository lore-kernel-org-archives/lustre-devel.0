From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:46 -0400
Subject: [lustre-devel] [PATCH 33/80] staging: lustre: lmv: cleanup req in
	lmv_getattr_name()
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In lmv_getattr_name() don't return a freed request in the error path.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4826
Reviewed-on: http://review.whamcloud.com/9863
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 5929994..f1b8ae9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1920,6 +1920,7 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		tgt = lmv_find_target(lmv, &rid);
 		if (IS_ERR(tgt)) {
 			ptlrpc_req_finished(*request);
+			*request = NULL;
 			return PTR_ERR(tgt);
 		}
 
-- 
1.7.1
