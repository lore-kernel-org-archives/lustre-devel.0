From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:20 -0500
Subject: [lustre-devel] [PATCH 52/60] staging: lustre: linkea: linkEA size
	limitation
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-53-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Under DNE mode, if we do not restrict the linkEA size, and if there
are too many cross-MDTs hard links to the same object, then it will
casue the llog overflow. On the other hand, too many linkEA entries
in the linkEA will serious affect the linkEA performance because we
only support to locate linkEA entry consecutively.

So we need to restrict the linkEA size. Currently, it is 4096 bytes,
that is independent from the backend. If too many hard links caused
the linkEA overflowed, we will add overflow timestamp in the linkEA
header. Such overflow timestamp has some functionalities:

1. It will prevent the object being migrated to other MDT, because
   some name entries may be not in the linkEA, so we cannot update
   these name entries for the migration.

2. It will tell the namespace LFSCK that the 'nlink' attribute may
   be more trustable than the linkEA, then avoid misguiding the
   namespace LFSCK to repair 'nlink' attribute based on linkEA.

There will be subsequent patch(es) for namespace LFSCK to handle the
linkEA size limitation and overflow cases.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8569
Reviewed-on: https://review.whamcloud.com/23500
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |  5 +-
 .../staging/lustre/lustre/include/lustre_linkea.h  | 15 ++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  2 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    | 70 +++++++++++++++++-----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 16 ++---
 5 files changed, 81 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b0eb80d..fc960da 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3217,9 +3217,8 @@ struct link_ea_header {
 	__u32 leh_magic;
 	__u32 leh_reccount;
 	__u64 leh_len;      /* total size */
-	/* future use */
-	__u32 padding1;
-	__u32 padding2;
+	__u32 leh_overflow_time;
+	__u32 leh_padding;
 };
 
 /** Hardlink data is name and parent fid.
diff --git a/drivers/staging/lustre/lustre/include/lustre_linkea.h b/drivers/staging/lustre/lustre/include/lustre_linkea.h
index 249e8bf..3ff008f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_linkea.h
+++ b/drivers/staging/lustre/lustre/include/lustre_linkea.h
@@ -26,7 +26,19 @@
  * Author: di wang <di.wang@intel.com>
  */
 
-#define DEFAULT_LINKEA_SIZE	4096
+/* There are several reasons to restrict the linkEA size:
+ *
+ * 1. Under DNE mode, if we do not restrict the linkEA size, and if there
+ *    are too many cross-MDTs hard links to the same object, then it will
+ *    casue the llog overflow.
+ *
+ * 2. Some backend has limited size for EA. For example, if without large
+ *    EA enabled, the ldiskfs will make all EAs to share one (4K) EA block.
+ *
+ * 3. Too many entries in linkEA will seriously affect linkEA performance
+ *    because we only support to locate linkEA entry consecutively.
+ */
+#define MAX_LINKEA_SIZE		4096
 
 struct linkea_data {
 	/**
@@ -43,6 +55,7 @@ struct linkea_data {
 
 int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf);
 int linkea_init(struct linkea_data *ldata);
+int linkea_init_with_rec(struct linkea_data *ldata);
 void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 			 struct lu_name *lname, struct lu_fid *pfid);
 int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b229cbc..9a9cdb0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2553,7 +2553,7 @@ static int ll_linkea_decode(struct linkea_data *ldata, unsigned int linkno,
 	unsigned int idx;
 	int rc;
 
-	rc = linkea_init(ldata);
+	rc = linkea_init_with_rec(ldata);
 	if (rc < 0)
 		return rc;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index 0b1d2f0..dddd0c4 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -39,6 +39,8 @@ int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf)
 	ldata->ld_leh->leh_magic = LINK_EA_MAGIC;
 	ldata->ld_leh->leh_len = sizeof(struct link_ea_header);
 	ldata->ld_leh->leh_reccount = 0;
+	ldata->ld_leh->leh_overflow_time = 0;
+	ldata->ld_leh->leh_padding = 0;
 	return 0;
 }
 EXPORT_SYMBOL(linkea_data_new);
@@ -53,11 +55,15 @@ int linkea_init(struct linkea_data *ldata)
 		leh->leh_magic = LINK_EA_MAGIC;
 		leh->leh_reccount = __swab32(leh->leh_reccount);
 		leh->leh_len = __swab64(leh->leh_len);
-		/* entries are swabbed by linkea_entry_unpack */
+		leh->leh_overflow_time = __swab32(leh->leh_overflow_time);
+		leh->leh_padding = __swab32(leh->leh_padding);
+		/* individual entries are swabbed by linkea_entry_unpack() */
 	}
+
 	if (leh->leh_magic != LINK_EA_MAGIC)
 		return -EINVAL;
-	if (leh->leh_reccount == 0)
+
+	if (leh->leh_reccount == 0 && leh->leh_overflow_time == 0)
 		return -ENODATA;
 
 	ldata->ld_leh = leh;
@@ -65,6 +71,18 @@ int linkea_init(struct linkea_data *ldata)
 }
 EXPORT_SYMBOL(linkea_init);
 
