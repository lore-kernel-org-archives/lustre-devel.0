From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:59 -0500
Subject: [lustre-devel] [PATCH 29/35] staging: lustre: misc: clean up DFID
	related error messages
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Improve the error messages related to DFID output and parsing
for usage in userspace.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1606
Reviewed-on: http://review.whamcloud.com/6156
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    9 +++++----
 .../lustre/lustre/include/lustre/lustre_user.h     |   17 ++++++-----------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c06909a..b8ddebd 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -537,13 +537,14 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 {
 	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
 		if (oid >= IDIF_MAX_OID) {
-			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
+			CERROR("Too large OID %#llx to set MDT0 " DOSTID "\n",
+			       oid, POSTID(oi));
 			return;
 		}
 		oi->oi.oi_id = oid;
 	} else if (fid_is_idif(&oi->oi_fid)) {
 		if (oid >= IDIF_MAX_OID) {
-			CERROR("Bad %llu to set "DOSTID"\n",
+			CERROR("Too large OID %#llx to set IDIF " DOSTID "\n",
 			       oid, POSTID(oi));
 			return;
 		}
@@ -569,7 +570,7 @@ static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
 
 	if (fid_is_idif(fid)) {
 		if (oid >= IDIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set IDIF "DFID"\n",
+			CERROR("Too large OID %#llx to set IDIF " DFID "\n",
 			       (unsigned long long)oid, PFID(fid));
 			return -EBADF;
 		}
@@ -578,7 +579,7 @@ static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
 		fid->f_ver = oid >> 48;
 	} else {
 		if (oid >= OBIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set REG "DFID"\n",
+			CERROR("Too large OID %#llx to set REG " DFID "\n",
 			       (unsigned long long)oid, PFID(fid));
 			return -EBADF;
 		}
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index e393ae3..d964841 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -528,25 +528,20 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 }
 
 /* printf display format
- * e.g. printf("file FID is "DFID"\n", PFID(fid));
+ * * usage: printf("file FID is "DFID"\n", PFID(fid));
  */
 #define FID_NOBRACE_LEN 40
 #define FID_LEN (FID_NOBRACE_LEN + 2)
 #define DFID_NOBRACE "%#llx:0x%x:0x%x"
 #define DFID "["DFID_NOBRACE"]"
-#define PFID(fid)     \
-	(fid)->f_seq, \
-	(fid)->f_oid, \
-	(fid)->f_ver
+#define PFID(fid) (unsigned long long)(fid)->f_seq, (fid)->f_oid, (fid)->f_ver
 
-/* scanf input parse format -- strip '[' first.
- * e.g. sscanf(fidstr, SFID, RFID(&fid));
+/* scanf input parse format for fids in DFID_NOBRACE format
+ * Need to strip '[' from DFID format first or use "["SFID"]" at caller.
+ * usage: sscanf(fidstr, SFID, RFID(&fid));
  */
 #define SFID "0x%llx:0x%x:0x%x"
-#define RFID(fid)     \
-	&((fid)->f_seq), \
-	&((fid)->f_oid), \
-	&((fid)->f_ver)
+#define RFID(fid) &((fid)->f_seq), &((fid)->f_oid), &((fid)->f_ver)
 
 /********* Quotas **********/
 
-- 
1.7.1
