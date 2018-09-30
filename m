From: James Simmons <jsimmons@infradead.org>
Date: Sun, 30 Sep 2018 03:19:36 +0100 (BST)
Subject: [lustre-devel] [PATCH 01/25] lustre: lnet: remove ni from
 lnet_finalize
In-Reply-To: <875zyrizgr.fsf@notabene.neil.brown.name>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
 <1537930097-11624-2-git-send-email-jsimmons@infradead.org>
 <875zyrizgr.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1809300318090.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> On Tue, Sep 25 2018, James Simmons wrote:
> 
> > From: Sergey Cheremencev <c17829@cray.com>
> >
> > Remove ni from lnet_finalize and kiblnd_txlist_done
> > input arguments. Also small code cleanup by introducing
> > ibprm_cookie to avoid checkpatch issues.
> 
> What checkpatch issues are avoided ??

more than 80 character. The LND drivers tend to be bad at that.

> Thanks,
> NeilBrown
> 
> >
> > Signed-off-by: Sergey Cheremencev <c17829@cray.com>
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9094
> > Seagate-bug-id: MRP-4056
> > Reviewed-on: https://review.whamcloud.com/25375
> > Reviewed-by: Doug Oucharek <dougso@me.com>
> > Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  .../staging/lustre/include/linux/lnet/lib-lnet.h   |  2 +-
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  3 +-
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 65 ++++++++++------------
> >  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  3 +-
> >  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  4 +-
> >  drivers/staging/lustre/lnet/lnet/lib-move.c        | 20 +++----
> >  drivers/staging/lustre/lnet/lnet/lib-msg.c         |  2 +-
> >  drivers/staging/lustre/lnet/lnet/lo.c              |  4 +-
> >  drivers/staging/lustre/lnet/lnet/net_fault.c       |  2 +-
> >  10 files changed, 50 insertions(+), 57 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> > index aedc88c..53cbf6d 100644
> > --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> > +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> > @@ -537,7 +537,7 @@ struct lnet_msg *lnet_create_reply_msg(struct lnet_ni *ni,
> >  void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
> >  			    unsigned int len);
> >  
> > -void lnet_finalize(struct lnet_ni *ni, struct lnet_msg *msg, int rc);
> > +void lnet_finalize(struct lnet_msg *msg, int rc);
> >  
> >  void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
> >  		       unsigned int nob);
> > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> > index 75a7e96..b3a4344 100644
> > --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> > +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> > @@ -521,7 +521,7 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
> >  
> >  	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
> >  
> > -	kiblnd_txlist_done(ni, &zombies, -EIO);
> > +	kiblnd_txlist_done(&zombies, -EIO);
> >  
> >  	return rc;
> >  }
> > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> > index b1851b5..a3d89ec 100644
> > --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> > +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> > @@ -1034,8 +1034,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
> >  void kiblnd_close_conn_locked(struct kib_conn *conn, int error);
> >  
> >  void kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid);
> > -void kiblnd_txlist_done(struct lnet_ni *ni, struct list_head *txlist,
> > -			int status);
> > +void kiblnd_txlist_done(struct list_head *txlist, int status);
> >  
> >  void kiblnd_qp_event(struct ib_event *event, void *arg);
> >  void kiblnd_cq_event(struct ib_event *event, void *arg);
> > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> > index cb752dc..debed17 100644
> > --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> > +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> > @@ -54,14 +54,12 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
> >  static void kiblnd_check_sends_locked(struct kib_conn *conn);
> >  
> >  static void
> > -kiblnd_tx_done(struct lnet_ni *ni, struct kib_tx *tx)
> > +kiblnd_tx_done(struct kib_tx *tx)
> >  {
> >  	struct lnet_msg *lntmsg[2];
> > -	struct kib_net *net = ni->ni_data;
> >  	int rc;
> >  	int i;
> >  
> > -	LASSERT(net);
> >  	LASSERT(!in_interrupt());
> >  	LASSERT(!tx->tx_queued);     /* mustn't be queued for sending */
> >  	LASSERT(!tx->tx_sending);    /* mustn't be awaiting sent callback */
> > @@ -76,8 +74,6 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
> >  	rc = tx->tx_status;
> >  
> >  	if (tx->tx_conn) {
> > -		LASSERT(ni == tx->tx_conn->ibc_peer->ibp_ni);
> > -
> >  		kiblnd_conn_decref(tx->tx_conn);
> >  		tx->tx_conn = NULL;
> >  	}
> > @@ -92,12 +88,12 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
> >  		if (!lntmsg[i])
> >  			continue;
> >  
> > -		lnet_finalize(ni, lntmsg[i], rc);
> > +		lnet_finalize(lntmsg[i], rc);
> >  	}
> >  }
> >  
> >  void
> > -kiblnd_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int status)
> > +kiblnd_txlist_done(struct list_head *txlist, int status)
> >  {
> >  	struct kib_tx *tx;
> >  
> > @@ -108,7 +104,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
> >  		/* complete now */
> >  		tx->tx_waiting = 0;
> >  		tx->tx_status = status;
> > -		kiblnd_tx_done(ni, tx);
> > +		kiblnd_tx_done(tx);
> >  	}
> >  }
> >  
> > @@ -281,7 +277,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
> >  	spin_unlock(&conn->ibc_lock);
> >  
> >  	if (idle)
> > -		kiblnd_tx_done(ni, tx);
> > +		kiblnd_tx_done(tx);
> >  }
> >  
> >  static void
> > @@ -794,7 +790,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
> >  		 * posted NOOPs complete
> >  		 */
> >  		spin_unlock(&conn->ibc_lock);
> > -		kiblnd_tx_done(peer_ni->ibp_ni, tx);
> > +		kiblnd_tx_done(tx);
> >  		spin_lock(&conn->ibc_lock);
> >  		CDEBUG(D_NET, "%s(%d): redundant or enough NOOP\n",
> >  		       libcfs_nid2str(peer_ni->ibp_nid),
> > @@ -888,7 +884,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
> >  	kiblnd_close_conn(conn, rc);
> >  
> >  	if (done)
> > -		kiblnd_tx_done(peer_ni->ibp_ni, tx);
> > +		kiblnd_tx_done(tx);
> >  
> >  	spin_lock(&conn->ibc_lock);
> >  
> > @@ -1007,7 +1003,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
> >  	spin_unlock(&conn->ibc_lock);
> >  
> >  	if (idle)
> > -		kiblnd_tx_done(conn->ibc_peer->ibp_ni, tx);
> > +		kiblnd_tx_done(tx);
> >  }
> >  
> >  static void
> > @@ -1343,7 +1339,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  
> >  	CWARN("Abort reconnection of %s: %s\n",
> >  	      libcfs_nid2str(peer_ni->ibp_nid), reason);
> > -	kiblnd_txlist_done(peer_ni->ibp_ni, &txs, -ECONNABORTED);
> > +	kiblnd_txlist_done(&txs, -ECONNABORTED);
> >  	return false;
> >  }
> >  
> > @@ -1421,7 +1417,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		if (tx) {
> >  			tx->tx_status = -EHOSTUNREACH;
> >  			tx->tx_waiting = 0;
> > -			kiblnd_tx_done(ni, tx);
> > +			kiblnd_tx_done(tx);
> >  		}
> >  		return;
> >  	}
> > @@ -1557,7 +1553,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		if (rc) {
> >  			CERROR("Can't setup GET sink for %s: %d\n",
> >  			       libcfs_nid2str(target.nid), rc);
> > -			kiblnd_tx_done(ni, tx);
> > +			kiblnd_tx_done(tx);
> >  			return -EIO;
> >  		}
> >  
> > @@ -1571,7 +1567,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		if (!tx->tx_lntmsg[1]) {
> >  			CERROR("Can't create reply for GET -> %s\n",
> >  			       libcfs_nid2str(target.nid));
> > -			kiblnd_tx_done(ni, tx);
> > +			kiblnd_tx_done(tx);
> >  			return -EIO;
> >  		}
> >  
> > @@ -1606,7 +1602,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		if (rc) {
> >  			CERROR("Can't setup PUT src for %s: %d\n",
> >  			       libcfs_nid2str(target.nid), rc);
> > -			kiblnd_tx_done(ni, tx);
> > +			kiblnd_tx_done(tx);
> >  			return -EIO;
> >  		}
> >  
> > @@ -1697,7 +1693,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  
> >  	if (!nob) {
> >  		/* No RDMA: local completion may happen now! */
> > -		lnet_finalize(ni, lntmsg, 0);
> > +		lnet_finalize(lntmsg, 0);
> >  	} else {
> >  		/* RDMA: lnet_finalize(lntmsg) when it completes */
> >  		tx->tx_lntmsg[0] = lntmsg;
> > @@ -1707,9 +1703,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  	return;
> >  
> >   failed_1:
> > -	kiblnd_tx_done(ni, tx);
> > +	kiblnd_tx_done(tx);
> >   failed_0:
> > -	lnet_finalize(ni, lntmsg, -EIO);
> > +	lnet_finalize(lntmsg, -EIO);
> >  }
> >  
> >  int
> > @@ -1722,6 +1718,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  	struct kib_tx *tx;
> >  	int nob;
> >  	int post_credit = IBLND_POSTRX_PEER_CREDIT;
> > +	u64 ibprm_cookie;
> >  	int rc = 0;
> >  
> >  	LASSERT(iov_iter_count(to) <= rlen);
> > @@ -1750,17 +1747,18 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		}
> >  
> >  		rc = 0;
> > -		lnet_finalize(ni, lntmsg, 0);
> > +		lnet_finalize(lntmsg, 0);
> >  		break;
> >  
> >  	case IBLND_MSG_PUT_REQ: {
> > +		u64 ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
> >  		struct kib_msg	*txmsg;
> >  		struct kib_rdma_desc *rd;
> >  
> >  		if (!iov_iter_count(to)) {
> > -			lnet_finalize(ni, lntmsg, 0);
> > -			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK, 0,
> > -					       rxmsg->ibm_u.putreq.ibprm_cookie);
> > +			lnet_finalize(lntmsg, 0);
> > +			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK,
> > +					       0, ibprm_cookie);
> >  			break;
> >  		}
> >  
> > @@ -1788,15 +1786,15 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		if (rc) {
> >  			CERROR("Can't setup PUT sink for %s: %d\n",
> >  			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
> > -			kiblnd_tx_done(ni, tx);
> > +			kiblnd_tx_done(tx);
> >  			/* tell peer_ni it's over */
> > -			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK, rc,
> > -					       rxmsg->ibm_u.putreq.ibprm_cookie);
> > +			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK,
> > +					       rc, ibprm_cookie);
> >  			break;
> >  		}
> >  
> >  		nob = offsetof(struct kib_putack_msg, ibpam_rd.rd_frags[rd->rd_nfrags]);
> > -		txmsg->ibm_u.putack.ibpam_src_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
> > +		txmsg->ibm_u.putack.ibpam_src_cookie = ibprm_cookie;
> >  		txmsg->ibm_u.putack.ibpam_dst_cookie = tx->tx_cookie;
> >  
> >  		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_ACK, nob);
> > @@ -1817,8 +1815,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  		} else {
> >  			/* GET didn't match anything */
> >  			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_GET_DONE,
> > -					       -ENODATA,
> > -					       rxmsg->ibm_u.get.ibgm_cookie);
> > +					       -ENODATA, ibprm_cookie);
> >  		}
> >  		break;
> >  	}
> > @@ -2016,7 +2013,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  
> >  	spin_unlock(&conn->ibc_lock);
> >  
> > -	kiblnd_txlist_done(conn->ibc_peer->ibp_ni, &zombies, -ECONNABORTED);
> > +	kiblnd_txlist_done(&zombies, -ECONNABORTED);
> >  }
> >  
> >  static void
> > @@ -2098,7 +2095,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  	CNETERR("Deleting messages for %s: connection failed\n",
> >  		libcfs_nid2str(peer_ni->ibp_nid));
> >  
> > -	kiblnd_txlist_done(peer_ni->ibp_ni, &zombies, -EHOSTUNREACH);
> > +	kiblnd_txlist_done(&zombies, -EHOSTUNREACH);
> >  }
> >  
> >  static void
> > @@ -2170,13 +2167,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> >  
> >  	if (!kiblnd_peer_active(peer_ni) ||	/* peer_ni has been deleted */
> >  	    conn->ibc_comms_error) {       /* error has happened already */
> > -		struct lnet_ni *ni = peer_ni->ibp_ni;
> > -
> >  		/* start to shut down connection */
> >  		kiblnd_close_conn_locked(conn, -ECONNABORTED);
> >  		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
> >  
> > -		kiblnd_txlist_done(ni, &txs, -ECONNABORTED);
> > +		kiblnd_txlist_done(&txs, -ECONNABORTED);
> >  
> >  		return;
> >  	}
> > diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> > index 534ba84..9b9cc87 100644
> > --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> > +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> > @@ -1653,8 +1653,7 @@ struct ksock_peer *
> >  		       &conn->ksnc_ipaddr, conn->ksnc_port,
> >  		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
> >  		       ktime_get_seconds() - last_rcv);
> > -		lnet_finalize(conn->ksnc_peer->ksnp_ni,
> > -			      conn->ksnc_cookie, -EIO);
> > +		lnet_finalize(conn->ksnc_cookie, -EIO);
> >  		break;
> >  	case SOCKNAL_RX_LNET_HEADER:
> >  		if (conn->ksnc_rx_started)
> > diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> > index 1bf0170..2e99a17 100644
> > --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> > +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> > @@ -343,7 +343,7 @@ struct ksock_tx *
> >  
> >  	ksocknal_free_tx(tx);
> >  	if (lnetmsg) /* KSOCK_MSG_NOOP go without lnetmsg */
> > -		lnet_finalize(ni, lnetmsg, rc);
> > +		lnet_finalize(lnetmsg, rc);
> >  }
> >  
> >  void
> > @@ -1226,7 +1226,7 @@ struct ksock_route *
> >  					le64_to_cpu(lhdr->src_nid) != id->nid);
> >  		}
> >  
> > -		lnet_finalize(conn->ksnc_peer->ksnp_ni, conn->ksnc_cookie, rc);
> > +		lnet_finalize(conn->ksnc_cookie, rc);
> >  
> >  		if (rc) {
> >  			ksocknal_new_packet(conn, 0);
> > diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> > index d39331f..a213387 100644
> > --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> > +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> > @@ -408,7 +408,7 @@
> >  	}
> >  	rc = ni->ni_net->net_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
> >  	if (rc < 0)
> > -		lnet_finalize(ni, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  }
> >  
> >  static void
> > @@ -462,7 +462,7 @@
> >  
> >  	rc = ni->ni_net->net_lnd->lnd_send(ni, priv, msg);
> >  	if (rc < 0)
> > -		lnet_finalize(ni, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  }
> >  
> >  static int
> > @@ -637,7 +637,7 @@
> >  		CNETERR("Dropping message for %s: peer not alive\n",
> >  			libcfs_id2str(msg->msg_target));
> >  		if (do_send)
> > -			lnet_finalize(ni, msg, -EHOSTUNREACH);
> > +			lnet_finalize(msg, -EHOSTUNREACH);
> >  
> >  		lnet_net_lock(cpt);
> >  		return -EHOSTUNREACH;
> > @@ -650,7 +650,7 @@
> >  		CNETERR("Aborting message for %s: LNetM[DE]Unlink() already called on the MD/ME.\n",
> >  			libcfs_id2str(msg->msg_target));
> >  		if (do_send)
> > -			lnet_finalize(ni, msg, -ECANCELED);
> > +			lnet_finalize(msg, -ECANCELED);
> >  
> >  		lnet_net_lock(cpt);
> >  		return -ECANCELED;
> > @@ -915,7 +915,7 @@
> >  		lnet_ni_recv(msg->msg_rxni, msg->msg_private, NULL,
> >  			     0, 0, 0, msg->msg_hdr.payload_length);
> >  		list_del_init(&msg->msg_list);
> > -		lnet_finalize(NULL, msg, -ECANCELED);
> > +		lnet_finalize(msg, -ECANCELED);
> >  	}
> >  
> >  	lnet_net_lock(cpt);
> > @@ -1914,7 +1914,7 @@
> >  		       libcfs_nid2str(ni->ni_nid),
> >  		       libcfs_id2str(info.mi_id), rc);
> >  
> > -		lnet_finalize(ni, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  	}
> >  
> >  	return 0;
> > @@ -2402,7 +2402,7 @@
> >  
> >   free_drop:
> >  	LASSERT(!msg->msg_md);
> > -	lnet_finalize(ni, msg, rc);
> > +	lnet_finalize(msg, rc);
> >  
> >   drop:
> >  	lnet_drop_message(ni, cpt, private, payload_length);
> > @@ -2447,7 +2447,7 @@
> >  		 * but we still should give error code so lnet_msg_decommit()
> >  		 * can skip counters operations and other checks.
> >  		 */
> > -		lnet_finalize(msg->msg_rxni, msg, -ENOENT);
> > +		lnet_finalize(msg, -ENOENT);
> >  	}
> >  }
> >  
> > @@ -2605,7 +2605,7 @@
> >  	if (rc) {
> >  		CNETERR("Error sending PUT to %s: %d\n",
> >  			libcfs_id2str(target), rc);
> > -		lnet_finalize(NULL, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  	}
> >  
> >  	/* completion will be signalled by an event */
> > @@ -2804,7 +2804,7 @@ struct lnet_msg *
> >  	if (rc < 0) {
> >  		CNETERR("Error sending GET to %s: %d\n",
> >  			libcfs_id2str(target), rc);
> > -		lnet_finalize(NULL, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  	}
> >  
> >  	/* completion will be signalled by an event */
> > diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> > index aa28b6a..00be9ab 100644
> > --- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
> > +++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> > @@ -452,7 +452,7 @@
> >  }
> >  
> >  void
> > -lnet_finalize(struct lnet_ni *ni, struct lnet_msg *msg, int status)
> > +lnet_finalize(struct lnet_msg *msg, int status)
> >  {
> >  	struct lnet_msg_container *container;
> >  	int my_slot;
> > diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
> > index 8167980..c8a1eb62 100644
> > --- a/drivers/staging/lustre/lnet/lnet/lo.c
> > +++ b/drivers/staging/lustre/lnet/lnet/lo.c
> > @@ -62,10 +62,10 @@
> >  					    sendmsg->msg_offset,
> >  					    iov_iter_count(to));
> >  
> > -		lnet_finalize(ni, lntmsg, 0);
> > +		lnet_finalize(lntmsg, 0);
> >  	}
> >  
> > -	lnet_finalize(ni, sendmsg, 0);
> > +	lnet_finalize(sendmsg, 0);
> >  	return 0;
> >  }
> >  
> > diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> > index 17891f6..3841bac 100644
> > --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> > +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> > @@ -633,7 +633,7 @@ struct delay_daemon_data {
> >  		}
> >  
> >  		lnet_drop_message(ni, cpt, msg->msg_private, msg->msg_len);
> > -		lnet_finalize(ni, msg, rc);
> > +		lnet_finalize(msg, rc);
> >  	}
> >  }
> >  
> > -- 
> > 1.8.3.1
> 
