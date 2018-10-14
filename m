From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:30 -0400
Subject: [lustre-devel] [PATCH 08/10] lustre: lnd: correct WR fast reg
 accounting
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Ensure that enough WRs are allocated for the fast reg
case which needs two additional WRs per transfer:
the first for memory window registration and the second for
memory window invalidation.

Failure to allocate these causes the following problem:
mlx5_warn:mlx5_0:begin_wqe:4085(pid 9590): work queue overflow

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9943
Reviewed-on: https://review.whamcloud.com/30311
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 43266d8..66aa45f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -656,8 +656,13 @@ static unsigned int kiblnd_send_wrs(struct kib_conn *conn)
 	 * One WR for the LNet message
 	 * And ibc_max_frags for the transfer WRs
 	 */
+	u32 dev_caps = conn->ibc_hdev->ibh_dev->ibd_dev_caps;
 	unsigned int ret = 1 + conn->ibc_max_frags;
 
+	/* FastReg needs two extra WRs for map and invalidate */
+	if (dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)
+		ret += 2;
+
 	/* account for a maximum of ibc_queue_depth in-flight transfers */
 	ret *= conn->ibc_queue_depth;
 	return ret;
-- 
1.8.3.1
