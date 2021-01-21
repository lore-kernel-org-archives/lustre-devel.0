Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75434C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 373EE23A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 373EE23A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 541E221FED0;
	Thu, 21 Jan 2021 09:17:55 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 912B521FC7A
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:14 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7C053100848F;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7AC7D1B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:54 -0500
Message-Id: <1611249422-556-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/39] lustre: lov: FIEMAP support for PFL
 and FLR file
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

* use the high 16 bits of fe_device to record the absolute stripe
  number from the beginning we are processing, so that continuous call
  can resume from the stripe specified by it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11848
Lustre-commit: 409719608cf0f60 ("LU-11848 lov: FIEMAP support for PFL and FLR file")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40766
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c                | 248 +++++++++++++++++++-----------
 fs/lustre/lov/lov_offset.c                |   8 +-
 fs/lustre/ptlrpc/wiretest.c               |   1 -
 include/uapi/linux/lustre/lustre_fiemap.h |  30 +++-
 4 files changed, 191 insertions(+), 96 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 0762cc5..3fcd342 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1487,21 +1487,34 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 				   int start_stripe, int *stripe_count)
 {
 	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
+	int init_stripe;
 	int last_stripe;
-	u64 obd_start;
-	u64 obd_end;
 	int i, j;
 
+	init_stripe = lov_stripe_number(lsm, index, ext->e_start);
+
 	if (ext->e_end - ext->e_start >
 	    lsme->lsme_stripe_size * lsme->lsme_stripe_count) {
-		last_stripe = (start_stripe < 1 ? lsme->lsme_stripe_count - 1 :
-						  start_stripe - 1);
-		*stripe_count = lsme->lsme_stripe_count;
+		if (init_stripe == start_stripe) {
+			last_stripe = (start_stripe < 1) ?
+				lsme->lsme_stripe_count - 1 : start_stripe - 1;
+			*stripe_count = lsme->lsme_stripe_count;
+		} else if (init_stripe < start_stripe) {
+			last_stripe = (init_stripe < 1) ?
+				lsme->lsme_stripe_count - 1 : init_stripe - 1;
+			*stripe_count = lsme->lsme_stripe_count -
+					(start_stripe - init_stripe);
+		} else {
+			last_stripe = init_stripe - 1;
+			*stripe_count = init_stripe - start_stripe;
+		}
 	} else {
 		for (j = 0, i = start_stripe; j < lsme->lsme_stripe_count;
 		     i = (i + 1) % lsme->lsme_stripe_count, j++) {
-			if (lov_stripe_intersects(lsm, index, i, ext,
-						  &obd_start, &obd_end) == 0)
+			if (!lov_stripe_intersects(lsm, index, i, ext, NULL,
+						   NULL))
+				break;
+			if ((start_stripe != init_stripe) && (i == init_stripe))
 				break;
 		}
 		*stripe_count = j;
@@ -1524,13 +1537,14 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
 					 struct fiemap_extent *lcl_fm_ext,
 					 int ost_index, unsigned int ext_count,
-					 int current_extent)
+					 int current_extent, int abs_stripeno)
 {
 	unsigned int ext;
 	char *to;
 
 	for (ext = 0; ext < ext_count; ext++) {
-		lcl_fm_ext[ext].fe_device = ost_index;
+		set_fe_device_stripenr(&lcl_fm_ext[ext], ost_index,
+				       abs_stripeno);
 		lcl_fm_ext[ext].fe_flags |= FIEMAP_EXTENT_NET;
 	}
 
@@ -1565,26 +1579,14 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 {
 	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
 	u64 local_end = fiemap->fm_extents[0].fe_logical;
-	u64 lun_start, lun_end;
+	u64 lun_end;
 	u64 fm_end_offset;
 	int stripe_no = -1;
-	int i;
 
 	if (!fiemap->fm_extent_count || !fiemap->fm_extents[0].fe_logical)
 		return 0;
 
-	/* Find out stripe_no from ost_index saved in the fe_device */
-	for (i = 0; i < lsme->lsme_stripe_count; i++) {
-		struct lov_oinfo *oinfo = lsme->lsme_oinfo[i];
-
-		if (lov_oinfo_is_dummy(oinfo))
-			continue;
-
-		if (oinfo->loi_ost_idx == fiemap->fm_extents[0].fe_device) {
-			stripe_no = i;
-			break;
-		}
-	}
+	stripe_no = *start_stripe;
 
 	if (stripe_no == -1)
 		return -EINVAL;
@@ -1593,11 +1595,9 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 	 * If we have finished mapping on previous device, shift logical
 	 * offset to start of next device
 	 */
-	if (lov_stripe_intersects(lsm, index, stripe_no, ext,
-				  &lun_start, &lun_end) != 0 &&
+	if (lov_stripe_intersects(lsm, index, stripe_no, ext, NULL, &lun_end) &&
 	    local_end < lun_end) {
 		fm_end_offset = local_end;
-		*start_stripe = stripe_no;
 	} else {
 		/* This is a special value to indicate that caller should
 		 * calculate offset in next stripe.
@@ -1611,16 +1611,16 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 
 struct fiemap_state {
 	struct fiemap		*fs_fm;
-	struct lu_extent	fs_ext;
+	struct lu_extent	fs_ext;		/* current entry extent */
 	u64			fs_length;
-	u64			fs_end_offset;
-	int			fs_cur_extent;
-	int			fs_cnt_need;
+	u64			fs_end_offset;	/* last iteration offset */
+	int			fs_cur_extent;	/* collected exts so far */
+	int			fs_cnt_need;	/* # of extents buf can hold */
 	int			fs_start_stripe;
 	int			fs_last_stripe;
-	bool			fs_device_done;
-	bool			fs_finish_stripe;
-	bool			fs_enough;
+	bool			fs_device_done;	/* enough for this OST */
+	bool			fs_finish_stripe; /* reached fs_last_stripe */
+	bool			fs_enough;	/* enough for this call */
 };
 
 static struct cl_object *lov_find_subobj(const struct lu_env *env,
@@ -1669,17 +1669,17 @@ static struct cl_object *lov_find_subobj(const struct lu_env *env,
 static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 			     struct lov_stripe_md *lsm, struct fiemap *fiemap,
 			     size_t *buflen, struct ll_fiemap_info_key *fmkey,
-			     int index, int stripeno, struct fiemap_state *fs)
+			     int index, int stripe_last, int stripeno,
+			     struct fiemap_state *fs)
 {
 	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
 	struct cl_object *subobj;
 	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
 	struct fiemap_extent *fm_ext = &fs->fs_fm->fm_extents[0];
-	u64 req_fm_len; /* Stores length of required mapping */
+	u64 req_fm_len; /* max requested extent coverage */
 	u64 len_mapped_single_call;
-	u64 lun_start;
-	u64 lun_end;
-	u64 obd_object_end;
+	u64 obd_start;
+	u64 obd_end;
 	unsigned int ext_count;
 	/* EOF for object */
 	bool ost_eof = false;
@@ -1691,24 +1691,24 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 	fs->fs_device_done = false;
 	/* Find out range of mapping on this stripe */
 	if ((lov_stripe_intersects(lsm, index, stripeno, &fs->fs_ext,
-				   &lun_start, &obd_object_end)) == 0)
+				   &obd_start, &obd_end)) == 0)
 		return 0;
 
 	if (lov_oinfo_is_dummy(lsme->lsme_oinfo[stripeno]))
 		return -EIO;
 
 	/* If this is a continuation FIEMAP call and we are on
-	 * starting stripe then lun_start needs to be set to
+	 * starting stripe then obd_start needs to be set to
 	 * end_offset
 	 */
 	if (fs->fs_end_offset != 0 && stripeno == fs->fs_start_stripe)
-		lun_start = fs->fs_end_offset;
+		obd_start = fs->fs_end_offset;
 
-	lun_end = lov_size_to_stripe(lsm, index, fs->fs_ext.e_end, stripeno);
-	if (lun_start == lun_end)
+	if (lov_size_to_stripe(lsm, index, fs->fs_ext.e_end, stripeno) ==
+	    obd_start)
 		return 0;
 
-	req_fm_len = obd_object_end - lun_start + 1;
+	req_fm_len = obd_end - obd_start + 1;
 	fs->fs_fm->fm_length = 0;
 	len_mapped_single_call = 0;
 
@@ -1729,7 +1729,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 						  fs->fs_cur_extent;
 		}
 
