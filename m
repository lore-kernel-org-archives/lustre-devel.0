From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:29 -0400
Subject: [lustre-devel] [PATCH 76/80] staging: lustre: lnet: Do not drop
	message when shutting down LNet
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-77-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

There is a case in lnet_parse() where we discover that LNet
is shutting down but we continue to use the NI when we drop the
message and end up calling ko2iblnd_check_send_locked() which tries to
allocate from the Tx pool which has been cleaned up already.
This triggers a NULL pointer dereference.

This fix just returns from lnet_parse() when we disover LNet is
shutting down.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8106
Reviewed-on: http://review.whamcloud.com/19993
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 6a3f2e1..5598fa8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -2002,6 +2002,9 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type), rc);
 		lnet_msg_free(msg);
+		if (rc == -ESHUTDOWN)
+			/* We are shutting down. Don't do anything more */
+			return 0;
 		goto drop;
 	}
 
-- 
1.7.1
