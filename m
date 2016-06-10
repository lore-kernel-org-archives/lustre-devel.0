From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:16 -0400
Subject: [lustre-devel] [PATCH 6/8] staging/lustre/obdclass: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/obdclass directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/llog.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 79194d8..55a9755 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -123,8 +123,10 @@ static int llog_read_header(const struct lu_env *env,
 		handle->lgh_last_idx = 0; /* header is record with index 0 */
 		llh->llh_count = 1;	 /* for the header record */
 		llh->llh_hdr.lrh_type = LLOG_HDR_MAGIC;
-		llh->llh_hdr.lrh_len = llh->llh_tail.lrt_len = LLOG_CHUNK_SIZE;
-		llh->llh_hdr.lrh_index = llh->llh_tail.lrt_index = 0;
+		llh->llh_hdr.lrh_len = LLOG_CHUNK_SIZE;
+		llh->llh_tail.lrt_len = LLOG_CHUNK_SIZE;
+		llh->llh_hdr.lrh_index = 0;
+		llh->llh_tail.lrt_index = 0;
 		llh->llh_timestamp = ktime_get_real_seconds();
 		if (uuid)
 			memcpy(&llh->llh_tgtuuid, uuid,
-- 
2.7.4