-		lun_start += len_mapped_single_call;
+		obd_start += len_mapped_single_call;
 		fs->fs_fm->fm_length = req_fm_len - len_mapped_single_call;
 		req_fm_len = fs->fs_fm->fm_length;
 		/**
@@ -1753,14 +1753,14 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 			fs->fs_fm->fm_flags |= FIEMAP_EXTENT_LAST;
 			fs->fs_fm->fm_mapped_extents = 1;
 
-			fm_ext[0].fe_logical = lun_start;
-			fm_ext[0].fe_length = obd_object_end - lun_start + 1;
+			fm_ext[0].fe_logical = obd_start;
+			fm_ext[0].fe_length = obd_end - obd_start + 1;
 			fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
 
 			goto inactive_tgt;
 		}
 
-		fs->fs_fm->fm_start = lun_start;
+		fs->fs_fm->fm_start = obd_start;
 		fs->fs_fm->fm_flags &= ~FIEMAP_FLAG_DEVICE_ORDER;
 		memcpy(&fmkey->lfik_fiemap, fs->fs_fm, sizeof(*fs->fs_fm));
 		*buflen = fiemap_count_to_size(fs->fs_fm->fm_extent_count);
@@ -1799,7 +1799,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		/* prepare to copy retrived map extents */
 		len_mapped_single_call = fm_ext[ext_count - 1].fe_logical +
 					 fm_ext[ext_count - 1].fe_length -
