From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:18 -0400
Subject: [lustre-devel] [PATCH 01/18] lustre: grant: add support for
 OBD_CONNECT_GRANT_PARAM
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Johann Lombardi <jlombardi@whamcloud.com>

Add support for grant overhead calculation on the client side.
To do so, clients track usage on a per-extent basis. An extent is
composed of contiguous blocks.
The OST now returns to the OSC layer several parameters to consume
grant more accurately:

- the backend filesystem block size which is the minimal grant
  allocation unit;
- the maximum extent size;
- the extent insertion cost.
  Clients now pack in bulk write how much grant space was consumed for
  the RPC. Dirty data accounting also adopts the same scheme.

Moreover, each backend OSD now reports its own set of parameters:
- For ldiskfs, we usually have a 4KB block size with a maximum extent
  size of 32MB (theoretical limit of 128MB) and an extent insertion
  cost of 6 x 4KB = 24KB
- For ZFS, we report a block size of 128KB, an extent size of 128
  blocks (i.e. 16MB with 128KB block size) and a block insertion cost
  of 112KB.

Besides, there is now no more generic metadata overhead reservation
done inside each OSD. Instead grant space is inflated for clients
that do not support the new grant parameters. That said, a tiny
percentage (typically 0.76%) of the free space is still reserved
inside each OSD to avoid fragmentation which might hurt performance
and impact our grant calculation (e.g. extents are broken due to
fragmentation).

This patch also fixes several other issues:

- Bulk write resent by ptlrpc after reconnection could trigger
  spurious error messages related to broken dirty accounting.
  The issue was that oa_dirty is discarded for resent requests
  (grant flag cleared in ost_brw_write()), so we can legitimately
  have grant > fed_dirty in ofd_grant_check().
  This was fixed by resetting fed_dirty on reconnection and skipping
  the dirty accounting check in ofd_grant_check() in the case of
  ptlrpc resend.

- In obd_connect_data_seqprint(), the connection flags cannot fit
  in a 32-bit integer.

- When merging two OSC extents, an extent tax should be released
  in both the merged extent and in the grant accounting.

