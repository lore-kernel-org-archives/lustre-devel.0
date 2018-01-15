From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 15 Jan 2018 12:36:27 +0300
Subject: [lustre-devel] [bug report] staging: lustre: DLC Feature dynamic
 net config
Message-ID: <20180115093627.wwygrvhxbrthb5cx@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Amir Shehata,

The patch 6c9e5a55cb62: "staging: lustre: DLC Feature dynamic net
config" from Feb 15, 2016, leads to the following static checker
warning:

	drivers/staging/lustre/lnet/lnet/api-ni.c:1804 lnet_dyn_add_ni()
	error: dereferencing freed memory 'ni'

drivers/staging/lustre/lnet/lnet/api-ni.c
  1212  static int
  1213  lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
  1214  {
  1215          struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
  1216          int rc = -EINVAL;
  1217          int lnd_type;
  1218          struct lnet_lnd *lnd;
  1219          struct lnet_tx_queue *tq;
  1220          int i;
  1221  
  1222          lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
  1223  
  1224          LASSERT(libcfs_isknown_lnd(lnd_type));
  1225  
  1226          if (lnd_type == CIBLND || lnd_type == OPENIBLND ||
  1227              lnd_type == IIBLND || lnd_type == VIBLND) {
  1228                  CERROR("LND %s obsoleted\n", libcfs_lnd2str(lnd_type));
  1229                  goto failed0;
  1230          }
  1231  
  1232          /* Make sure this new NI is unique. */
  1233          lnet_net_lock(LNET_LOCK_EX);
  1234          rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis);
  1235          lnet_net_unlock(LNET_LOCK_EX);
  1236          if (!rc) {
  1237                  if (lnd_type == LOLND) {
  1238                          lnet_ni_free(ni);
                                ^^^^^^^^^^^^^^^^
The caller is not expecting this to be freed on the success path.

  1239                          return 0;
  1240                  }
  1241  
  1242                  CERROR("Net %s is not unique\n",
  1243                         libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
  1244                  rc = -EEXIST;
  1245                  goto failed0;
  1246          }
  1247  

regards,
dan carpenter
