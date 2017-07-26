From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:37:59 -0400
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: lov: refactor
	lov_object_fiemap()
In-Reply-To: <1501083479-23069-1-git-send-email-jsimmons@infradead.org>
References: <1501083479-23069-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501083479-23069-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Add fiemap_for_stripe() to get file map extent from each stripe
device.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8773
Reviewed-on: https://review.whamcloud.com/23461
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c | 441 +++++++++++++------------
 1 file changed, 225 insertions(+), 216 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index b33ed2a..8fc0bcc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1126,6 +1126,190 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 	return fm_end_offset;
 }
 
+struct fiemap_state {
+	struct fiemap	*fs_fm;
+	u64		fs_start;
+	u64		fs_length;
+	u64		fs_end;
+	u64		fs_end_offset;
+	int		fs_cur_extent;
+	int		fs_cnt_need;
+	int		fs_start_stripe;
+	int		fs_last_stripe;
+	bool		fs_device_done;
+	bool		fs_finish;
+	bool		fs_enough;
+};
+
+int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
+		      struct lov_stripe_md *lsm,
+		      struct fiemap *fiemap, size_t *buflen,
+		      struct ll_fiemap_info_key *fmkey, int stripeno,
+		      struct fiemap_state *fs)
+{
+	struct cl_object *subobj;
+	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
+	struct fiemap_extent *fm_ext = &fs->fs_fm->fm_extents[0];
+	u64 req_fm_len; /* Stores length of required mapping */
+	u64 len_mapped_single_call;
+	u64 lun_start;
+	u64 lun_end;
+	u64 obd_object_end;
+	unsigned int ext_count;
+	/* EOF for object */
+	bool ost_eof = false;
+	/* done with required mapping for this OST? */
+	bool ost_done = false;
+	int ost_index;
+	int rc = 0;
+
+	fs->fs_device_done = false;
+	/* Find out range of mapping on this stripe */
+	if ((lov_stripe_intersects(lsm, stripeno, fs->fs_start, fs->fs_end,
+				   &lun_start, &obd_object_end)) == 0)
+		return 0;
+
+	if (lov_oinfo_is_dummy(lsm->lsm_oinfo[stripeno]))
+		return -EIO;
+
+	/* If this is a continuation FIEMAP call and we are on
+	 * starting stripe then lun_start needs to be set to
+	 * end_offset */
+	if (fs->fs_end_offset != 0 && stripeno == fs->fs_start_stripe)
+		lun_start = fs->fs_end_offset;
+
+	lun_end = fs->fs_length;
+	if (lun_end != ~0ULL) {
+		/* Handle fs->fs_start + fs->fs_length overflow */
+		if (fs->fs_start + fs->fs_length < fs->fs_start)
+			fs->fs_length = ~0ULL - fs->fs_start;
+		lun_end = lov_size_to_stripe(lsm, fs->fs_start + fs->fs_length,
+					     stripeno);
+	}
+
+	if (lun_start == lun_end)
+		return 0;
+
+	req_fm_len = obd_object_end - lun_start;
+	fs->fs_fm->fm_length = 0;
+	len_mapped_single_call = 0;
+
+	/* find lobsub object */
+	subobj = lov_find_subobj(env, cl2lov(obj), lsm, stripeno);
+	if (IS_ERR(subobj))
+		return PTR_ERR(subobj);
+	/* If the output buffer is very large and the objects have many
+	 * extents we may need to loop on a single OST repeatedly */
+	do {
+		if (fiemap->fm_extent_count > 0) {
+			/* Don't get too many extents. */
+			if (fs->fs_cur_extent + fs->fs_cnt_need >
+			    fiemap->fm_extent_count)
+				fs->fs_cnt_need = fiemap->fm_extent_count -
+						  fs->fs_cur_extent;
+		}
+
+		lun_start += len_mapped_single_call;
+		fs->fs_fm->fm_length = req_fm_len - len_mapped_single_call;
+		req_fm_len = fs->fs_fm->fm_length;
+		fs->fs_fm->fm_extent_count = fs->fs_enough ?
+					     1 : fs->fs_cnt_need;
+		fs->fs_fm->fm_mapped_extents = 0;
+		fs->fs_fm->fm_flags = fiemap->fm_flags;
+
+		ost_index = lsm->lsm_oinfo[stripeno]->loi_ost_idx;
+
+		if (ost_index < 0 || ost_index >= lov->desc.ld_tgt_count) {
+			rc = -EINVAL;
+			goto obj_put;
+		}
+		/* If OST is inactive, return extent with UNKNOWN flag. */
+		if (!lov->lov_tgts[ost_index]->ltd_active) {
+			fs->fs_fm->fm_flags |= FIEMAP_EXTENT_LAST;
+			fs->fs_fm->fm_mapped_extents = 1;
+
+			fm_ext[0].fe_logical = lun_start;
+			fm_ext[0].fe_length = obd_object_end - lun_start;
+			fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
+
+			goto inactive_tgt;
+		}
+
+		fs->fs_fm->fm_start = lun_start;
+		fs->fs_fm->fm_flags &= ~FIEMAP_FLAG_DEVICE_ORDER;
+		memcpy(&fmkey->lfik_fiemap, fs->fs_fm, sizeof(*fs->fs_fm));
+		*buflen = fiemap_count_to_size(fs->fs_fm->fm_extent_count);
+
+		rc = cl_object_fiemap(env, subobj, fmkey, fs->fs_fm, buflen);
+		if (rc)
+			goto obj_put;
+inactive_tgt:
+		ext_count = fs->fs_fm->fm_mapped_extents;
+		if (ext_count == 0) {
+			ost_done = true;
+			fs->fs_device_done = true;
+			/* If last stripe has hold at the end,
+			 * we need to return */
+			if (stripeno == fs->fs_last_stripe) {
+				fiemap->fm_mapped_extents = 0;
+				fs->fs_finish = true;
+				goto obj_put;
+			}
+			break;
+		} else if (fs->fs_enough) {
+			/*
+			 * We've collected enough extents and there are
+			 * more extents after it.
+			 */
+			fs->fs_finish = true;
+			goto obj_put;
+		}
+
+		/* If we just need num of extents, got to next device */
+		if (fiemap->fm_extent_count == 0) {
+			fs->fs_cur_extent += ext_count;
+			break;
+		}
+
+		/* prepare to copy retrived map extents */
+		len_mapped_single_call = fm_ext[ext_count - 1].fe_logical +
+					 fm_ext[ext_count - 1].fe_length -
+					 lun_start;
+
+		/* Have we finished mapping on this device? */
+		if (req_fm_len <= len_mapped_single_call) {
+			ost_done = true;
+			fs->fs_device_done = true;
+		}
+
+		/* Clear the EXTENT_LAST flag which can be present on
+		 * the last extent */
+		if (fm_ext[ext_count - 1].fe_flags & FIEMAP_EXTENT_LAST)
+			fm_ext[ext_count - 1].fe_flags &= ~FIEMAP_EXTENT_LAST;
+		if (lov_stripe_size(lsm, fm_ext[ext_count - 1].fe_logical +
+					 fm_ext[ext_count - 1].fe_length,
+				    stripeno) >= fmkey->lfik_oa.o_size) {
+			ost_eof = true;
+			fs->fs_device_done = true;
+		}
+
+		fiemap_prepare_and_copy_exts(fiemap, fm_ext, ost_index,
+					     ext_count, fs->fs_cur_extent);
+		fs->fs_cur_extent += ext_count;
+
+		/* Ran out of available extents? */
+		if (fs->fs_cur_extent >= fiemap->fm_extent_count)
+			fs->fs_enough = true;
+	} while (!ost_done && !ost_eof);
+
+	if (stripeno == fs->fs_last_stripe)
+		fs->fs_finish = true;
+obj_put:
+	cl_object_put(env, subobj);
+
+	return rc;
+}
+
 /**
  * Break down the FIEMAP request and send appropriate calls to individual OSTs.
  * This also handles the restarting of FIEMAP calls in case mapping overflows
@@ -1144,31 +1328,13 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 			     struct ll_fiemap_info_key *fmkey,
 			     struct fiemap *fiemap, size_t *buflen)
 {
-	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
 	unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
-	struct fiemap_extent *lcl_fm_ext;
-	struct cl_object *subobj = NULL;
 	struct fiemap *fm_local = NULL;
 	struct lov_stripe_md *lsm;
-	u64 fm_start;
-	u64 fm_end;
-	u64 fm_length;
-	u64 fm_end_offset;
-	int count_local;
-	int ost_index = 0;
-	int start_stripe;
-	int current_extent = 0;
 	int rc = 0;
-	int last_stripe;
-	int cur_stripe = 0;
-	int cur_stripe_wrap = 0;
+	int cur_stripe;
 	int stripe_count;
-	/* Whether have we collected enough extents */
-	bool enough = false;
-	/* EOF for object */
-	bool ost_eof = false;
-	/* done with required mapping for this OST? */
-	bool ost_done = false;
+	struct fiemap_state fs = { 0 };
 
 	lsm = lov_lsm_addref(cl2lov(obj));
 	if (!lsm)