Signed-off-by: Johann Lombardi <jlombardi@whamcloud.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/2049
Reviewed-on: http://review.whamcloud.com/7793
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  8 +-
 drivers/staging/lustre/lustre/include/obd.h        |  9 ++-
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  9 +++
 .../lustre/lustre/obdclass/lprocfs_status.c        | 10 ++-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 18 +++++
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 84 +++++++++++++++------
 drivers/staging/lustre/lustre/osc/osc_request.c    | 85 ++++++++++++++++------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 32 ++++----
 10 files changed, 191 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 6c7e399..3d77ed6 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -732,10 +732,10 @@ struct obd_connect_data {
 	__u32 ocd_index;	 /* LOV index to connect to */
 	__u32 ocd_brw_size;	 /* Maximum BRW size in bytes */
 	__u64 ocd_ibits_known;   /* inode bits this client understands */
-	__u8  ocd_blocksize;     /* log2 of the backend filesystem blocksize */
-	__u8  ocd_inodespace;    /* log2 of the per-inode space consumption */
-	__u16 ocd_grant_extent;  /* per-extent grant overhead, in 1K blocks */
-	__u32 ocd_unused;	 /* also fix lustre_swab_connect */
+	__u8  ocd_grant_blkbits; /* log2 of the backend filesystem blocksize */
+	__u8  ocd_grant_inobits; /* log2 of the per-inode space consumption */
+	__u16 ocd_grant_tax_kb;  /* extent grant overhead, in 1K blocks */
+	__u32 ocd_grant_max_blks;/* maximum number of blocks per extent */
 	__u64 ocd_transno;       /* first transno from client to be replayed */
 	__u32 ocd_group;	 /* MDS group on OST */
 	__u32 ocd_cksum_types;   /* supported checksum algorithms */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d38b6bc..d6fd1ea 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -198,6 +198,8 @@ struct client_obd {
 	unsigned long		 cl_dirty_transit;	/* dirty synchronous */
 	unsigned long		 cl_avail_grant;	/* bytes of credit for ost */
 	unsigned long		 cl_lost_grant;		/* lost credits (trunc) */
+	/* grant consumed for dirty pages */
+	unsigned long		 cl_dirty_grant;
 
 	/* since we allocate grant by blocks, we don't know how many grant will
 	 * be used to add a page into cache. As a solution, we reserve maximum
@@ -214,7 +216,12 @@ struct client_obd {
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
 	int		  cl_chunkbits;
-	unsigned int	  cl_extent_tax; /* extent overhead, by bytes */
+	/* extent insertion metadata overhead to be accounted in grant,
+	 * in bytes
+	 */
+	unsigned int	 cl_grant_extent_tax;
+	/* maximum extent size, in number of pages */
+	unsigned int	 cl_max_extent_pages;
 
 	/* keep track of objects that have lois that contain pages which
 	 * have been queued for async brw.  this lock also protects the
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 070a281..ca28caf 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -320,6 +320,7 @@
 #define OBD_FAIL_OSC_CP_ENQ_RACE	 0x410
 #define OBD_FAIL_OSC_NO_GRANT	    0x411
 #define OBD_FAIL_OSC_DELAY_SETTIME	 0x412
+#define OBD_FAIL_OSC_CONNECT_GRANT_PARAM 0x413
 #define OBD_FAIL_OSC_DELAY_IO		 0x414
 
 #define OBD_FAIL_PTLRPC		  0x500
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9f6f061..df5bc0a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -178,6 +178,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		return -ENOMEM;
 	}
 
+	/*
+	 * pass client page size via ocd_grant_blkbits, the server should report
+	 * back its backend blocksize for grant calculation purpose
+	 */
+	data->ocd_grant_blkbits = PAGE_SHIFT;
+
 	/* indicate the features supported by this client */
 	data->ocd_connect_flags = OBD_CONNECT_IBITS    | OBD_CONNECT_NODEVOH  |
 				  OBD_CONNECT_ATTRFID  |
@@ -367,6 +373,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_PINGLESS | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_BULK_MBITS;
 
+	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
+		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
+
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_CKSUM)) {
 		/* OBD_CONNECT_CKSUM should always be set, even if checksums are
 		 * disabled by default, because it can still be enabled on the
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a40ec42..dd88179 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -163,10 +163,12 @@ static void obd_connect_data_seqprint(struct seq_file *m,
 	if (flags & OBD_CONNECT_GRANT_PARAM)
 		seq_printf(m, "       grant_block_size: %d\n"
 			   "       grant_inode_size: %d\n"
-			   "       grant_extent_overhead: %d\n",
-			   ocd->ocd_blocksize,
-			   ocd->ocd_inodespace,
-			   ocd->ocd_grant_extent);
+			   "       grant_max_extent_size: %d\n"
+			   "       grant_extent_tax: %d\n",
+			   1 << ocd->ocd_grant_blkbits,
+			   1 << ocd->ocd_grant_inobits,
+			   ocd->ocd_grant_max_blks << ocd->ocd_grant_blkbits,
+			   ocd->ocd_grant_tax_kb << 10);
 	if (flags & OBD_CONNECT_TRANSNO)
 		seq_printf(m, "       first_transno: %llx\n",
 			   ocd->ocd_transno);
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 64931b9..81adf54 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -326,6 +326,23 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 }
 LUSTRE_RO_ATTR(cur_lost_grant_bytes);
 
+static ssize_t cur_dirty_grant_bytes_show(struct kobject *kobj,
+					  struct attribute *attr,
+					  char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+	struct client_obd *cli = &dev->u.cli;
+	int len;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	len = sprintf(buf, "%lu\n", cli->cl_dirty_grant);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return len;
+}
+LUSTRE_RO_ATTR(cur_dirty_grant_bytes);
+
 static ssize_t grant_shrink_interval_show(struct kobject *kobj,
 					  struct attribute *attr,
 					  char *buf)
@@ -817,6 +834,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_cur_dirty_bytes.attr,
 	&lustre_attr_cur_grant_bytes.attr,
 	&lustre_attr_cur_lost_grant_bytes.attr,
+	&lustre_attr_cur_dirty_grant_bytes.attr,
 	&lustre_attr_destroys_in_flight.attr,
 	&lustre_attr_grant_shrink_interval.attr,
 	&lustre_attr_lockless_truncate.attr,
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 99de672..8d3f501 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -55,13 +55,16 @@ static int osc_refresh_count(const struct lu_env *env,
 static int osc_io_unplug_async(const struct lu_env *env,
 			       struct client_obd *cli, struct osc_object *osc);
 static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
-			   unsigned int lost_grant);
+			   unsigned int lost_grant, unsigned int dirty_grant);
 
 static void osc_extent_tree_dump0(int level, struct osc_object *obj,
 				  const char *func, int line);
 #define osc_extent_tree_dump(lvl, obj) \
 	osc_extent_tree_dump0(lvl, obj, __func__, __LINE__)
 
+static void osc_unreserve_grant(struct client_obd *cli, unsigned int reserved,
+				unsigned int unused);
+
 /** \addtogroup osc
  *  @{
  */
@@ -532,12 +535,13 @@ static void osc_extent_remove(struct osc_extent *ext)
 
 /**
  * This function is used to merge extents to get better performance. It checks
- * if @cur and @victim are contiguous at chunk level.
+ * if @cur and @victim are contiguous at block level.
  */
 static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 			    struct osc_extent *victim)
 {
 	struct osc_object *obj = cur->oe_obj;
+	struct client_obd *cli = osc_cli(obj);
 	pgoff_t chunk_start;
 	pgoff_t chunk_end;
 	int ppc_bits;
@@ -561,11 +565,20 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 	    chunk_end + 1 != victim->oe_start >> ppc_bits)
 		return -ERANGE;
 
