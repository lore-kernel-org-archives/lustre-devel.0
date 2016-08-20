From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:21 -0400
Subject: [lustre-devel] [PATCH 04/13] lustre: ->kss_scratch... are unused now
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <green@linuxhacker.ru>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index d5efb42..84a915c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -86,10 +86,6 @@ struct ksock_sched {				/* per scheduler state */
 	int                     kss_nconns;     /* # connections assigned to
 						 * this scheduler */
 	struct ksock_sched_info *kss_info;	/* owner of it */
-	union {
-		struct bio_vec          kss_scratch_bvec[LNET_MAX_IOV];
-		struct kvec             kss_scratch_iov[LNET_MAX_IOV];
-	};
 };
 
 struct ksock_sched_info {
-- 
2.7.4
