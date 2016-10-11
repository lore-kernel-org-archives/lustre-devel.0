From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 11 Oct 2016 13:41:16 +0300
Subject: [lustre-devel] [bug report] staging: lustre: fix comparison between
 signed and unsigned
Message-ID: <20161011104116.GA23572@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Dmitry Eremin,

The patch 97cba1302d89: "staging: lustre: fix comparison between
signed and unsigned" from Sep 18, 2016, leads to the following static
checker warning:

	drivers/staging/lustre/lustre/osc/osc_request.c:973 osc_init_grant()
	warn: unsigned 'cli->cl_avail_grant' is never less than zero.

drivers/staging/lustre/lustre/osc/osc_request.c
   955  static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
   956  {
   957          /*
   958           * ocd_grant is the total grant amount we're expect to hold: if we've
   959           * been evicted, it's the new avail_grant amount, cl_dirty_pages will
   960           * drop to 0 as inflight RPCs fail out; otherwise, it's avail_grant +
   961           * dirty.
   962           *
   963           * race is tolerable here: if we're evicted, but imp_state already
   964           * left EVICTED state, then cl_dirty_pages must be 0 already.
   965           */
   966          spin_lock(&cli->cl_loi_list_lock);
   967          if (cli->cl_import->imp_state == LUSTRE_IMP_EVICTED)
   968                  cli->cl_avail_grant = ocd->ocd_grant;
   969          else
   970                  cli->cl_avail_grant = ocd->ocd_grant -
   971                                        (cli->cl_dirty_pages << PAGE_SHIFT);
   972  
   973          if (cli->cl_avail_grant < 0) {

This used to be long but we made it unsigned long.

   974                  CWARN("%s: available grant < 0: avail/ocd/dirty %ld/%u/%ld\n",
   975                        cli->cl_import->imp_obd->obd_name, cli->cl_avail_grant,
   976                        ocd->ocd_grant, cli->cl_dirty_pages << PAGE_SHIFT);
   977                  /* workaround for servers which do not have the patch from
   978                   * LU-2679
   979                   */
   980                  cli->cl_avail_grant = ocd->ocd_grant;
   981          }

regards,
dan carpenter