+	/*
+	 * overall extent size should not exceed the max supported limit
+	 * reported by the server
+	 */
+	if (cur->oe_end - cur->oe_start + 1 +
+	    victim->oe_end - victim->oe_start + 1 > cli->cl_max_extent_pages)
+		return -ERANGE;
+
 	OSC_EXTENT_DUMP(D_CACHE, victim, "will be merged by %p.\n", cur);
 
 	cur->oe_start = min(cur->oe_start, victim->oe_start);
 	cur->oe_end = max(cur->oe_end, victim->oe_end);
-	cur->oe_grants += victim->oe_grants;
+	/* per-extent tax should be accounted only once for the whole extent */
+	cur->oe_grants += victim->oe_grants - cli->cl_grant_extent_tax;
 	cur->oe_nr_pages += victim->oe_nr_pages;
 	/* only the following bits are needed to merge */
 	cur->oe_urgent |= victim->oe_urgent;
@@ -588,6 +601,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 {
 	struct osc_object *obj = ext->oe_obj;
+	struct client_obd *cli = osc_cli(obj);
 
 	LASSERT(atomic_read(&ext->oe_users) > 0);
 	LASSERT(sanity_check(ext) == 0);
@@ -603,13 +617,19 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 			osc_extent_state_set(ext, OES_TRUNC);
 			ext->oe_trunc_pending = 0;
 		} else {
+			int grant = 0;
+
 			osc_extent_state_set(ext, OES_CACHE);
 			osc_update_pending(obj, OBD_BRW_WRITE,
 					   ext->oe_nr_pages);
 
 			/* try to merge the previous and next extent. */
-			osc_extent_merge(env, ext, prev_extent(ext));
-			osc_extent_merge(env, ext, next_extent(ext));
+			if (!osc_extent_merge(env, ext, prev_extent(ext)))
+				grant += cli->cl_grant_extent_tax;
+			if (!osc_extent_merge(env, ext, next_extent(ext)))
+				grant += cli->cl_grant_extent_tax;
+			if (grant > 0)
+				osc_unreserve_grant(cli, 0, grant);
 
 			if (ext->oe_urgent)
 				list_move_tail(&ext->oe_link,
@@ -617,7 +637,7 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 		}
 		osc_object_unlock(obj);
 
-		osc_io_unplug_async(env, osc_cli(obj), obj);
+		osc_io_unplug_async(env, cli, obj);
 	}
 	osc_extent_put(env, ext);
 }
