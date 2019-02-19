From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 12/37] lustre: remove unused function in
 linkea.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494549.24125.14755296858886216830.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Much of the linkea functionality is server-only.
Keep the parts used on the client, but remove the rest.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_linkea.h  |    8 -
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  150 --------------------
 2 files changed, 1 insertion(+), 157 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_linkea.h b/drivers/staging/lustre/lustre/include/lustre_linkea.h
index 03db1511bfd3..a028d91dd151 100644
--- a/drivers/staging/lustre/lustre/include/lustre_linkea.h
+++ b/drivers/staging/lustre/lustre/include/lustre_linkea.h
@@ -55,17 +55,9 @@ struct linkea_data {
 };
 
 int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf);
-int linkea_init(struct linkea_data *ldata);
 int linkea_init_with_rec(struct linkea_data *ldata);
 void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 			 struct lu_name *lname, struct lu_fid *pfid);
-int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
-		      const struct lu_fid *pfid);
-int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
-		   const struct lu_fid *pfid);
-void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname);
-int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
-		      const struct lu_fid  *pfid);
 
 static inline void linkea_first_entry(struct linkea_data *ldata)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index 33594bd26794..b1aa80a73a2c 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -48,7 +48,7 @@ int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf)
 }
 EXPORT_SYMBOL(linkea_data_new);
 
-int linkea_init(struct linkea_data *ldata)
+static int linkea_init(struct linkea_data *ldata)
 {
 	struct link_ea_header *leh;
 
@@ -72,7 +72,6 @@ int linkea_init(struct linkea_data *ldata)
 	ldata->ld_leh = leh;
 	return 0;
 }
-EXPORT_SYMBOL(linkea_init);
 
 int linkea_init_with_rec(struct linkea_data *ldata)
 {
@@ -86,32 +85,6 @@ int linkea_init_with_rec(struct linkea_data *ldata)
 }
 EXPORT_SYMBOL(linkea_init_with_rec);
 
-/**
- * Pack a link_ea_entry.
- * All elements are stored as chars to avoid alignment issues.
- * Numbers are always big-endian
- * \retval record length
- */
-int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
-		      const struct lu_fid *pfid)
-{
-	struct lu_fid tmpfid;
-	int reclen;
-
-	tmpfid = *pfid;
-	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_LINKEA_CRASH))
-		tmpfid.f_ver = ~0;
-	fid_cpu_to_be(&tmpfid, &tmpfid);
-	memcpy(&lee->lee_parent_fid, &tmpfid, sizeof(tmpfid));
-	memcpy(lee->lee_name, lname->ln_name, lname->ln_namelen);
-	reclen = sizeof(struct link_ea_entry) + lname->ln_namelen;
-
-	lee->lee_reclen[0] = (reclen >> 8) & 0xff;
-	lee->lee_reclen[1] = reclen & 0xff;
-	return reclen;
-}
-EXPORT_SYMBOL(linkea_entry_pack);
-
 void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 			 struct lu_name *lname, struct lu_fid *pfid)
 {
@@ -126,124 +99,3 @@ void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
 	}
 }
 EXPORT_SYMBOL(linkea_entry_unpack);
