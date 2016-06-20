From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:37 -0400
Subject: [lustre-devel] [PATCH v2 14/29] staging/lustre: Add newline to
	LU_OBJECT_DEBUG() message
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bob Glossman <bob.glossman@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bob Glossman <bob.glossman@intel.com>

LU_OBJECT_DEBUG expects non \n terminated message from the caller,
so it should add it's own to keep debug logger happy.

Signed-off-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-on: http://review.whamcloud.com/19960
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8094
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index c6281e6..6e25c1b 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -779,7 +779,7 @@ do {								      \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		     \
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 		lu_object_print(env, &msgdata, lu_cdebug_printer, object);\
-		CDEBUG(mask, format, ## __VA_ARGS__);		    \
+		CDEBUG(mask, format "\n", ## __VA_ARGS__);		    \
 	}								 \
 } while (0)
 
-- 
2.7.4