@@ -690,8 +710,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	}
 
 	/* grants has been allocated by caller */
-	LASSERTF(*grants >= chunksize + cli->cl_extent_tax,
-		 "%u/%u/%u.\n", *grants, chunksize, cli->cl_extent_tax);
+	LASSERTF(*grants >= chunksize + cli->cl_grant_extent_tax,
+		 "%u/%u/%u.\n", *grants, chunksize, cli->cl_grant_extent_tax);
 	LASSERTF((max_end - cur->oe_start) < max_pages, EXTSTR "\n",
 		 EXTPARA(cur));
 
@@ -770,6 +790,13 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			continue;
 		}
 
+		/* check whether maximum extent size will be hit */
+		if ((ext_chk_end - ext_chk_start + 1) << ppc_bits >
+		    cli->cl_max_extent_pages) {
+			ext = next_extent(ext);
+			continue;
+		}
+
 		/* it's required that an extent must be contiguous at chunk
 		 * level so that we know the whole extent is covered by grant
 		 * (the pages in the extent are NOT required to be contiguous).
@@ -801,7 +828,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			 */
 			if (osc_extent_merge(env, ext, next_extent(ext)) == 0)
 				/* we can save extent tax from next extent */
-				*grants += cli->cl_extent_tax;
+				*grants += cli->cl_grant_extent_tax;
 
 			found = osc_extent_hold(ext);
 		}
@@ -822,7 +849,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	} else if (!conflict) {
 		/* create a new extent */
 		EASSERT(osc_extent_is_overlapped(obj, cur) == 0, cur);
-		cur->oe_grants = chunksize + cli->cl_extent_tax;
+		cur->oe_grants = chunksize + cli->cl_grant_extent_tax;
 		LASSERT(*grants >= cur->oe_grants);
 		*grants -= cur->oe_grants;
 
@@ -908,7 +935,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		lost_grant = PAGE_SIZE - count;
 	}
 	if (ext->oe_grants > 0)
-		osc_free_grant(cli, nr_pages, lost_grant);
+		osc_free_grant(cli, nr_pages, lost_grant, ext->oe_grants);
 
 	osc_extent_remove(ext);
 	/* put the refcount for RPC */
@@ -1084,7 +1111,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	osc_object_unlock(obj);
 
 	if (grants > 0 || nr_pages > 0)
-		osc_free_grant(cli, nr_pages, grants);
+		osc_free_grant(cli, nr_pages, grants, grants);
 
 out:
 	cl_io_fini(env, io);
@@ -1207,9 +1234,16 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
 	}
 
 	LASSERT(end_chunk + 1 == chunk);
+
 	/* try to expand this extent to cover @index */
 	end_index = min(ext->oe_max_end, ((chunk + 1) << ppc_bits) - 1);
 
