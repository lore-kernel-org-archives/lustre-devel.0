From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 8 Feb 2016 11:17:57 +0300
Subject: [lustre-devel] staging/lustre/obdecho: remove userspace LSM
	handling
Message-ID: <20160208081757.GA18514@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello John L. Hammond,

The patch f833ea10c7bb: "staging/lustre/obdecho: remove userspace LSM
handling" from Jan 3, 2016, leads to the following static checker
warning:

	drivers/staging/lustre/lustre/obdecho/echo_client.c:1225 echo_create_object()
	warn: we tested 'oa->o_valid & (1)' before and it was 'true'

drivers/staging/lustre/lustre/obdecho/echo_client.c
  1204  static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
  1205                                struct obdo *oa, struct obd_trans_info *oti)
  1206  {
  1207          struct echo_object     *eco;
  1208          struct echo_client_obd *ec = ed->ed_ec;
  1209          struct lov_stripe_md   *lsm = NULL;
  1210          int                  rc;
  1211          int                  created = 0;
  1212  
  1213          if ((oa->o_valid & OBD_MD_FLID) == 0) { /* no obj id */
  1214                  CERROR("No valid oid\n");
  1215                  return -EINVAL;
  1216          }
  1217  
  1218          rc = echo_alloc_memmd(ed, &lsm);
  1219          if (rc < 0) {
  1220                  CERROR("Cannot allocate md: rc = %d\n", rc);
  1221                  goto failed;
  1222          }
  1223  
  1224          /* setup object ID here */
  1225          if (oa->o_valid & OBD_MD_FLID) {
                    ^^^^^^^^^^^^^^^^^^^^^^^^^

This condition can be removed now because it is always true.

  1226                  LASSERT(oa->o_valid & OBD_MD_FLGROUP);
  1227                  lsm->lsm_oi = oa->o_oi;
  1228          }
  1229  
  1230          if (ostid_id(&lsm->lsm_oi) == 0)
  1231                  ostid_set_id(&lsm->lsm_oi, ++last_object_id);
  1232  
  1233          /* Only echo objects are allowed to be created */
  1234          LASSERT((oa->o_valid & OBD_MD_FLGROUP) &&
  1235                  (ostid_seq(&oa->o_oi) == FID_SEQ_ECHO));
  1236  

regards,
dan carpenter
