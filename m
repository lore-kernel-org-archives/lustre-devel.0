From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:56 -0500
Subject: [lustre-devel] [PATCH 26/35] staging: lustre: mdc: remove console
	spew from mdc_ioc_fid2path
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

In some cases with a very long pathname, such as with sanity.sh
test_154c, mdc_ioc_fid2path() would spew long debug messages to
the log, because libcfs_debug_vmsg2() refuses to log messages over
one page in size.

Truncate the debug message to only log the last 512 characters
of the pathname, which is sufficient for most debugging, saves a
bit of space in the debug log, and will prevent the debug logging
from printing to the console in the first place.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1095
Reviewed-on: http://review.whamcloud.com/17078
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index eee848d..6bed5ec 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1455,8 +1455,11 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 		goto out;
 	}
 
-	CDEBUG(D_IOCTL, "path get "DFID" from %llu #%d\n%s\n",
-	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno, gf->gf_path);
+	CDEBUG(D_IOCTL, "path got " DFID " from %llu #%d: %s\n",
+	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno,
+	       gf->gf_pathlen < 512 ? gf->gf_path :
+	       /* only log the last 512 characters of the path */
+	       gf->gf_path + gf->gf_pathlen - 512);
 
 out:
 	kfree(key);
-- 
1.7.1