+	/* don't go over the maximum extent size reported by server */
+	if (end_index - ext->oe_start + 1 > cli->cl_max_extent_pages) {
+		rc = -ERANGE;
+		goto out;
+	}
+
 	next = next_extent(ext);
 	if (next && next->oe_start <= end_index) {
 		/* complex mode - overlapped with the next extent,
@@ -1374,13 +1408,15 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 
 #define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
 	struct client_obd *__tmp = (cli);				      \
-	CDEBUG(lvl, "%s: grant { dirty: %lu/%lu dirty_pages: %ld/%lu "	      \
-	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
-	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt "\n",	      \
+	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	\
+	       "dropped: %ld avail: %ld, dirty_grant: %ld, "		\
+	       "reserved: %ld, flight: %d } lru {in list: %ld, "	\
+	       "left: %ld, waiters: %d }" fmt "\n",			\
 	       cli_name(__tmp),						      \
 	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
 	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
+	       __tmp->cl_dirty_grant,					\
 	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
 	       atomic_long_read(&__tmp->cl_lru_in_list),		      \
 	       atomic_long_read(&__tmp->cl_lru_busy),			      \
@@ -1451,8 +1487,10 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	if (unused > reserved) {
 		cli->cl_avail_grant += reserved;
 		cli->cl_lost_grant  += unused - reserved;
+		cli->cl_dirty_grant -= unused - reserved;
 	} else {
 		cli->cl_avail_grant += unused;
+		cli->cl_dirty_grant += reserved - unused;
 	}
 }
 
@@ -1480,14 +1518,17 @@ static void osc_unreserve_grant(struct client_obd *cli,
  *    See filter_grant_check() for details.
  */
 static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
-			   unsigned int lost_grant)
+			   unsigned int lost_grant, unsigned int dirty_grant)
 {
-	unsigned long grant = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
+	unsigned long grant;
+
+	grant = (1 << cli->cl_chunkbits) + cli->cl_grant_extent_tax;
 
 	spin_lock(&cli->cl_loi_list_lock);
 	atomic_long_sub(nr_pages, &obd_dirty_pages);
 	cli->cl_dirty_pages -= nr_pages;
 	cli->cl_lost_grant += lost_grant;
+	cli->cl_dirty_grant -= dirty_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
 		/* borrow some grant from truncate to avoid the case that
 		 * truncate uses up all avail grant
@@ -1497,9 +1538,10 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 	}
 	osc_wake_cache_waiters(cli);
 	spin_unlock(&cli->cl_loi_list_lock);
-	CDEBUG(D_CACHE, "lost %u grant: %lu avail: %lu dirty: %lu\n",
+	CDEBUG(D_CACHE, "lost %u grant: %lu avail: %lu dirty: %lu/%lu\n",
 	       lost_grant, cli->cl_lost_grant,
-	       cli->cl_avail_grant, cli->cl_dirty_pages << PAGE_SHIFT);
+	       cli->cl_avail_grant, cli->cl_dirty_pages << PAGE_SHIFT,
+	       cli->cl_dirty_grant);
 }
 
 /**
@@ -2437,7 +2479,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		/* one chunk plus extent overhead must be enough to write this
 		 * page
 		 */
-		grants = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
+		grants = (1 << cli->cl_chunkbits) + cli->cl_grant_extent_tax;
 		if (ext->oe_end >= index)
 			grants = 0;
 
@@ -2474,7 +2516,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	}
 
 	if (!ext) {
-		tmp = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
+		tmp = (1 << cli->cl_chunkbits) + cli->cl_grant_extent_tax;
 
 		/* try to find new extent to cover this page */
 		LASSERT(!oio->oi_active);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index bcb9b91..ce073b6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -576,7 +576,10 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 
 	oa->o_valid |= bits;
 	spin_lock(&cli->cl_loi_list_lock);
-	oa->o_dirty = cli->cl_dirty_pages << PAGE_SHIFT;
+	if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data, GRANT_PARAM))
+		oa->o_dirty = cli->cl_dirty_grant;
+	else
+		oa->o_dirty = cli->cl_dirty_pages << PAGE_SHIFT;
 	if (unlikely(cli->cl_dirty_pages - cli->cl_dirty_transit >
 		     cli->cl_dirty_max_pages)) {
 		CERROR("dirty %lu - %lu > dirty_max %lu\n",
@@ -601,12 +604,24 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		       cli->cl_dirty_pages, cli->cl_dirty_max_pages);
 		oa->o_undirty = 0;
 	} else {
-		unsigned long max_in_flight;
-
-		max_in_flight = (cli->cl_max_pages_per_rpc << PAGE_SHIFT) *
-				(cli->cl_max_rpcs_in_flight + 1);
-		oa->o_undirty = max(cli->cl_dirty_max_pages << PAGE_SHIFT,
-				    max_in_flight);
+		unsigned long nrpages;
+
+		nrpages = cli->cl_max_pages_per_rpc;
+		nrpages *= cli->cl_max_rpcs_in_flight + 1;
+		nrpages = max(nrpages, cli->cl_dirty_max_pages);
+		oa->o_undirty = nrpages << PAGE_SHIFT;
+		if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data,
+				 GRANT_PARAM)) {
+			int nrextents;
+
+			/*
+			 * take extent tax into account when asking for more
+			 * grant space
+			 */
+			nrextents = (nrpages + cli->cl_max_extent_pages - 1)  /
+				     cli->cl_max_extent_pages;
+			oa->o_undirty += nrextents * cli->cl_grant_extent_tax;
+		}
 	}
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
 	oa->o_dropped = cli->cl_lost_grant;
