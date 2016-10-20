From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 20 Oct 2016 15:19:09 +0300
Subject: [lustre-devel] [bug report] staging: lustre: llite: remove
	duplicate fiemap defines
Message-ID: <20161020121908.GA16578@elgon.mountain>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Bobi Jam,

The patch cbd4d4a8e319: "staging: lustre: llite: remove duplicate
fiemap defines" from Oct 2, 2016, leads to the following static
checker warning:

	drivers/staging/lustre/lustre/lov/lov_object.c:1241 lov_object_fiemap()
	warn: signed overflow undefined. 'fm_start + fm_length < fm_start'

drivers/staging/lustre/lustre/lov/lov_object.c
  1102  static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
  1103                               struct ll_fiemap_info_key *fmkey,
  1104                               struct fiemap *fiemap, size_t *buflen)
  1105  {
  1106          struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
  1107          unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
  1108          struct fiemap_extent *lcl_fm_ext;
  1109          struct cl_object *subobj = NULL;
  1110          struct fiemap *fm_local = NULL;
  1111          struct lov_stripe_md *lsm;
  1112          loff_t fm_start;
                       ^^^^^^^^
  1113          loff_t fm_end;
  1114          loff_t fm_length;
                       ^^^^^^^^^^
These used to be u64 types but now they are signed.

  1115          loff_t fm_end_offset;
  1116          int count_local;
  1117          int ost_index = 0;
  1118          int start_stripe;
  1119          int current_extent = 0;
  1120          int rc = 0;
  1121          int last_stripe;
  1122          int cur_stripe = 0;
  1123          int cur_stripe_wrap = 0;
  1124          int stripe_count;
  1125          /* Whether have we collected enough extents */
  1126          bool enough = false;
  1127          /* EOF for object */
  1128          bool ost_eof = false;
  1129          /* done with required mapping for this OST? */
  1130          bool ost_done = false;
  1131  

[ snip ]

  1231                  /*
  1232                   * If this is a continuation FIEMAP call and we are on
  1233                   * starting stripe then lun_start needs to be set to
  1234                   * fm_end_offset
  1235                   */
  1236                  if (fm_end_offset && cur_stripe == start_stripe)
  1237                          lun_start = fm_end_offset;
  1238  
  1239                  if (fm_length != ~0ULL) {
  1240                          /* Handle fm_start + fm_length overflow */
  1241                          if (fm_start + fm_length < fm_start)
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
So, technically, this is undefined behavior now.

  1242                                  fm_length = ~0ULL - fm_start;
  1243                          lun_end = lov_size_to_stripe(lsm, fm_start + fm_length,
  1244                                                       cur_stripe);
  1245                  } else {
  1246                          lun_end = ~0ULL;
  1247                  }

regards,
dan carpenter
