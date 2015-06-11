From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:09 -0400
Subject: [lustre-devel] [PATCH v4 3/9] staging:lustre: rename
	socklnd_lib-linux.c
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

With the move to support only the linux kernel their is
no need to keep "linux" in the socklnd source file names.
This is broken out of the original patch 12932 that was
merged to the Intel/OpenSFS branch.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/12932
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile |    2 +-
 .../socklnd/{socklnd_lib-linux.c => socklnd_lib.c} |    0
 2 files changed, 1 insertions(+), 1 deletions(-)
 rename drivers/staging/lustre/lnet/klnds/socklnd/{socklnd_lib-linux.c => socklnd_lib.c} (100%)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
index f3fb877..c011581 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_LNET) += ksocklnd.o
 
-ksocklnd-y := socklnd.o socklnd_cb.o socklnd_proto.o socklnd_modparams.o socklnd_lib-linux.o
+ksocklnd-y := socklnd.o socklnd_cb.o socklnd_proto.o socklnd_modparams.o socklnd_lib.o
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
similarity index 100%
rename from drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
rename to drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
-- 
1.7.1
