From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:21 -0400
Subject: [lustre-devel] [PATCH 1/9] staging: lustre: libcfs: remove function
	declarations in libcfs.h
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

A few function declarations are in libcfs.h that are not needed.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13874
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index d2e4361..332394c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -60,15 +60,8 @@
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
 /*
- * Drop into debugger, if possible. Implementation is provided by platform.
- */
-
-void cfs_enter_debugger(void);
-
-/*
  * Defined by platform
  */
-int unshare_fs_struct(void);
 sigset_t cfs_block_allsigs(void);
 sigset_t cfs_block_sigs(unsigned long sigs);
 sigset_t cfs_block_sigsinv(unsigned long sigs);
-- 
1.7.1
