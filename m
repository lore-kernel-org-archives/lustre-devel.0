From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 11 Oct 2016 14:35:42 +0300
Subject: [lustre-devel] [bug report] staging: lustre: lmv: try all stripes
 for unknown hash functions
Message-ID: <20161011113542.GA20012@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello wang di,

The patch 893ab7479263: "staging: lustre: lmv: try all stripes for
unknown hash functions" from Aug 16, 2016, leads to the following
static checker warning:

	drivers/staging/lustre/lustre/lmv/lmv_intent.c:397 lmv_intent_lookup()
	error: 'tgt' dereferencing possible ERR_PTR()

drivers/staging/lustre/lustre/lmv/lmv_intent.c
  361                               struct ptlrpc_request **reqp,
   362                               ldlm_blocking_callback cb_blocking,
   363                               __u64 extra_lock_flags)
   364  {
   365          struct lmv_stripe_md *lsm = op_data->op_mea1;
   366          struct obd_device      *obd = exp->exp_obd;
   367          struct lmv_obd   *lmv = &obd->u.lmv;
   368          struct lmv_tgt_desc    *tgt = NULL;
   369          struct mdt_body *body;
   370          int                  rc = 0;
   371  
   372          /*
   373           * If it returns ERR_PTR(-EBADFD) then it is an unknown hash type
   374           * it will try all stripes to locate the object
   375           */

I have read this comment so I assume that this warning is a false
positive.

   376          tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
   377          if (IS_ERR(tgt) && (PTR_ERR(tgt) != -EBADFD))
   378                  return PTR_ERR(tgt);
   379  
   380          /*
   381           * Both migrating dir and unknown hash dir need to try
   382           * all of sub-stripes
   383           */
   384          if (lsm && !lmv_is_known_hash_type(lsm->lsm_md_hash_type)) {

But really, it's pretty ugly to assume that -EBADFD implies that lsm is
non-NULL and lmv_is_known_hash_type() will return false.

   385                  struct lmv_oinfo *oinfo = &lsm->lsm_md_oinfo[0];
   386  
   387                  op_data->op_fid1 = oinfo->lmo_fid;
   388                  op_data->op_mds = oinfo->lmo_mds;
   389                  tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
   390                  if (IS_ERR(tgt))
   391                          return PTR_ERR(tgt);
   392          }
   393  
   394          if (!fid_is_sane(&op_data->op_fid2))
   395                  fid_zero(&op_data->op_fid2);
   396  
   397          CDEBUG(D_INODE, "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u lsm=%p lsm_magic=%x\n",
   398                 PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
   399                 op_data->op_name ? op_data->op_name : "<NULL>",
   400                 tgt->ltd_idx, lsm, !lsm ? -1 : lsm->lsm_md_magic);
   401  
   402          op_data->op_bias &= ~MDS_CROSS_REF;

regards,
dan carpenter