-					 lun_start;
+					 obd_start;
 
 		/* Have we finished mapping on this device? */
 		if (req_fm_len <= len_mapped_single_call) {
@@ -1821,7 +1821,8 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		}
 
 		fiemap_prepare_and_copy_exts(fiemap, fm_ext, ost_index,
-					     ext_count, fs->fs_cur_extent);
+					     ext_count, fs->fs_cur_extent,
+					     stripe_last + stripeno);
 		fs->fs_cur_extent += ext_count;
 
 		/* Ran out of available extents? */
@@ -1863,12 +1864,17 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	loff_t whole_start;
 	loff_t whole_end;
 	int entry;
-	int start_entry;
+	int start_entry = -1;
 	int end_entry;
 	int cur_stripe = 0;
 	int stripe_count;
 	int rc = 0;
 	struct fiemap_state fs = { NULL };
+	struct lu_extent range;
+	int cur_ext;
+	int stripe_last;
+	int start_stripe = 0;
+	bool resume = false;
 
 	lsm = lov_lsm_addref(cl2lov(obj));
 	if (!lsm) {
@@ -1936,8 +1942,6 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	 */
 	if (fiemap_count_to_size(fiemap->fm_extent_count) > *buflen)
 		fiemap->fm_extent_count = fiemap_size_to_count(*buflen);
-	if (!fiemap->fm_extent_count)
-		fs.fs_cnt_need = 0;
 
 	fs.fs_enough = false;
 	fs.fs_cur_extent = 0;
@@ -1951,73 +1955,142 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		goto out_fm_local;
 	}
 	whole_end = (fiemap->fm_length == OBD_OBJECT_EOF) ?
-		     fmkey->lfik_oa.o_size :
-		     whole_start + fiemap->fm_length - 1;
+		     fmkey->lfik_oa.o_size + 1 :
+		     whole_start + fiemap->fm_length;
 	/**
 	 * If fiemap->fm_length != OBD_OBJECT_EOF but whole_end exceeds file
 	 * size
 	 */
-	if (whole_end > fmkey->lfik_oa.o_size)
-		whole_end = fmkey->lfik_oa.o_size;
+	if (whole_end > fmkey->lfik_oa.o_size + 1)
+		whole_end = fmkey->lfik_oa.o_size + 1;
 
-	start_entry = lov_lsm_entry(lsm, whole_start);
-	end_entry = lov_lsm_entry(lsm, whole_end);
-	if (end_entry == -1)
-		end_entry = lsm->lsm_entry_count - 1;
+	/**
+	 * the high 16bits of fe_device remember which stripe the last
+	 * call has been arrived, we'd continue from there in this call.
+	 */
+	if (fiemap->fm_extent_count && fiemap->fm_extents[0].fe_logical)
+		resume = true;
+	stripe_last = get_fe_stripenr(&fiemap->fm_extents[0]);
+	/**
+	 * stripe_last records stripe number we've been processed in the last
+	 * call
+	 */
+	end_entry = lsm->lsm_entry_count - 1;
+	cur_stripe = 0;
+	for (entry = 0; entry <= end_entry; entry++) {
+		lsme = lsm->lsm_entries[entry];
+		if (cur_stripe + lsme->lsme_stripe_count >= stripe_last) {
+			start_entry = entry;
+			start_stripe = stripe_last - cur_stripe;
+			break;
+		}
+		cur_stripe += lsme->lsme_stripe_count;
+	}
 