@@ -811,20 +826,40 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	 * race is tolerable here: if we're evicted, but imp_state already
 	 * left EVICTED state, then cl_dirty_pages must be 0 already.
 	 */
+	cli->cl_avail_grant = ocd->ocd_grant;
 	spin_lock(&cli->cl_loi_list_lock);
-	if (cli->cl_import->imp_state == LUSTRE_IMP_EVICTED)
-		cli->cl_avail_grant = ocd->ocd_grant;
-	else
-		cli->cl_avail_grant = ocd->ocd_grant -
-				      (cli->cl_dirty_pages << PAGE_SHIFT);
-
-	/* determine the appropriate chunk size used by osc_extent. */
-	cli->cl_chunkbits = max_t(int, PAGE_SHIFT, ocd->ocd_blocksize);
+	if (cli->cl_import->imp_state != LUSTRE_IMP_EVICTED) {
+		cli->cl_avail_grant -= cli->cl_reserved_grant;
+		if (OCD_HAS_FLAG(ocd, GRANT_PARAM))
+			cli->cl_avail_grant -= cli->cl_dirty_grant;
+		else
+			cli->cl_avail_grant -= cli->cl_dirty_pages << PAGE_SHIFT;
+	}
+
+	if (OCD_HAS_FLAG(ocd, GRANT_PARAM)) {
+		u64 size;
+
+		/* overhead for each extent insertion */
+		cli->cl_grant_extent_tax = ocd->ocd_grant_tax_kb << 10;
+		/* determine the appropriate chunk size used by osc_extent. */
+		cli->cl_chunkbits = max_t(int, PAGE_SHIFT,
+					  ocd->ocd_grant_blkbits);
+		/* determine maximum extent size, in #pages */
+		size = (u64)ocd->ocd_grant_max_blks << ocd->ocd_grant_blkbits;
+		cli->cl_max_extent_pages = size >> PAGE_SHIFT;
+		if (!cli->cl_max_extent_pages)
+			cli->cl_max_extent_pages = 1;
+	} else {
+		cli->cl_grant_extent_tax = 0;
+		cli->cl_chunkbits = PAGE_SHIFT;
+		cli->cl_max_extent_pages = DT_MAX_BRW_PAGES;
+	}
 	spin_unlock(&cli->cl_loi_list_lock);
 
-	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
+	CDEBUG(D_CACHE,
+	       "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d cl_max_extent_pages: %d\n",
 	       cli_name(cli), cli->cl_avail_grant, cli->cl_lost_grant,
-	       cli->cl_chunkbits);
+	       cli->cl_chunkbits, cli->cl_max_extent_pages);
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_GRANT_SHRINK &&
 	    list_empty(&cli->cl_grant_shrink_list))
@@ -1661,6 +1696,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	int page_count = 0;
 	bool soft_sync = false;
 	bool interrupted = false;