@@ -1215,28 +1381,37 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		rc = -ENOMEM;
 		goto out;
 	}
-	lcl_fm_ext = &fm_local->fm_extents[0];
-	count_local = fiemap_size_to_count(buffer_size);
+	fs.fs_fm = fm_local;
+	fs.fs_cnt_need = fiemap_size_to_count(buffer_size);
 
-	fm_start = fiemap->fm_start;
-	fm_length = fiemap->fm_length;
+	fs.fs_start = fiemap->fm_start;
+	/* fs_start is beyond the end of the file */
+	if (fs.fs_start > fmkey->lfik_oa.o_size) {
+		rc = -EINVAL;
+		goto out;
+	}
 	/* Calculate start stripe, last stripe and length of mapping */
-	start_stripe = lov_stripe_number(lsm, fm_start);
-	fm_end = (fm_length == ~0ULL) ? fmkey->lfik_oa.o_size :
-					fm_start + fm_length - 1;
-	/* If fm_length != ~0ULL but fm_start_fm_length-1 exceeds file size */
-	if (fm_end > fmkey->lfik_oa.o_size)
-		fm_end = fmkey->lfik_oa.o_size;
-
-	last_stripe = fiemap_calc_last_stripe(lsm, fm_start, fm_end,
-					      start_stripe, &stripe_count);
-	fm_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fm_start, fm_end,
-						  &start_stripe);
-	if (fm_end_offset == -EINVAL) {
+	fs.fs_start_stripe = lov_stripe_number(lsm, fs.fs_start);
+	fs.fs_end = (fs.fs_length == ~0ULL) ? fmkey->lfik_oa.o_size :
+					      fs.fs_start + fs.fs_length - 1;
+	/* If fs_length != ~0ULL but fs_start+fs_length-1 exceeds file size */
+	if (fs.fs_end > fmkey->lfik_oa.o_size) {
+		fs.fs_end = fmkey->lfik_oa.o_size;
+		fs.fs_length = fs.fs_end - fs.fs_start;
+	}
+
+	fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, fs.fs_start, fs.fs_end,
+						    fs.fs_start_stripe,
+						    &stripe_count);
+	fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fs.fs_start,
+						     fs.fs_end,
+						     &fs.fs_start_stripe);
+	if (fs.fs_end_offset == -EINVAL) {
 		rc = -EINVAL;
 		goto out;
 	}
 