-
-/**
- * Add a record to the end of link ea buf
- **/
-int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
-		   const struct lu_fid *pfid)
-{
-	struct link_ea_header *leh = ldata->ld_leh;
-	int reclen;
-
-	LASSERT(leh);
-
-	if (!lname || !pfid)
-		return -EINVAL;
-
-	reclen = lname->ln_namelen + sizeof(struct link_ea_entry);
-	if (unlikely(leh->leh_len + reclen > MAX_LINKEA_SIZE)) {
-		/*
-		 * Use 32-bits to save the overflow time, although it will
-		 * shrink the ktime_get_real_seconds() returned 64-bits value
-		 * to 32-bits value, it is still quite large and can be used
-		 * for about 140 years. That is enough.
-		 */
-		leh->leh_overflow_time = ktime_get_real_seconds();
-		if (unlikely(leh->leh_overflow_time == 0))
-			leh->leh_overflow_time++;
-
-		CDEBUG(D_INODE, "No enough space to hold linkea entry '" DFID ": %.*s' at %u\n",
-		       PFID(pfid), lname->ln_namelen,
-		       lname->ln_name, leh->leh_overflow_time);
-		return 0;
-	}
-
-	if (leh->leh_len + reclen > ldata->ld_buf->lb_len) {
-		/* Note: this never happens as MAX_LINKEA_SIZE is 4096, while
-		 * the initial allocation is PAGE_SIZE.
-		 */
-		void *b = krealloc(ldata->ld_buf->lb_buf, leh->leh_len + reclen, GFP_NOFS);
-		if (!b)
-			return -ENOMEM;
-
-		ldata->ld_buf->lb_len = leh->leh_len + reclen;
-		leh = ldata->ld_leh = ldata->ld_buf->lb_buf = b;
-	}
-
-	ldata->ld_lee = ldata->ld_buf->lb_buf + leh->leh_len;
-	ldata->ld_reclen = linkea_entry_pack(ldata->ld_lee, lname, pfid);
-	leh->leh_len += ldata->ld_reclen;
-	leh->leh_reccount++;
-	CDEBUG(D_INODE, "New link_ea name '" DFID ":%.*s' is added\n",
-	       PFID(pfid), lname->ln_namelen, lname->ln_name);
-	return 0;
-}
-EXPORT_SYMBOL(linkea_add_buf);
-
-/** Del the current record from the link ea buf */
-void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname)
-{
-	LASSERT(ldata->ld_leh && ldata->ld_lee);
-	LASSERT(ldata->ld_leh->leh_reccount > 0);
-
-	ldata->ld_leh->leh_reccount--;
-	ldata->ld_leh->leh_len -= ldata->ld_reclen;
-	memmove(ldata->ld_lee, (char *)ldata->ld_lee + ldata->ld_reclen,
-		(char *)ldata->ld_leh + ldata->ld_leh->leh_len -
-		(char *)ldata->ld_lee);
-	CDEBUG(D_INODE, "Old link_ea name '%.*s' is removed\n",
-	       lname->ln_namelen, lname->ln_name);
-
-	if ((char *)ldata->ld_lee >= ((char *)ldata->ld_leh +
-				      ldata->ld_leh->leh_len))
-		ldata->ld_lee = NULL;
-}
-EXPORT_SYMBOL(linkea_del_buf);
-
-/**
- * Check if such a link exists in linkEA.
- *
- * \param ldata link data the search to be done on
- * \param lname name in the parent's directory entry pointing to this object
- * \param pfid parent fid the link to be found for
- *
- * \retval   0 success
- * \retval -ENOENT link does not exist
- * \retval -ve on error
- */
-int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
-		      const struct lu_fid  *pfid)
-{
-	struct lu_name tmpname;
-	struct lu_fid tmpfid;
-	int count;
-
-	LASSERT(ldata->ld_leh);
-
-	/* link #0, if leh_reccount == 0 we skip the loop and return -ENOENT */
-	if (likely(ldata->ld_leh->leh_reccount > 0))
-		ldata->ld_lee = (struct link_ea_entry *)(ldata->ld_leh + 1);
-
-	for (count = 0; count < ldata->ld_leh->leh_reccount; count++) {
-		linkea_entry_unpack(ldata->ld_lee, &ldata->ld_reclen,
-				    &tmpname, &tmpfid);
-		if (tmpname.ln_namelen == lname->ln_namelen &&
-		    lu_fid_eq(&tmpfid, pfid) &&
-		    (strncmp(tmpname.ln_name, lname->ln_name,
-			     tmpname.ln_namelen) == 0))
-			break;
-		ldata->ld_lee = (struct link_ea_entry *)((char *)ldata->ld_lee +
-							 ldata->ld_reclen);
-	}
-
-	if (count == ldata->ld_leh->leh_reccount) {
-		CDEBUG(D_INODE, "Old link_ea name '%.*s' not found\n",
-		       lname->ln_namelen, lname->ln_name);
-		ldata->ld_lee = NULL;
-		ldata->ld_reclen = 0;
-		return -ENOENT;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(linkea_links_find);
