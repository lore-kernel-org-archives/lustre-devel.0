From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:48 -0400
Subject: [lustre-devel] [PATCH v2 25/29] staging/lustre/osc: fix signed one
	bit field
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Bit field 'oi_lockless' and 'oi_is_active' has one bit and is signed
which is confusing.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-on: http://review.whamcloud.com/19196
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7258
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 437c659..c8c3f1c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -62,7 +62,7 @@ struct osc_io {
 	/** super class */
 	struct cl_io_slice oi_cl;
 	/** true if this io is lockless. */
-	int		oi_lockless;
+	unsigned int		oi_lockless;
 	/** how many LRU pages are reserved for this IO */
 	int oi_lru_reserved;
 
-- 
2.7.4