+int linkea_init_with_rec(struct linkea_data *ldata)
+{
+	int rc;
+
+	rc = linkea_init(ldata);
+	if (!rc && ldata->ld_leh->leh_reccount == 0)
+		rc = -ENODATA;
+
+	return rc;
+}
+EXPORT_SYMBOL(linkea_init_with_rec);
+
 /**
  * Pack a link_ea_entry.
  * All elements are stored as chars to avoid alignment issues.
@@ -94,6 +112,8 @@ int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
 void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 			 struct lu_name *lname, struct lu_fid *pfid)
 {
+	LASSERT(lee);
+
 	*reclen = (lee->lee_reclen[0] << 8) | lee->lee_reclen[1];
 	memcpy(pfid, &lee->lee_parent_fid, sizeof(*pfid));
 	fid_be_to_cpu(pfid, pfid);
@@ -110,25 +130,45 @@ void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
 		   const struct lu_fid *pfid)
 {
-	LASSERT(ldata->ld_leh);
+	struct link_ea_header *leh = ldata->ld_leh;
+	int reclen;
+
+	LASSERT(leh);
 
 	if (!lname || !pfid)
 		return -EINVAL;
 
-	ldata->ld_reclen = lname->ln_namelen + sizeof(struct link_ea_entry);
-	if (ldata->ld_leh->leh_len + ldata->ld_reclen >
-	    ldata->ld_buf->lb_len) {
+	reclen = lname->ln_namelen + sizeof(struct link_ea_entry);
+	if (unlikely(leh->leh_len + reclen > MAX_LINKEA_SIZE)) {
+		/*
+		 * Use 32-bits to save the overflow time, although it will
+		 * shrink the ktime_get_real_seconds() returned 64-bits value
+		 * to 32-bits value, it is still quite large and can be used
+		 * for about 140 years. That is enough.
+		 */
+		leh->leh_overflow_time = ktime_get_real_seconds();
+		if (unlikely(leh->leh_overflow_time == 0))
+			leh->leh_overflow_time++;
+
+		CDEBUG(D_INODE, "No enough space to hold linkea entry '" DFID ": %.*s' at %u\n",
+		       PFID(pfid), lname->ln_namelen,
+		       lname->ln_name, leh->leh_overflow_time);
+		return 0;
+	}
+
+	if (leh->leh_len + reclen > ldata->ld_buf->lb_len) {
 		if (lu_buf_check_and_grow(ldata->ld_buf,
-					  ldata->ld_leh->leh_len +
-					  ldata->ld_reclen) < 0)
+					  leh->leh_len + reclen) < 0)
 			return -ENOMEM;
+
+		ldata->ld_leh = ldata->ld_buf->lb_buf;
+		leh = ldata->ld_leh;
 	}
 
-	ldata->ld_leh = ldata->ld_buf->lb_buf;
-	ldata->ld_lee = ldata->ld_buf->lb_buf + ldata->ld_leh->leh_len;
+	ldata->ld_lee = ldata->ld_buf->lb_buf + leh->leh_len;
 	ldata->ld_reclen = linkea_entry_pack(ldata->ld_lee, lname, pfid);
-	ldata->ld_leh->leh_len += ldata->ld_reclen;
-	ldata->ld_leh->leh_reccount++;
+	leh->leh_len += ldata->ld_reclen;
+	leh->leh_reccount++;
 	CDEBUG(D_INODE, "New link_ea name '" DFID ":%.*s' is added\n",
 	       PFID(pfid), lname->ln_namelen, lname->ln_name);
 	return 0;
@@ -139,6 +179,7 @@ int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
 void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname)
 {
 	LASSERT(ldata->ld_leh && ldata->ld_lee);
+	LASSERT(ldata->ld_leh->leh_reccount > 0);
 
 	ldata->ld_leh->leh_reccount--;
 	ldata->ld_leh->leh_len -= ldata->ld_reclen;
@@ -174,8 +215,9 @@ int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
 
 	LASSERT(ldata->ld_leh);
 
-	/* link #0 */
-	ldata->ld_lee = (struct link_ea_entry *)(ldata->ld_leh + 1);
+	/* link #0, if leh_reccount == 0 we skip the loop and return -ENOENT */
+	if (likely(ldata->ld_leh->leh_reccount > 0))
+		ldata->ld_lee = (struct link_ea_entry *)(ldata->ld_leh + 1);
 
 	for (count = 0; count < ldata->ld_leh->leh_reccount; count++) {
 		linkea_entry_unpack(ldata->ld_lee, &ldata->ld_reclen,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index a04e36c..f166518 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -3820,14 +3820,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct link_ea_header, leh_len));
 	LASSERTF((int)sizeof(((struct link_ea_header *)0)->leh_len) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct link_ea_header *)0)->leh_len));
-	LASSERTF((int)offsetof(struct link_ea_header, padding1) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct link_ea_header, padding1));
-	LASSERTF((int)sizeof(((struct link_ea_header *)0)->padding1) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct link_ea_header *)0)->padding1));
-	LASSERTF((int)offsetof(struct link_ea_header, padding2) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct link_ea_header, padding2));
-	LASSERTF((int)sizeof(((struct link_ea_header *)0)->padding2) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct link_ea_header *)0)->padding2));
+	LASSERTF((int)offsetof(struct link_ea_header, leh_overflow_time) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct link_ea_header, leh_overflow_time));
+	LASSERTF((int)sizeof(((struct link_ea_header *)0)->leh_overflow_time) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct link_ea_header *)0)->leh_overflow_time));
+	LASSERTF((int)offsetof(struct link_ea_header, leh_padding) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct link_ea_header, leh_padding));
+	LASSERTF((int)sizeof(((struct link_ea_header *)0)->leh_padding) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct link_ea_header *)0)->leh_padding));
 	CLASSERT(LINK_EA_MAGIC == 0x11EAF1DFUL);
 
 	/* Checks for struct link_ea_entry */
-- 
1.8.3.1
