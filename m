From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:31 -0500
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: Correct missing newline
	for CERROR call in sfw_handle_server_rpc
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Nunez <james.a.nunez@intel.com>

From: James Nunez <james.a.nunez@intel.com>

This is one of the fixes broken out of patch 10000 that was
missed in the merger. With this fix the CERROR called in
sfw_handle_server_rpc will print out correctly.

Signed-off-by: James Nunez <james.a.nunez@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4871
Reviewed-on: http://review.whamcloud.com/10000
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Cliff White <cliff.white@intel.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 926c397..0f32f0b 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1244,7 +1244,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 
 	/* Remove timer to avoid racing with it or expiring active session */
 	if (sfw_del_session_timer()) {
-		CERROR("Dropping RPC (%s) from %s: racing with expiry timer.",
+		CERROR("dropping RPC %s from %s: racing with expiry timer\n",
 		       sv->sv_name, libcfs_id2str(rpc->srpc_peer));
 		spin_unlock(&sfw_data.fw_lock);
 		return -EAGAIN;
-- 
1.7.1
