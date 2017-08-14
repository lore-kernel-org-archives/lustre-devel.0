From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 16:09:34 +0100 (BST)
Subject: [lustre-devel] [bug report] staging: lustre: lov: Ensure
 correct operation for large object sizes
In-Reply-To: <20170801111058.xlmx7tmvmfkyihxh@mwanda>
References: <20170801111058.xlmx7tmvmfkyihxh@mwanda>
Message-ID: <alpine.LFD.2.20.1708141602050.14369@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hello Nathaniel Clark,
> 
> The patch 476f575cf070: "staging: lustre: lov: Ensure correct
> operation for large object sizes" from Jul 26, 2017, leads to the
> following static checker warning:
> 
> 	drivers/staging/lustre/lustre/lov/lov_ea.c:207 lsm_unpackmd_common()
> 	warn: signed overflow undefined. 'min_stripe_maxbytes * stripe_count < min_stripe_maxbytes'
> 
> drivers/staging/lustre/lustre/lov/lov_ea.c
>    148  static int lsm_unpackmd_common(struct lov_obd *lov,
>    149                                 struct lov_stripe_md *lsm,
>    150                                 struct lov_mds_md *lmm,
>    151                                 struct lov_ost_data_v1 *objects)
>    152  {
>    153          loff_t min_stripe_maxbytes = 0;
>                 ^^^^^^
> loff_t is long long.
> 
>    154          unsigned int stripe_count;
>    155          struct lov_oinfo *loi;
>    156          loff_t lov_bytes;
>    157          unsigned int i;
>    158  
>    159          /*
>    160           * This supposes lov_mds_md_v1/v3 first fields are
>    161           * are the same
>    162           */
>    163          lmm_oi_le_to_cpu(&lsm->lsm_oi, &lmm->lmm_oi);
>    164          lsm->lsm_stripe_size = le32_to_cpu(lmm->lmm_stripe_size);
>    165          lsm->lsm_pattern = le32_to_cpu(lmm->lmm_pattern);
>    166          lsm->lsm_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
>    167          lsm->lsm_pool_name[0] = '\0';
>    168  
>    169          stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
>    170  
>    171          for (i = 0; i < stripe_count; i++) {
>    172                  loi = lsm->lsm_oinfo[i];
>    173                  ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
>    174                  loi->loi_ost_idx = le32_to_cpu(objects[i].l_ost_idx);
>    175                  loi->loi_ost_gen = le32_to_cpu(objects[i].l_ost_gen);
>    176                  if (lov_oinfo_is_dummy(loi))
>    177                          continue;
>    178  
>    179                  if (loi->loi_ost_idx >= lov->desc.ld_tgt_count &&
>    180                      !lov2obd(lov)->obd_process_conf) {
>    181                          CERROR("%s: OST index %d more than OST count %d\n",
>    182                                 (char *)lov->desc.ld_uuid.uuid,
>    183                                 loi->loi_ost_idx, lov->desc.ld_tgt_count);
>    184                          lov_dump_lmm_v1(D_WARNING, lmm);
>    185                          return -EINVAL;
>    186                  }
>    187  
>    188                  if (!lov->lov_tgts[loi->loi_ost_idx]) {
>    189                          CERROR("%s: OST index %d missing\n",
>    190                                 (char *)lov->desc.ld_uuid.uuid,
>    191                                 loi->loi_ost_idx);
>    192                          lov_dump_lmm_v1(D_WARNING, lmm);
>    193                          continue;
>    194                  }
>    195  
>    196                  lov_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
>    197                  if (min_stripe_maxbytes == 0 || lov_bytes < min_stripe_maxbytes)
>    198                          min_stripe_maxbytes = lov_bytes;
>    199          }
>    200  
>    201          if (min_stripe_maxbytes == 0)
>    202                  min_stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
>    203  
>    204          stripe_count = lsm->lsm_stripe_count ?: lov->desc.ld_tgt_count;
>    205          lov_bytes = min_stripe_maxbytes * stripe_count;
>                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> This is undefined in C.
> 
>    206  
>    207          if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
>                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> So this might be wrong.
> 
>    208                  lsm->lsm_maxbytes = MAX_LFS_FILESIZE;
>    209          else
>    210                  lsm->lsm_maxbytes = lov_bytes;
>    211  
>    212          return 0;
>    213  }

Dan what exact command did you use to find this bug? We do use smatch to 
find these kinds of issues before patches land but some how we are missing
this class from time to time.

Just to let you know the bug is being tracked under 

https://jira.hpdd.intel.com/browse/LU-9862

We do have a patch as well under going testing and review.
