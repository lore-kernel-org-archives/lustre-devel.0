From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:55 -0400
Subject: [lustre-devel] [PATCH 19/32] staging: lustre: fld: add fld
	description documentation
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, James Simmons <jsimmons@infradead.org>

From: Patrick Farrell <paf@cray.com>

Add subsystem description from Di Wang to header file.

Signed-off-by: Patrick Farrell <paf@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5153
Reviewed-on: http://review.whamcloud.com/10631
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/fld_internal.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index f0efe5b..08eaec7 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -31,6 +31,25 @@
  *
  * lustre/fld/fld_internal.h
  *
+ * Subsystem Description:
+ * FLD is FID Location Database, which stores where (IE, on which MDT)
+ * FIDs are located.
+ * The database is basically a record file, each record consists of a FID
+ * sequence range, MDT/OST index, and flags. The FLD for the whole FS
+ * is only stored on the sequence controller(MDT0) right now, but each target
+ * also has its local FLD, which only stores the local sequence.
+ *
+ * The FLD subsystem usually has two tasks:
+ * 1. maintain the database, i.e. when the sequence controller allocates
+ * new sequence ranges to some nodes, it will call the FLD API to insert the
+ * location information <sequence_range, node_index> in FLDB.
+ *
+ * 2. Handle requests from other nodes, i.e. if client needs to know where
+ * the FID is located, if it can not find the information in the local cache,
+ * it will send a FLD lookup RPC to the FLD service, and the FLD service will
+ * look up the FLDB entry and return the location information to client.
+ *
+ *
  * Author: Yury Umanets <umka@clusterfs.com>
  * Author: Tom WangDi <wangdi@clusterfs.com>
  */
-- 
1.7.1
