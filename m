From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:25:58 -0400
Subject: [lustre-devel] [PATCH 04/64 v2] staging: lustre: uapi: update URL
	doc link in lustre_fid.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

The wiki has been revived so update the URL about the FID
design in lustre_fid.h.

Signed-off-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/22712
Reviewed-on: https://review.whamcloud.com/24569
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_fid.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 681f698..0446bec 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -41,7 +41,7 @@
  *
  * @{
  *
- * http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
+ * http://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
  * describes the FID namespace and interoperability requirements for FIDs.
  * The important parts of that document are included here for reference.
  *
-- 
1.8.3.1