+	int grant = 0;
 	int i;
 	int rc;
 	struct ost_body *body;
@@ -1672,6 +1708,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	list_for_each_entry(ext, ext_list, oe_link) {
 		LASSERT(ext->oe_state == OES_RPC);
 		mem_tight |= ext->oe_memalloc;
+		grant += ext->oe_grants;
 		page_count += ext->oe_nr_pages;
 		if (!obj)
 			obj = ext->oe_obj;
@@ -1732,6 +1769,9 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	crattr->cra_oa = oa;
 	cl_req_attr_set(env, osc2cl(obj), crattr);
 
+	if (cmd == OBD_BRW_WRITE)
+		oa->o_grant_used = grant;
+
 	sort_brw_pages(pga, page_count);
 	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 1, 0);
 	if (rc != 0) {
@@ -2435,12 +2475,15 @@ static int osc_reconnect(const struct lu_env *env,
 	struct client_obd *cli = &obd->u.cli;
 
 	if (data && (data->ocd_connect_flags & OBD_CONNECT_GRANT)) {
-		long lost_grant;
+		long lost_grant, grant;
 
 		spin_lock(&cli->cl_loi_list_lock);
-		data->ocd_grant = (cli->cl_avail_grant +
-				   (cli->cl_dirty_pages << PAGE_SHIFT)) ?:
-				   2 * cli_brw_size(obd);
+		grant = cli->cl_avail_grant + cli->cl_reserved_grant;
+		if (data->ocd_connect_flags & OBD_CONNECT_GRANT_PARAM)
+			grant += cli->cl_dirty_grant;
+		else
+			grant += cli->cl_dirty_pages << PAGE_SHIFT;
+		data->ocd_grant = grant ? : 2 * cli_brw_size(obd);
 		lost_grant = cli->cl_lost_grant;
 		cli->cl_lost_grant = 0;
 		spin_unlock(&cli->cl_loi_list_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 6ac9bb5..0337b33 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1551,8 +1551,8 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 	/* ocd_blocksize and ocd_inodespace don't need to be swabbed because
 	 * they are 8-byte values
 	 */
-	__swab16s(&ocd->ocd_grant_extent);
-	__swab32s(&ocd->ocd_unused);
+	__swab16s(&ocd->ocd_grant_tax_kb);
+	__swab32s(&ocd->ocd_grant_max_blks);
 	__swab64s(&ocd->ocd_transno);
 	__swab32s(&ocd->ocd_group);
 	__swab32s(&ocd->ocd_cksum_types);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index f9394c3..2b3608c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -884,22 +884,22 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_connect_data, ocd_ibits_known));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_ibits_known) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_ibits_known));
-	LASSERTF((int)offsetof(struct obd_connect_data, ocd_blocksize) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, ocd_blocksize));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_blocksize) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_blocksize));
-	LASSERTF((int)offsetof(struct obd_connect_data, ocd_inodespace) == 33, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, ocd_inodespace));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_inodespace) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_inodespace));
-	LASSERTF((int)offsetof(struct obd_connect_data, ocd_grant_extent) == 34, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, ocd_grant_extent));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_grant_extent) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_grant_extent));
-	LASSERTF((int)offsetof(struct obd_connect_data, ocd_unused) == 36, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, ocd_unused));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_unused) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_unused));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_grant_blkbits) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_grant_blkbits));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_grant_blkbits) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_grant_blkbits));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_grant_inobits) == 33, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_grant_inobits));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_grant_inobits) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_grant_inobits));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_grant_tax_kb) == 34, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_grant_tax_kb));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_grant_tax_kb) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_grant_tax_kb));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_grant_max_blks) == 36, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_grant_max_blks));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_grant_max_blks) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_grant_max_blks));
 	LASSERTF((int)offsetof(struct obd_connect_data, ocd_transno) == 40, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_connect_data, ocd_transno));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_transno) == 8, "found %lld\n",
-- 
1.8.3.1