+
 	/**
 	 * Requested extent count exceeds the fiemap buffer size, shrink our
 	 * ambition.
@@ -1244,186 +1419,23 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	if (fiemap_count_to_size(fiemap->fm_extent_count) > *buflen)
 		fiemap->fm_extent_count = fiemap_size_to_count(*buflen);
 	if (!fiemap->fm_extent_count)
-		count_local = 0;
+		fs.fs_cnt_need = 0;
+
+	fs.fs_finish = false;
+	fs.fs_enough = false;
+	fs.fs_cur_extent = 0;
 
 	/* Check each stripe */
-	for (cur_stripe = start_stripe; stripe_count > 0;
+	for (cur_stripe = fs.fs_start_stripe; stripe_count > 0;
 	     --stripe_count,
 	     cur_stripe = (cur_stripe + 1) % lsm->lsm_stripe_count) {
-		u64 req_fm_len; /* Stores length of required mapping */
-		u64 len_mapped_single_call;
-		u64 lun_start;
-		u64 lun_end;
-		u64 obd_object_end;
-		unsigned int ext_count;
-
-		cur_stripe_wrap = cur_stripe;
-
-		/* Find out range of mapping on this stripe */
-		if (!(lov_stripe_intersects(lsm, cur_stripe, fm_start, fm_end,
-					    &lun_start, &obd_object_end)))
-			continue;
-
-		if (lov_oinfo_is_dummy(lsm->lsm_oinfo[cur_stripe])) {
-			rc = -EIO;
-			goto out;
-		}
-
-		/*
-		 * If this is a continuation FIEMAP call and we are on
-		 * starting stripe then lun_start needs to be set to
-		 * fm_end_offset
-		 */
-		if (fm_end_offset && cur_stripe == start_stripe)
-			lun_start = fm_end_offset;
-
-		if (fm_length != ~0ULL) {
-			/* Handle fm_start + fm_length overflow */
-			if (fm_start + fm_length < fm_start)
-				fm_length = ~0ULL - fm_start;
-			lun_end = lov_size_to_stripe(lsm, fm_start + fm_length,
-						     cur_stripe);
-		} else {
-			lun_end = ~0ULL;
-		}
-
-		if (lun_start == lun_end)
-			continue;
-
-		req_fm_len = obd_object_end - lun_start;
-		fm_local->fm_length = 0;
-		len_mapped_single_call = 0;
-
-		/* find lobsub object */
-		subobj = lov_find_subobj(env, cl2lov(obj), lsm,
-					 cur_stripe);
-		if (IS_ERR(subobj)) {
-			rc = PTR_ERR(subobj);
+		rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen, fmkey,
+				       cur_stripe, &fs);
+		if (rc < 0)
 			goto out;
-		}
-		/*
-		 * If the output buffer is very large and the objects have many
-		 * extents we may need to loop on a single OST repeatedly
-		 */
-		ost_eof = false;
-		ost_done = false;
-		do {
-			if (fiemap->fm_extent_count > 0) {
-				/* Don't get too many extents. */
-				if (current_extent + count_local >
-				    fiemap->fm_extent_count)
-					count_local = fiemap->fm_extent_count -
-						      current_extent;
-			}
-
-			lun_start += len_mapped_single_call;
-			fm_local->fm_length = req_fm_len -
-					      len_mapped_single_call;
-			req_fm_len = fm_local->fm_length;
-			fm_local->fm_extent_count = enough ? 1 : count_local;
-			fm_local->fm_mapped_extents = 0;
-			fm_local->fm_flags = fiemap->fm_flags;
-
-			ost_index = lsm->lsm_oinfo[cur_stripe]->loi_ost_idx;
-
-			if (ost_index < 0 ||
-			    ost_index >= lov->desc.ld_tgt_count) {
-				rc = -EINVAL;
-				goto obj_put;
-			}
-			/*
-			 * If OST is inactive, return extent with UNKNOWN
-			 * flag.
-			 */
-			if (!lov->lov_tgts[ost_index]->ltd_active) {
-				fm_local->fm_flags |= FIEMAP_EXTENT_LAST;
-				fm_local->fm_mapped_extents = 1;
-
-				lcl_fm_ext[0].fe_logical = lun_start;
-				lcl_fm_ext[0].fe_length = obd_object_end -
-							  lun_start;
-				lcl_fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
-
-				goto inactive_tgt;
-			}
-
-			fm_local->fm_start = lun_start;
-			fm_local->fm_flags &= ~FIEMAP_FLAG_DEVICE_ORDER;
-			memcpy(&fmkey->lfik_fiemap, fm_local, sizeof(*fm_local));
-			*buflen = fiemap_count_to_size(fm_local->fm_extent_count);
-
-			rc = cl_object_fiemap(env, subobj, fmkey, fm_local,
-					      buflen);
-			if (rc)
-				goto obj_put;
-inactive_tgt:
-			ext_count = fm_local->fm_mapped_extents;
-			if (!ext_count) {
-				ost_done = true;
-				/*
-				 * If last stripe has hold at the end,
-				 * we need to return
-				 */
-				if (cur_stripe_wrap == last_stripe) {
-					fiemap->fm_mapped_extents = 0;
-					goto finish;
-				}
-				break;
-			} else if (enough) {
-				/*
-				 * We've collected enough extents and there are
-				 * more extents after it.
-				 */
-				goto finish;
-			}
-
-			/* If we just need num of extents, got to next device */
-			if (!fiemap->fm_extent_count) {
-				current_extent += ext_count;
-				break;
-			}
-
-			/* prepare to copy retrived map extents */
-			len_mapped_single_call =
-				lcl_fm_ext[ext_count - 1].fe_logical -
-				lun_start + lcl_fm_ext[ext_count - 1].fe_length;
-
-			/* Have we finished mapping on this device? */
-			if (req_fm_len <= len_mapped_single_call)
-				ost_done = true;
-
-			/*
-			 * Clear the EXTENT_LAST flag which can be present on
-			 * the last extent
-			 */
-			if (lcl_fm_ext[ext_count - 1].fe_flags &
-			    FIEMAP_EXTENT_LAST)
-				lcl_fm_ext[ext_count - 1].fe_flags &=
-					~FIEMAP_EXTENT_LAST;
-
-			if (lov_stripe_size(lsm,
-					    lcl_fm_ext[ext_count - 1].fe_logical +
-					    lcl_fm_ext[ext_count - 1].fe_length,
-					    cur_stripe) >= fmkey->lfik_oa.o_size)
-				ost_eof = true;
-
-			fiemap_prepare_and_copy_exts(fiemap, lcl_fm_ext,
-						     ost_index, ext_count,
-						     current_extent);
-			current_extent += ext_count;
-
-			/* Ran out of available extents? */
-			if (current_extent >= fiemap->fm_extent_count)
-				enough = true;
-		} while (!ost_done && !ost_eof);
-
-		cl_object_put(env, subobj);
-		subobj = NULL;
-
-		if (cur_stripe_wrap == last_stripe)
-			goto finish;
+		if (fs.fs_finish)
+			break;
 	} /* for each stripe */
-finish:
 	/*
 	 * Indicate that we are returning device offsets unless file just has
 	 * single stripe
@@ -1438,14 +1450,11 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	 * Check if we have reached the last stripe and whether mapping for that
 	 * stripe is done.
 	 */
-	if ((cur_stripe_wrap == last_stripe) && (ost_done || ost_eof))
-		fiemap->fm_extents[current_extent - 1].fe_flags |=
+	if ((cur_stripe == fs.fs_last_stripe) && fs.fs_device_done)
+		fiemap->fm_extents[fs.fs_cur_extent - 1].fe_flags |=
 							FIEMAP_EXTENT_LAST;
 skip_last_device_calc:
-	fiemap->fm_mapped_extents = current_extent;
-obj_put:
-	if (subobj)
-		cl_object_put(env, subobj);
+	fiemap->fm_mapped_extents = fs.fs_cur_extent;
 out:
 	kvfree(fm_local);
 	lov_lsm_put(lsm);
-- 
1.8.3.1
