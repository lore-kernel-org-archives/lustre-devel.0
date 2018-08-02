From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:45:31 +0100 (BST)
Subject: [lustre-devel] [PATCH 1/7] lustre: use
 schedule_timeout_$state().
In-Reply-To: <153292257279.26496.13641642926795469723.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257279.26496.13641642926795469723.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020444260.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Lustre has many calls to
>    set_current_state(STATE);
>    schedule_timeout(time);
> 
> 
> These can more easily be done as
>     schedule_timeout_STATE(time);
> 
> Also clean up some oddities, such as setting the state
> to TASK_RUNNING after the timeout, and simplify
> some time calculations.
> 
> Some schedule_timeout() calls remain as the state was set earlier,
> before an 'add_wait_queue()'.  It would be incorrect to convert these.

From a time long ago.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   12 ++++--------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 ++----
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   14 ++++++--------
>  drivers/staging/lustre/lnet/libcfs/fail.c          |    3 +--
>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |    3 +--
>  drivers/staging/lustre/lnet/lnet/acceptor.c        |    3 +--
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 ++----
>  drivers/staging/lustre/lnet/lnet/peer.c            |    3 +--
>  drivers/staging/lustre/lnet/lnet/router.c          |   19 +++++--------------
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    3 +--
>  drivers/staging/lustre/lnet/selftest/rpc.c         |    3 +--
>  drivers/staging/lustre/lnet/selftest/selftest.h    |    3 +--
>  drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    3 +--
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 +++-----
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 ++----
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    3 +--
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 +---
>  drivers/staging/lustre/lustre/ptlrpc/sec.c         |    3 +--
>  19 files changed, 36 insertions(+), 71 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index e15ad94151bd..f496e6fcc416 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1201,8 +1201,7 @@ static struct kib_hca_dev *kiblnd_current_hdev(struct kib_dev *dev)
>  		if (!(i++ % 50))
>  			CDEBUG(D_NET, "%s: Wait for failover\n",
>  			       dev->ibd_ifname);
> -		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(HZ / 100);
> +		schedule_timeout_interruptible(HZ / 100);
>  
>  		read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
>  	}
> @@ -1916,8 +1915,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
>  		CDEBUG(D_NET, "Another thread is allocating new %s pool, waiting %d HZs for her to complete. trips = %d\n",
>  		       ps->ps_name, interval, trips);
>  
> -		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(interval);
> +		schedule_timeout_interruptible(interval);
>  		if (interval < HZ)
>  			interval *= 2;
>  
> @@ -2548,8 +2546,7 @@ static void kiblnd_base_shutdown(void)
>  			CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET,
>  			       "Waiting for %d threads to terminate\n",
>  			       atomic_read(&kiblnd_data.kib_nthreads));
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ);
> +			schedule_timeout_uninterruptible(HZ);
>  		}
>  
>  		/* fall through */
> @@ -2599,8 +2596,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
>  			       "%s: waiting for %d peers to disconnect\n",
>  			       libcfs_nid2str(ni->ni_nid),
>  			       atomic_read(&net->ibn_npeers));
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ);
> +			schedule_timeout_uninterruptible(HZ);
>  		}
>  
>  		kiblnd_net_fini_pools(net);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index f0b0480686dc..4dde158451ea 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -2307,8 +2307,7 @@ ksocknal_base_shutdown(void)
>  			       "waiting for %d threads to terminate\n",
>  				ksocknal_data.ksnd_nthreads);
>  			read_unlock(&ksocknal_data.ksnd_global_lock);
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ);
> +			schedule_timeout_uninterruptible(HZ);
>  			read_lock(&ksocknal_data.ksnd_global_lock);
>  		}
>  		read_unlock(&ksocknal_data.ksnd_global_lock);
> @@ -2533,8 +2532,7 @@ ksocknal_shutdown(struct lnet_ni *ni)
>  		CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET, /* power of 2? */
>  		       "waiting for %d peers to disconnect\n",
>  		       net->ksnn_npeers);
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ);
> +		schedule_timeout_uninterruptible(HZ);
>  
>  		ksocknal_debug_peerhash(ni);
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index a5c0e8a9bc40..32b76727f400 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -188,10 +188,9 @@ ksocknal_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
>  	int rc;
>  	int bufnob;
>  
> -	if (ksocknal_data.ksnd_stall_tx) {
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(ksocknal_data.ksnd_stall_tx * HZ);
> -	}
> +	if (ksocknal_data.ksnd_stall_tx)
> +		schedule_timeout_uninterruptible(
> +			ksocknal_data.ksnd_stall_tx * HZ);
>  
>  	LASSERT(tx->tx_resid);
>  
> @@ -293,10 +292,9 @@ ksocknal_receive(struct ksock_conn *conn)
>  	 */
>  	int rc;
>  
> -	if (ksocknal_data.ksnd_stall_rx) {
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(ksocknal_data.ksnd_stall_rx * HZ);
> -	}
> +	if (ksocknal_data.ksnd_stall_rx)
> +		schedule_timeout_uninterruptible(
> +			ksocknal_data.ksnd_stall_rx * HZ);
>  
>  	rc = ksocknal_connsock_addref(conn);
>  	if (rc) {
> diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
> index bd86b3b5bc34..6ee4de2178ce 100644
> --- a/drivers/staging/lustre/lnet/libcfs/fail.c
> +++ b/drivers/staging/lustre/lnet/libcfs/fail.c
> @@ -137,8 +137,7 @@ int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
>  	if (ret && likely(ms > 0)) {
>  		CERROR("cfs_fail_timeout id %x sleeping for %dms\n",
>  		       id, ms);
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(ms * HZ / 1000);
> +		schedule_timeout_uninterruptible(ms * HZ / 1000);
>  		CERROR("cfs_fail_timeout id %x awake\n", id);
>  	}
>  	return ret;
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index a4768e930021..d4c80cf254e4 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -1208,8 +1208,7 @@ static int tracefiled(void *arg)
>  		}
>  		init_waitqueue_entry(&__wait, current);
>  		add_wait_queue(&tctl->tctl_waitq, &__wait);
> -		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(HZ);
> +		schedule_timeout_interruptible(HZ);
>  		remove_wait_queue(&tctl->tctl_waitq, &__wait);
>  	}
>  	complete(&tctl->tctl_stop);
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> index 5648f17eddc0..3ae3ca1311a1 100644
> --- a/drivers/staging/lustre/lnet/lnet/acceptor.c
> +++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
> @@ -362,8 +362,7 @@ lnet_acceptor(void *arg)
>  		if (rc) {
>  			if (rc != -EAGAIN) {
>  				CWARN("Accept error %d: pausing...\n", rc);
> -				set_current_state(TASK_UNINTERRUPTIBLE);
> -				schedule_timeout(HZ);
> +				schedule_timeout_uninterruptible(HZ);
>  			}
>  			continue;
>  		}
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 14b797802a85..cdbbe9cc8d95 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -955,8 +955,7 @@ lnet_ping_md_unlink(struct lnet_ping_info *pinfo,
>  	/* NB md could be busy; this just starts the unlink */
>  	while (pinfo->pi_features != LNET_PING_FEAT_INVAL) {
>  		CDEBUG(D_NET, "Still waiting for ping MD to unlink\n");
> -		set_current_state(TASK_NOLOAD);
> -		schedule_timeout(HZ);
> +		schedule_timeout_idle(HZ);
>  	}
>  }
>  
> @@ -1093,8 +1092,7 @@ lnet_clear_zombies_nis_locked(void)
>  				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
>  				       libcfs_nid2str(ni->ni_nid));
>  			}
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ);
> +			schedule_timeout_uninterruptible(HZ);
>  			lnet_net_lock(LNET_LOCK_EX);
>  			continue;
>  		}
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 7c303ef6bb34..d9452c322e4d 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -136,8 +136,7 @@ lnet_peer_table_deathrow_wait_locked(struct lnet_peer_table *ptable,
>  			       "Waiting for %d zombies on peer table\n",
>  			       ptable->pt_zombies);
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ >> 1);
> +		schedule_timeout_uninterruptible(HZ >> 1);
>  		lnet_net_lock(cpt_locked);
>  	}
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 53373372b526..02241fbc9eaa 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -783,8 +783,7 @@ lnet_wait_known_routerstate(void)
>  		if (all_known)
>  			return;
>  
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ);
> +		schedule_timeout_uninterruptible(HZ);
>  	}
>  }
>  
> @@ -1159,8 +1158,7 @@ lnet_prune_rc_data(int wait_unlink)
>  		i++;
>  		CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET,
>  		       "Waiting for rc buffers to unlink\n");
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 4);
> +		schedule_timeout_uninterruptible(HZ / 4);
>  
>  		lnet_net_lock(LNET_LOCK_EX);
>  	}
> @@ -1236,23 +1234,16 @@ lnet_router_checker(void *arg)
>  
>  		lnet_prune_rc_data(0); /* don't wait for UNLINK */
>  
> -		/*
> -		 * Call schedule_timeout() here always adds 1 to load average
> -		 * because kernel counts # active tasks as nr_running
> -		 * + nr_uninterruptible.
> -		 */
>  		/*
>  		 * if there are any routes then wakeup every second.  If
>  		 * there are no routes then sleep indefinitely until woken
>  		 * up by a user adding a route
>  		 */
>  		if (!lnet_router_checker_active())
> -			wait_event_interruptible(the_lnet.ln_rc_waitq,
> -						 lnet_router_checker_active());
> +			wait_event_idle(the_lnet.ln_rc_waitq,
> +					lnet_router_checker_active());
>  		else
> -			wait_event_interruptible_timeout(the_lnet.ln_rc_waitq,
> -							 false,
> -							 HZ);
> +			schedule_timeout_idle(HZ);
>  	}
>  
>  	lnet_prune_rc_data(1); /* wait for UNLINK */
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index e73b956d15e4..7809c1fc6f73 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -1345,8 +1345,7 @@ lstcon_rpc_cleanup_wait(void)
>  		mutex_unlock(&console_session.ses_mutex);
>  
>  		CWARN("Session is shutting down, waiting for termination of transactions\n");
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ);
> +		schedule_timeout_uninterruptible(HZ);
>  
>  		mutex_lock(&console_session.ses_mutex);
>  	}
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
> index e097ef8414a6..298de41444b3 100644
> --- a/drivers/staging/lustre/lnet/selftest/rpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/rpc.c
> @@ -1603,8 +1603,7 @@ srpc_startup(void)
>  	spin_lock_init(&srpc_data.rpc_glock);
>  
>  	/* 1 second pause to avoid timestamp reuse */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ);
> +	schedule_timeout_uninterruptible(HZ);
>  	srpc_data.rpc_matchbits = ((__u64)ktime_get_real_seconds()) << 48;
>  
>  	srpc_data.rpc_state = SRPC_STATE_NONE;
> diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
> index ad9be095c4ea..9dbb0a51d430 100644
> --- a/drivers/staging/lustre/lnet/selftest/selftest.h
> +++ b/drivers/staging/lustre/lnet/selftest/selftest.h
> @@ -573,8 +573,7 @@ swi_state2str(int state)
>  
>  #define selftest_wait_events()					\
>  	do {							\
> -		set_current_state(TASK_UNINTERRUPTIBLE);	\
> -		schedule_timeout(HZ / 10);	\
> +		schedule_timeout_uninterruptible(HZ / 10);	\
>  	} while (0)
>  
>  #define lst_wait_until(cond, lock, fmt, ...)				\
> diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
> index a9c9992a2502..6ac7fc4fa8c6 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
> @@ -124,7 +124,7 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
>  	 */
>  	while (unlikely(lck->rpcl_it == MDC_FAKE_RPCL_IT)) {
>  		mutex_unlock(&lck->rpcl_mutex);
> -		schedule_timeout(HZ / 4);
> +		schedule_timeout_uninterruptible(HZ / 4);
>  		goto again;
>  	}
>  
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index 5b125fdc7321..0ee4798f1bb9 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -167,8 +167,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
>  		int to = HZ;
>  
>  		while (to > 0) {
> -			set_current_state(TASK_INTERRUPTIBLE);
> -			schedule_timeout(to);
> +			schedule_timeout_interruptible(to);
>  			if (lock->l_granted_mode == lock->l_req_mode ||
>  			    ldlm_is_destroyed(lock))
>  				break;
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index f06cbd8b6d13..33d73fa8e9d5 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -749,11 +749,9 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
>  			 */
>  			unlock_res(res);
>  			LDLM_DEBUG(lock, "setting FL_LOCAL_ONLY");
> -			if (lock->l_flags & LDLM_FL_FAIL_LOC) {
> -				set_current_state(TASK_UNINTERRUPTIBLE);
> -				schedule_timeout(4 * HZ);
> -				set_current_state(TASK_RUNNING);
> -			}
> +			if (lock->l_flags & LDLM_FL_FAIL_LOC)
> +				schedule_timeout_uninterruptible(4 * HZ);
> +
>  			if (lock->l_completion_ast)
>  				lock->l_completion_ast(lock, LDLM_FL_FAILED,
>  						       NULL);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index 5c8d0fe7217e..3dedc61d2257 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -706,10 +706,8 @@ void ll_kill_super(struct super_block *sb)
>  		sbi->ll_umounting = 1;
>  
>  		/* wait running statahead threads to quit */
> -		while (atomic_read(&sbi->ll_sa_running) > 0) {
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC >> 3));
> -		}
> +		while (atomic_read(&sbi->ll_sa_running) > 0)
> +			schedule_timeout_uninterruptible(HZ >> 3);
>  	}
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index 3022706c6985..1ddb4a6dd8f3 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -751,8 +751,7 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
>  	while (!list_empty(&ec->ec_objects)) {
>  		spin_unlock(&ec->ec_lock);
>  		CERROR("echo_client still has objects at cleanup time, wait for 1 second\n");
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ);
> +		schedule_timeout_uninterruptible(HZ);
>  		lu_site_purge(env, ed->ed_site, -1);
>  		spin_lock(&ec->ec_lock);
>  	}
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index 7a3d83c0e50b..91dd09867260 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -761,9 +761,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
>  			/* The RPC is infected, let the test change the
>  			 * fail_loc
>  			 */
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(2 * HZ);
> -			set_current_state(TASK_RUNNING);
> +			schedule_timeout_uninterruptible(2 * HZ);
>  		}
>  	}
>  
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> index 9b60292370a7..9c598710b576 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> @@ -514,8 +514,7 @@ static int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
>  		       "ctx (%p, fl %lx) doesn't switch, relax a little bit\n",
>  		       newctx, newctx->cc_flags);
>  
> -		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC));
> +		schedule_timeout_interruptible(HZ);
>  	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT, &newctx->cc_flags))) {
>  		/*
>  		 * new ctx not up to date yet
> 
> 
> 