-	if (start_entry == -1 || end_entry == -1) {
+	if (start_entry == -1) {
+		CERROR(DFID": FIEMAP does not init start entry, cur_stripe=%d, stripe_last=%d\n",
+		       PFID(lu_object_fid(&obj->co_lu)),
+		       cur_stripe, stripe_last);
 		rc = -EINVAL;
 		goto out_fm_local;
 	}
+	/**
+	 * @start_entry & @start_stripe records the position of fiemap
+	 * resumption @stripe_last keeps recording the absolution position
+	 * we'are processing. @resume indicates we'd honor @start_stripe.
+	 */
+
+	range.e_start = whole_start;
+	range.e_end = whole_end;
 
-	/* TODO: rewrite it with lov_foreach_io_layout() */
 	for (entry = start_entry; entry <= end_entry; entry++) {
+		/* remeber to update stripe_last accordingly */
 		lsme = lsm->lsm_entries[entry];
 
-		if (!lsme_inited(lsme))
-			break;
+		/* FLR could contain component holes between entries */
+		if (!lsme_inited(lsme)) {
+			stripe_last += lsme->lsme_stripe_count;
+			resume = false;
+			continue;
+		}
 
-		if (entry == start_entry)
-			fs.fs_ext.e_start = whole_start;
-		else
+		if (!lu_extent_is_overlapped(&range, &lsme->lsme_extent)) {
+			stripe_last += lsme->lsme_stripe_count;
+			resume = false;
+			continue;
+		}
+
+		/* prepare for a component entry iteration */
+		if (lsme->lsme_extent.e_start > whole_start)
 			fs.fs_ext.e_start = lsme->lsme_extent.e_start;
-		if (entry == end_entry)
+		else
+			fs.fs_ext.e_start = whole_start;
+		if (lsme->lsme_extent.e_end > whole_end)
 			fs.fs_ext.e_end = whole_end;
 		else
-			fs.fs_ext.e_end = lsme->lsme_extent.e_end - 1;
-		fs.fs_length = fs.fs_ext.e_end - fs.fs_ext.e_start + 1;
+			fs.fs_ext.e_end = lsme->lsme_extent.e_end;
 
 		/* Calculate start stripe, last stripe and length of mapping */
-		fs.fs_start_stripe = lov_stripe_number(lsm, entry,
-						       fs.fs_ext.e_start);
+		if (resume) {
+			fs.fs_start_stripe = start_stripe;
+			/* put stripe_last to the first stripe of the comp */
+			stripe_last -= start_stripe;
+			resume = false;
+		} else {
+			fs.fs_start_stripe = lov_stripe_number(lsm, entry,
+							       fs.fs_ext.e_start);
+		}
 		fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, entry,
 							    &fs.fs_ext,
 							    fs.fs_start_stripe,
 							    &stripe_count);
-		fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, entry,
-							     &fs.fs_ext,
-							     &fs.fs_start_stripe);
+		/**
+		 * A new mirror component is under process, reset
+		 * fs.fs_end_offset and then fiemap_for_stripe() starts from
+		 * the overlapping extent, otherwise starts from
+		 * fs.fs_end_offset.
+		 */
+		if (entry > start_entry && lsme->lsme_extent.e_start == 0) {
+			/* new mirror */
+			fs.fs_end_offset = 0;
+		} else {
+			fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap,
+								     lsm, entry,
+								     &fs.fs_ext,
+								     &fs.fs_start_stripe);
+		}
+
 		/* Check each stripe */
 		for (cur_stripe = fs.fs_start_stripe; stripe_count > 0;
 		     --stripe_count,
 		     cur_stripe = (cur_stripe + 1) % lsme->lsme_stripe_count) {
+			/* reset fs_finish_stripe */
+			fs.fs_finish_stripe = false;
 			rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen,
-					       fmkey, entry, cur_stripe, &fs);
+					       fmkey, entry, stripe_last,
+					       cur_stripe, &fs);
 			if (rc < 0)
 				goto out_fm_local;
-			if (fs.fs_enough)
+			if (fs.fs_enough) {
+				stripe_last += cur_stripe;
 				goto finish;
+			}
 			if (fs.fs_finish_stripe)
 				break;
 		} /* for each stripe */
-	} /* for covering layout component */
+		stripe_last += lsme->lsme_stripe_count;
+	} /* for covering layout component entry */
 
-	/*
-	 * We've traversed all components, set @entry to the last component
-	 * entry, it's for the last stripe check.
-	 */
-	entry--;
 finish:
+	if (fs.fs_cur_extent > 0)
+		cur_ext = fs.fs_cur_extent - 1;
+	else
+		cur_ext = 0;
+
+	/* done all the processing */
+	if (entry > end_entry)
+		fiemap->fm_extents[cur_ext].fe_flags |= FIEMAP_EXTENT_LAST;
+
 	/*
 	 * Indicate that we are returning device offsets unless file just has
 	 * single stripe
@@ -2030,13 +2103,6 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	if (!fiemap->fm_extent_count)
 		goto skip_last_device_calc;
 
-	/*
-	 * Check if we have reached the last stripe and whether mapping for that
-	 * stripe is done.
-	 */
-	if ((cur_stripe == fs.fs_last_stripe) && fs.fs_device_done)
-		fiemap->fm_extents[fs.fs_cur_extent - 1].fe_flags |=
-							FIEMAP_EXTENT_LAST;
 skip_last_device_calc:
 	fiemap->fm_mapped_extents = fs.fs_cur_extent;
 out_fm_local:
diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
index b53ce43..ca763af 100644
--- a/fs/lustre/lov/lov_offset.c
+++ b/fs/lustre/lov/lov_offset.c
@@ -227,18 +227,24 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
  * that is contained within the lov extent.  this returns true if the given
  * stripe does intersect with the lov extent.
  *
- * Closed interval [@obd_start, @obd_end] will be returned.
+ * Closed interval [@obd_start, @obd_end] will be returned if caller needs them.
  */
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
 			  struct lu_extent *ext, u64 *obd_start, u64 *obd_end)
 {
 	struct lov_stripe_md_entry *entry = lsm->lsm_entries[index];
 	int start_side, end_side;
+	u64 loc_start, loc_end;
 	u64 start, end;
 
 	if (!lu_extent_is_overlapped(ext, &entry->lsme_extent))
 		return 0;
 
+	if (!obd_start)
+		obd_start = &loc_start;
+	if (!obd_end)
+		obd_end = &loc_end;
+
 	start = max_t(u64, ext->e_start, entry->lsme_extent.e_start);
 	end = min_t(u64, ext->e_end, entry->lsme_extent.e_end);
 	if (end != OBD_OBJECT_EOF)
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index fedb914..a500a87 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -4262,7 +4262,6 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(FIEMAP_EXTENT_UNWRITTEN != 0x00000800);
 	BUILD_BUG_ON(FIEMAP_EXTENT_MERGED != 0x00001000);
 	BUILD_BUG_ON(FIEMAP_EXTENT_SHARED != 0x00002000);
-	BUILD_BUG_ON(FIEMAP_EXTENT_NO_DIRECT != 0x40000000);
 	BUILD_BUG_ON(FIEMAP_EXTENT_NET != 0x80000000);
 
 #ifdef CONFIG_FS_POSIX_ACL
diff --git a/include/uapi/linux/lustre/lustre_fiemap.h b/include/uapi/linux/lustre/lustre_fiemap.h
index 4ae1850..f93e107 100644
--- a/include/uapi/linux/lustre/lustre_fiemap.h
+++ b/include/uapi/linux/lustre/lustre_fiemap.h
@@ -43,9 +43,35 @@
 #include <linux/fiemap.h>
 #include <linux/types.h>
 
-/* XXX: We use fiemap_extent::fe_reserved[0] */
+/**
+ * XXX: We use fiemap_extent::fe_reserved[0], notice the high 16bits of it
+ * is used to locate the stripe number starting from the very beginning to
+ * resume the fiemap call.
+ */
 #define fe_device	fe_reserved[0]
 
+static inline int get_fe_device(struct fiemap_extent *fe)
+{
+	return fe->fe_device & 0xffff;
+}
+static inline void set_fe_device(struct fiemap_extent *fe, int devno)
+{
+	fe->fe_device = (fe->fe_device & 0xffff0000) | (devno & 0xffff);
+}
+static inline int get_fe_stripenr(struct fiemap_extent *fe)
+{
+	return fe->fe_device >> 16;
+}
+static inline void set_fe_stripenr(struct fiemap_extent *fe, int nr)
+{
+	fe->fe_device = (fe->fe_device & 0xffff) | (nr << 16);
+}
+static inline void set_fe_device_stripenr(struct fiemap_extent *fe, int devno,
+					  int nr)
+{
+	fe->fe_device = (nr << 16) | (devno & 0xffff);
+}
+
 static inline __kernel_size_t fiemap_count_to_size(__kernel_size_t extent_count)
 {
 	return sizeof(struct fiemap) + extent_count *
@@ -64,8 +90,6 @@ static inline unsigned int fiemap_size_to_count(__kernel_size_t array_size)
 #undef FIEMAP_FLAGS_COMPAT
 #endif
 
-/* Lustre specific flags - use a high bit, don't conflict with upstream flag */
-#define FIEMAP_EXTENT_NO_DIRECT	 0x40000000 /* Data mapping undefined */
 #define FIEMAP_EXTENT_NET	 0x80000000 /* Data stored remotely.
 					     * Sets NO_DIRECT flag
 					     */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
