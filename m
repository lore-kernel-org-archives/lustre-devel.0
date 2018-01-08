From: James Simmons <jsimmons@infradead.org>
Date: Mon, 8 Jan 2018 16:52:35 +0000 (GMT)
Subject: [lustre-devel] [PATCH 04/19] staging: lustre: discard
 cfs_time_seconds()
In-Reply-To: <151538209341.23920.8613572158448297057.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209341.23920.8613572158448297057.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801081630470.9942@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> cfs_time_seconds() converts a number of seconds to the
> matching number of jiffies.
> The standard way to do this in Linux is  "* HZ".
> So discard cfs_time_seconds() and use "* HZ" instead.
 
Just to make you aware I have been working for several months on 
moving lustre away from using jiffies as much as possible. The
problem with using HZ is that it can vary. So when you have a
parallel file system with batches of nodes that have different
values of HZ you can get very interesting corner cases. So I have
been moving everything over to time64_t and ktime. Also I mostly
have killed off the cfs_time_shift* and crap as well. You see all
work under https://jira.hpdd.intel.com/browse/LU-9019. So many
of the cases you did below don't event exist any more. I was
planning to push those changes after the next merge window.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_debug.h     |    4 ++--
>  .../lustre/include/linux/libcfs/libcfs_time.h      |    2 +-
>  .../lustre/include/linux/libcfs/linux/linux-time.h |    7 +-----
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    8 ++++---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 ++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 +++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   22 ++++++++++----------
>  drivers/staging/lustre/lnet/libcfs/debug.c         |    2 +-
>  drivers/staging/lustre/lnet/libcfs/fail.c          |    2 +-
>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |    4 ++--
>  drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 +-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 ++--
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 ++--
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |   14 +++++--------
>  drivers/staging/lustre/lnet/lnet/peer.c            |    2 +-
>  drivers/staging/lustre/lnet/lnet/router.c          |    8 ++++---
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 ++--
>  drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
>  drivers/staging/lustre/lnet/selftest/selftest.h    |    2 +-
>  drivers/staging/lustre/lnet/selftest/timer.c       |    2 +-
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
>  drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 +-
>  drivers/staging/lustre/lustre/include/lustre_net.h |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    4 ++--
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 +-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 ++--
>  drivers/staging/lustre/lustre/llite/statahead.c    |    2 +-
>  drivers/staging/lustre/lustre/lov/lov_request.c    |    4 ++--
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |    2 +-
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |    4 ++--
>  drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |   10 +++++----
>  drivers/staging/lustre/lustre/ptlrpc/events.c      |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |   15 ++++++--------
>  drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    4 ++--
>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    8 ++++---
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    4 ++--
>  drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |    8 ++++---
>  46 files changed, 96 insertions(+), 106 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> index 1b98f0953afb..9290a19429e7 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> @@ -66,8 +66,8 @@ extern unsigned int libcfs_panic_on_lbug;
>  # define DEBUG_SUBSYSTEM S_UNDEFINED
>  #endif
>  
> -#define CDEBUG_DEFAULT_MAX_DELAY (cfs_time_seconds(600))	 /* jiffies */
> -#define CDEBUG_DEFAULT_MIN_DELAY ((cfs_time_seconds(1) + 1) / 2) /* jiffies */
> +#define CDEBUG_DEFAULT_MAX_DELAY (600 * HZ)	 /* jiffies */
> +#define CDEBUG_DEFAULT_MIN_DELAY ((HZ + 1) / 2) /* jiffies */
>  #define CDEBUG_DEFAULT_BACKOFF   2
>  struct cfs_debug_limit_state {
>  	unsigned long   cdls_next;
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> index 9699646decb9..c4f25be78268 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> @@ -62,7 +62,7 @@ static inline int cfs_time_aftereq(unsigned long t1, unsigned long t2)
>  
>  static inline unsigned long cfs_time_shift(int seconds)
>  {
> -	return cfs_time_add(cfs_time_current(), cfs_time_seconds(seconds));
> +	return cfs_time_add(cfs_time_current(), seconds * HZ);
>  }
>  
>  /*
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> index aece13698eb4..805cb326af86 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> @@ -65,11 +65,6 @@ static inline unsigned long cfs_time_current(void)
>  	return jiffies;
>  }
>  
> -static inline long cfs_time_seconds(int seconds)
> -{
> -	return ((long)seconds) * msecs_to_jiffies(MSEC_PER_SEC);
> -}
> -
>  static inline long cfs_duration_sec(long d)
>  {
>  	return d / msecs_to_jiffies(MSEC_PER_SEC);
> @@ -85,7 +80,7 @@ static inline u64 cfs_time_add_64(u64 t, u64 d)
>  static inline u64 cfs_time_shift_64(int seconds)
>  {
>  	return cfs_time_add_64(cfs_time_current_64(),
> -			       cfs_time_seconds(seconds));
> +			       seconds * HZ);
>  }
>  
>  static inline int cfs_time_before_64(u64 t1, u64 t2)
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index bb7b19473e3a..8a49f7730308 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1219,7 +1219,7 @@ static struct kib_hca_dev *kiblnd_current_hdev(struct kib_dev *dev)
>  			CDEBUG(D_NET, "%s: Wait for failover\n",
>  			       dev->ibd_ifname);
>  		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1) / 100);
> +		schedule_timeout(HZ / 100);
>  
>  		read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
>  	}
> @@ -1930,7 +1930,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
>  
>  		set_current_state(TASK_INTERRUPTIBLE);
>  		schedule_timeout(interval);
> -		if (interval < cfs_time_seconds(1))
> +		if (interval < HZ)
>  			interval *= 2;
>  
>  		goto again;
> @@ -2567,7 +2567,7 @@ static void kiblnd_base_shutdown(void)
>  			       "Waiting for %d threads to terminate\n",
>  			       atomic_read(&kiblnd_data.kib_nthreads));
>  			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(cfs_time_seconds(1));
> +			schedule_timeout(HZ);
>  		}
>  
>  		/* fall through */
> @@ -2618,7 +2618,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
>  			       libcfs_nid2str(ni->ni_nid),
>  			       atomic_read(&net->ibn_npeers));
>  			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(cfs_time_seconds(1));
> +			schedule_timeout(HZ);
>  		}
>  
>  		kiblnd_net_fini_pools(net);
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 9b3328c5d1e7..0b30c205e760 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -3726,8 +3726,8 @@ kiblnd_failover_thread(void *arg)
>  		add_wait_queue(&kiblnd_data.kib_failover_waitq, &wait);
>  		write_unlock_irqrestore(glock, flags);
>  
> -		rc = schedule_timeout(long_sleep ? cfs_time_seconds(10) :
> -						   cfs_time_seconds(1));
> +		rc = schedule_timeout(long_sleep ? 10 * HZ :
> +						   HZ);
>  		remove_wait_queue(&kiblnd_data.kib_failover_waitq, &wait);
>  		write_lock_irqsave(glock, flags);
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 7dba949a95a7..6ab876d8c744 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -1677,7 +1677,7 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
>  	switch (conn->ksnc_rx_state) {
>  	case SOCKNAL_RX_LNET_PAYLOAD:
>  		last_rcv = conn->ksnc_rx_deadline -
> -			   cfs_time_seconds(*ksocknal_tunables.ksnd_timeout);
> +			   *ksocknal_tunables.ksnd_timeout * HZ;
>  		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %ld secs ago\n",
>  		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
>  		       &conn->ksnc_ipaddr, conn->ksnc_port,
> @@ -2361,7 +2361,7 @@ ksocknal_base_shutdown(void)
>  				ksocknal_data.ksnd_nthreads);
>  			read_unlock(&ksocknal_data.ksnd_global_lock);
>  			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(cfs_time_seconds(1));
> +			schedule_timeout(HZ);
>  			read_lock(&ksocknal_data.ksnd_global_lock);
>  		}
>  		read_unlock(&ksocknal_data.ksnd_global_lock);
> @@ -2604,7 +2604,7 @@ ksocknal_shutdown(struct lnet_ni *ni)
>  		       "waiting for %d peers to disconnect\n",
>  		       net->ksnn_npeers);
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  
>  		ksocknal_debug_peerhash(ni);
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index 11fd3a36424f..63e452f666bf 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -189,7 +189,7 @@ ksocknal_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
>  
>  	if (ksocknal_data.ksnd_stall_tx) {
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(ksocknal_data.ksnd_stall_tx));
> +		schedule_timeout(ksocknal_data.ksnd_stall_tx * HZ);
>  	}
>  
>  	LASSERT(tx->tx_resid);
> @@ -294,7 +294,7 @@ ksocknal_receive(struct ksock_conn *conn)
>  
>  	if (ksocknal_data.ksnd_stall_rx) {
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(ksocknal_data.ksnd_stall_rx));
> +		schedule_timeout(ksocknal_data.ksnd_stall_rx * HZ);
>  	}
>  
>  	rc = ksocknal_connsock_addref(conn);
> @@ -1780,7 +1780,7 @@ ksocknal_connect(struct ksock_route *route)
>  	int rc = 0;
>  
>  	deadline = cfs_time_add(cfs_time_current(),
> -				cfs_time_seconds(*ksocknal_tunables.ksnd_timeout));
> +				*ksocknal_tunables.ksnd_timeout * HZ);
>  
>  	write_lock_bh(&ksocknal_data.ksnd_global_lock);
>  
> @@ -1878,7 +1878,7 @@ ksocknal_connect(struct ksock_route *route)
>  			 * so min_reconnectms should be good heuristic
>  			 */
>  			route->ksnr_retry_interval =
> -				cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms) / 1000;
> +				*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000;
>  			route->ksnr_timeout = cfs_time_add(cfs_time_current(),
>  							   route->ksnr_retry_interval);
>  		}
> @@ -1899,10 +1899,10 @@ ksocknal_connect(struct ksock_route *route)
>  	route->ksnr_retry_interval *= 2;
>  	route->ksnr_retry_interval =
>  		max(route->ksnr_retry_interval,
> -		    cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms) / 1000);
> +		    (long)*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000);
>  	route->ksnr_retry_interval =
>  		min(route->ksnr_retry_interval,
> -		    cfs_time_seconds(*ksocknal_tunables.ksnd_max_reconnectms) / 1000);
> +		    (long)*ksocknal_tunables.ksnd_max_reconnectms * HZ / 1000);
>  
>  	LASSERT(route->ksnr_retry_interval);
>  	route->ksnr_timeout = cfs_time_add(cfs_time_current(),
> @@ -1972,7 +1972,7 @@ ksocknal_connd_check_start(time64_t sec, long *timeout)
>  
>  	if (sec - ksocknal_data.ksnd_connd_failed_stamp <= 1) {
>  		/* may run out of resource, retry later */
> -		*timeout = cfs_time_seconds(1);
> +		*timeout = HZ;
>  		return 0;
>  	}
>  
> @@ -2031,8 +2031,8 @@ ksocknal_connd_check_stop(time64_t sec, long *timeout)
>  	val = (int)(ksocknal_data.ksnd_connd_starting_stamp +
>  		    SOCKNAL_CONND_TIMEOUT - sec);
>  
> -	*timeout = (val > 0) ? cfs_time_seconds(val) :
> -			       cfs_time_seconds(SOCKNAL_CONND_TIMEOUT);
> +	*timeout = (val > 0) ? val * HZ :
> +			       SOCKNAL_CONND_TIMEOUT * HZ;
>  	if (val > 0)
>  		return 0;
>  
> @@ -2307,7 +2307,7 @@ ksocknal_send_keepalive_locked(struct ksock_peer *peer)
>  	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
>  	    time_before(cfs_time_current(),
>  			cfs_time_add(peer->ksnp_last_alive,
> -				     cfs_time_seconds(*ksocknal_tunables.ksnd_keepalive))))
> +				     *ksocknal_tunables.ksnd_keepalive * HZ)))
>  		return 0;
>  
>  	if (time_before(cfs_time_current(), peer->ksnp_send_keepalive))
> @@ -2563,7 +2563,7 @@ ksocknal_reaper(void *arg)
>  					     ksocknal_data.ksnd_peer_hash_size;
>  			}
>  
> -			deadline = cfs_time_add(deadline, cfs_time_seconds(p));
> +			deadline = cfs_time_add(deadline, p * HZ);
>  		}
>  
>  		if (nenomem_conns) {
> diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
> index 551c45bf4108..c70d2ae29b11 100644
> --- a/drivers/staging/lustre/lnet/libcfs/debug.c
> +++ b/drivers/staging/lustre/lnet/libcfs/debug.c
> @@ -113,7 +113,7 @@ static int param_set_delay_minmax(const char *val,
>  	if (rc)
>  		return -EINVAL;
>  
> -	d = cfs_time_seconds(sec) / 100;
> +	d = sec * HZ / 100;
>  	if (d < min || d > max)
>  		return -EINVAL;
>  
> diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
> index 39439b303d65..d3f1e866c6a7 100644
> --- a/drivers/staging/lustre/lnet/libcfs/fail.c
> +++ b/drivers/staging/lustre/lnet/libcfs/fail.c
> @@ -134,7 +134,7 @@ int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
>  		CERROR("cfs_fail_timeout id %x sleeping for %dms\n",
>  		       id, ms);
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(ms) / 1000);
> +		schedule_timeout(ms * HZ / 1000);
>  		CERROR("cfs_fail_timeout id %x awake\n", id);
>  	}
>  	return ret;
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index da2844f37edf..8c33c8fa66e2 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -441,7 +441,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
>  
>  		if (cfs_time_after(cfs_time_current(),
>  				   cdls->cdls_next + libcfs_console_max_delay +
> -				   cfs_time_seconds(10))) {
> +				   10 * HZ)) {
>  			/* last timeout was a long time ago */
>  			cdls->cdls_delay /= libcfs_console_backoff * 4;
>  		} else {
> @@ -1071,7 +1071,7 @@ static int tracefiled(void *arg)
>  		init_waitqueue_entry(&__wait, current);
>  		add_wait_queue(&tctl->tctl_waitq, &__wait);
>  		set_current_state(TASK_INTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  		remove_wait_queue(&tctl->tctl_waitq, &__wait);
>  	}
>  	complete(&tctl->tctl_stop);
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> index ee85cab6f437..6c1f4941d4ba 100644
> --- a/drivers/staging/lustre/lnet/lnet/acceptor.c
> +++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
> @@ -365,7 +365,7 @@ lnet_acceptor(void *arg)
>  			if (rc != -EAGAIN) {
>  				CWARN("Accept error %d: pausing...\n", rc);
>  				set_current_state(TASK_UNINTERRUPTIBLE);
> -				schedule_timeout(cfs_time_seconds(1));
> +				schedule_timeout(HZ);
>  			}
>  			continue;
>  		}
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 6a1fb0397604..ddd37eae63c6 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -973,7 +973,7 @@ lnet_ping_md_unlink(struct lnet_ping_info *pinfo,
>  	while (pinfo->pi_features != LNET_PING_FEAT_INVAL) {
>  		CDEBUG(D_NET, "Still waiting for ping MD to unlink\n");
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  	}
>  
>  	cfs_restore_sigs(blocked);
> @@ -1112,7 +1112,7 @@ lnet_clear_zombies_nis_locked(void)
>  				       libcfs_nid2str(ni->ni_nid));
>  			}
>  			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(cfs_time_seconds(1));
> +			schedule_timeout(HZ);
>  			lnet_net_lock(LNET_LOCK_EX);
>  			continue;
>  		}
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index d724c4c73ecc..7fe7ae917273 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -524,7 +524,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
>  		return 0;
>  
>  	deadline = cfs_time_add(lp->lp_last_alive,
> -				cfs_time_seconds(lp->lp_ni->ni_peertimeout));
> +				lp->lp_ni->ni_peertimeout * HZ);
>  	alive = cfs_time_after(deadline, now);
>  
>  	/* Update obsolete lp_alive except for routers assumed to be dead
> @@ -562,7 +562,7 @@ lnet_peer_alive_locked(struct lnet_peer *lp)
>  
>  		unsigned long next_query =
>  			   cfs_time_add(lp->lp_last_query,
> -					cfs_time_seconds(lnet_queryinterval));
> +					lnet_queryinterval * HZ);
>  
>  		if (time_before(now, next_query)) {
>  			if (lp->lp_alive)
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index e3468cef273b..a63b7941d435 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -315,9 +315,8 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
>  				rule->dr_time_base = now;
>  
>  			rule->dr_drop_time = rule->dr_time_base +
> -				cfs_time_seconds(
> -					prandom_u32_max(attr->u.drop.da_interval));
> -			rule->dr_time_base += cfs_time_seconds(attr->u.drop.da_interval);
> +				prandom_u32_max(attr->u.drop.da_interval) * HZ;
> +			rule->dr_time_base += attr->u.drop.da_interval * HZ;
>  
>  			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lu\n",
>  			       libcfs_nid2str(attr->fa_src),
> @@ -440,8 +439,7 @@ static struct delay_daemon_data	delay_dd;
>  static unsigned long
>  round_timeout(unsigned long timeout)
>  {
> -	return cfs_time_seconds((unsigned int)
> -			cfs_duration_sec(cfs_time_sub(timeout, 0)) + 1);
> +	return (unsigned int)rounddown(timeout, HZ) + HZ;
>  }
>  
>  static void
> @@ -483,10 +481,8 @@ delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
>  				rule->dl_time_base = now;
>  
>  			rule->dl_delay_time = rule->dl_time_base +
> -				cfs_time_seconds(
> -					prandom_u32_max(
> -						attr->u.delay.la_interval));
> -			rule->dl_time_base += cfs_time_seconds(attr->u.delay.la_interval);
> +				prandom_u32_max(attr->u.delay.la_interval) * HZ;
> +			rule->dl_time_base += attr->u.delay.la_interval * HZ;
>  
>  			CDEBUG(D_NET, "Delay Rule %s->%s: next delay : %lu\n",
>  			       libcfs_nid2str(attr->fa_src),
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 19fcbcf0f642..89610f768b4f 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -137,7 +137,7 @@ lnet_peer_table_deathrow_wait_locked(struct lnet_peer_table *ptable,
>  			       ptable->pt_zombies);
>  		}
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1) >> 1);
> +		schedule_timeout(HZ >> 1);
>  		lnet_net_lock(cpt_locked);
>  	}
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 476d6d296037..47a98d50ebc7 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -808,7 +808,7 @@ lnet_wait_known_routerstate(void)
>  			return;
>  
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  	}
>  }
>  
> @@ -1011,7 +1011,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
>  
>  	if (secs && !rtr->lp_ping_notsent &&
>  	    cfs_time_after(now, cfs_time_add(rtr->lp_ping_timestamp,
> -					     cfs_time_seconds(secs)))) {
> +					     secs * HZ))) {
>  		int rc;
>  		struct lnet_process_id id;
>  		struct lnet_handle_md mdh;
> @@ -1185,7 +1185,7 @@ lnet_prune_rc_data(int wait_unlink)
>  		CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET,
>  		       "Waiting for rc buffers to unlink\n");
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1) / 4);
> +		schedule_timeout(HZ / 4);
>  
>  		lnet_net_lock(LNET_LOCK_EX);
>  	}
> @@ -1282,7 +1282,7 @@ lnet_router_checker(void *arg)
>  		else
>  			wait_event_interruptible_timeout(the_lnet.ln_rc_waitq,
>  							 false,
> -							 cfs_time_seconds(1));
> +							 HZ);
>  	}
>  
>  	lnet_prune_rc_data(1); /* wait for UNLINK */
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index 7aa515c34594..6dcc966b293b 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -359,7 +359,7 @@ lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout)
>  
>  	rc = wait_event_interruptible_timeout(trans->tas_waitq,
>  					      lstcon_rpc_trans_check(trans),
> -					      cfs_time_seconds(timeout));
> +					      timeout * HZ);
>  	rc = (rc > 0) ? 0 : ((rc < 0) ? -EINTR : -ETIMEDOUT);
>  
>  	mutex_lock(&console_session.ses_mutex);
> @@ -1350,7 +1350,7 @@ lstcon_rpc_cleanup_wait(void)
>  
>  		CWARN("Session is shutting down, waiting for termination of transactions\n");
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  
>  		mutex_lock(&console_session.ses_mutex);
>  	}
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
> index b515138dca2c..18e0f1b87fc1 100644
> --- a/drivers/staging/lustre/lnet/selftest/rpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/rpc.c
> @@ -1605,7 +1605,7 @@ srpc_startup(void)
>  
>  	/* 1 second pause to avoid timestamp reuse */
>  	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(cfs_time_seconds(1));
> +	schedule_timeout(HZ);
>  	srpc_data.rpc_matchbits = ((__u64)ktime_get_real_seconds()) << 48;
>  
>  	srpc_data.rpc_state = SRPC_STATE_NONE;
> diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
> index ad04534f000c..05466b85e1c0 100644
> --- a/drivers/staging/lustre/lnet/selftest/selftest.h
> +++ b/drivers/staging/lustre/lnet/selftest/selftest.h
> @@ -575,7 +575,7 @@ swi_state2str(int state)
>  #define selftest_wait_events()					\
>  	do {							\
>  		set_current_state(TASK_UNINTERRUPTIBLE);	\
> -		schedule_timeout(cfs_time_seconds(1) / 10);	\
> +		schedule_timeout(HZ / 10);	\
>  	} while (0)
>  
>  #define lst_wait_until(cond, lock, fmt, ...)				\
> diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
> index ab125a8524c5..9716afeb3c94 100644
> --- a/drivers/staging/lustre/lnet/selftest/timer.c
> +++ b/drivers/staging/lustre/lnet/selftest/timer.c
> @@ -177,7 +177,7 @@ stt_timer_main(void *arg)
>  
>  		rc = wait_event_timeout(stt_data.stt_waitq,
>  					stt_data.stt_shuttingdown,
> -					cfs_time_seconds(STTIMER_SLOTTIME));
> +					STTIMER_SLOTTIME * HZ);
>  	}
>  
>  	spin_lock(&stt_data.stt_lock);
> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> index e0b17052b2ea..239aa2b1268f 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> @@ -60,7 +60,7 @@ struct obd_device;
>  #define OBD_LDLM_DEVICENAME  "ldlm"
>  
>  #define LDLM_DEFAULT_LRU_SIZE (100 * num_online_cpus())
> -#define LDLM_DEFAULT_MAX_ALIVE (cfs_time_seconds(3900)) /* 65 min */
> +#define LDLM_DEFAULT_MAX_ALIVE (65 * 60 * HZ) /* 65 min */
>  #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
>  
>  /**
> diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
> index 007e1ec3f0f4..a9c9992a2502 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
> @@ -124,7 +124,7 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
>  	 */
>  	while (unlikely(lck->rpcl_it == MDC_FAKE_RPCL_IT)) {
>  		mutex_unlock(&lck->rpcl_mutex);
> -		schedule_timeout(cfs_time_seconds(1) / 4);
> +		schedule_timeout(HZ / 4);
>  		goto again;
>  	}
>  
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index 4c665eca2467..5a4434e7c85a 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -2262,7 +2262,7 @@ static inline int ptlrpc_send_limit_expired(struct ptlrpc_request *req)
>  {
>  	if (req->rq_delay_limit != 0 &&
>  	    time_before(cfs_time_add(req->rq_queued_time,
> -				     cfs_time_seconds(req->rq_delay_limit)),
> +				     req->rq_delay_limit * HZ),
>  			cfs_time_current())) {
>  		return 1;
>  	}
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index 4f700ddb47c6..773abe78708a 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -1366,7 +1366,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
>  				}
>  			}
>  
> -			lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(obd_timeout),
> +			lwi = LWI_TIMEOUT_INTR(obd_timeout * HZ,
>  					       NULL, LWI_ON_SIGNAL_NOOP, NULL);
>  
>  			/* XXX FIXME see comment on CAN_MATCH in lustre_dlm.h */
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index 6c7c4b19a0a0..58913e628124 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -163,7 +163,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
>  	LDLM_DEBUG(lock, "client completion callback handler START");
>  
>  	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
> -		int to = cfs_time_seconds(1);
> +		int to = HZ;
>  
>  		while (to > 0) {
>  			set_current_state(TASK_INTERRUPTIBLE);
> @@ -327,7 +327,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
>  	    !lock->l_readers && !lock->l_writers &&
>  	    cfs_time_after(cfs_time_current(),
>  			   cfs_time_add(lock->l_last_used,
> -					cfs_time_seconds(10)))) {
> +					10 * HZ))) {
>  		unlock_res_and_lock(lock);
>  		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
>  			ldlm_handle_bl_callback(ns, NULL, lock);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index f27c2694793a..622245a5f049 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -1008,7 +1008,7 @@ static int ldlm_pools_thread_main(void *arg)
>  		 * Wait until the next check time, or until we're
>  		 * stopped.
>  		 */
> -		lwi = LWI_TIMEOUT(cfs_time_seconds(c_time),
> +		lwi = LWI_TIMEOUT(c_time * HZ,
>  				  NULL, NULL);
>  		l_wait_event(thread->t_ctl_waitq,
>  			     thread_is_stopping(thread) ||
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index 6aa37463db46..a244fa717134 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -288,7 +288,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
>  		LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
>  		lwi = LWI_INTR(interrupted_completion_wait, &lwd);
>  	} else {
> -		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(timeout),
> +		lwi = LWI_TIMEOUT_INTR(timeout * HZ,
>  				       ldlm_expired_completion_wait,
>  				       interrupted_completion_wait, &lwd);
>  	}
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index 9958533cc227..2e66825c8f4b 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -799,7 +799,7 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
>  			LDLM_DEBUG(lock, "setting FL_LOCAL_ONLY");
>  			if (lock->l_flags & LDLM_FL_FAIL_LOC) {
>  				set_current_state(TASK_UNINTERRUPTIBLE);
> -				schedule_timeout(cfs_time_seconds(4));
> +				schedule_timeout(4 * HZ);
>  				set_current_state(TASK_RUNNING);
>  			}
>  			if (lock->l_completion_ast)
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index 6735a6f006d2..0a9183f271f5 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -2026,8 +2026,8 @@ void ll_umount_begin(struct super_block *sb)
>  	 * to decrement mnt_cnt and hope to finish it within 10sec.
>  	 */
>  	init_waitqueue_head(&waitq);
> -	lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(10),
> -				   cfs_time_seconds(1), NULL, NULL);
> +	lwi = LWI_TIMEOUT_INTERVAL(10 * HZ,
> +				   HZ, NULL, NULL);
>  	l_wait_event(waitq, may_umount(sbi->ll_mnt.mnt), &lwi);
>  
>  	schedule();
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index 78005cc6e831..96360f104b92 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -1424,7 +1424,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
>  		spin_lock(&lli->lli_sa_lock);
>  		sai->sai_index_wait = entry->se_index;
>  		spin_unlock(&lli->lli_sa_lock);
> -		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
> +		lwi = LWI_TIMEOUT_INTR(30 * HZ, NULL,
>  				       LWI_ON_SIGNAL_NOOP, NULL);
>  		rc = l_wait_event(sai->sai_waitq, sa_ready(entry), &lwi);
>  		if (rc < 0) {
> diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
> index cfa1d7f92b0f..fb3b7a7fa32a 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_request.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_request.c
> @@ -126,8 +126,8 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
>  	mutex_unlock(&lov->lov_lock);
>  
>  	init_waitqueue_head(&waitq);
> -	lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(obd_timeout),
> -				   cfs_time_seconds(1), NULL, NULL);
> +	lwi = LWI_TIMEOUT_INTERVAL(obd_timeout * HZ,
> +				   HZ, NULL, NULL);
>  
>  	rc = l_wait_event(waitq, lov_check_set(lov, ost_idx), &lwi);
>  	if (tgt->ltd_active)
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 03e55bca4ada..b12518ba5ae9 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -888,7 +888,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
>  			       exp->exp_obd->obd_name, -EIO);
>  			return -EIO;
>  		}
> -		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(resends), NULL, NULL,
> +		lwi = LWI_TIMEOUT_INTR(resends * HZ, NULL, NULL,
>  				       NULL);
>  		l_wait_event(waitq, 0, &lwi);
>  
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index b743aee62349..a01d13bde102 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -1628,7 +1628,7 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
>  
>  		if (rcl == -ESHUTDOWN &&
>  		    atomic_read(&mgc->u.cli.cl_mgc_refcount) > 0 && !retry) {
> -			int secs = cfs_time_seconds(obd_timeout);
> +			int secs = obd_timeout * HZ;
>  			struct obd_import *imp;
>  			struct l_wait_info lwi;
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index 902bad22013b..ce5e7bdda692 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -1097,7 +1097,7 @@ EXPORT_SYMBOL(cl_sync_io_init);
>  int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
>  		    long timeout)
>  {
> -	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(timeout),
> +	struct l_wait_info lwi = LWI_TIMEOUT_INTR(timeout * HZ,
>  						  NULL, NULL, NULL);
>  	int rc;
>  
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index b9c1dc7e61b0..9c5ce5074b66 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -752,7 +752,7 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
>  		spin_unlock(&ec->ec_lock);
>  		CERROR("echo_client still has objects at cleanup time, wait for 1 second\n");
>  		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(cfs_time_seconds(1));
> +		schedule_timeout(HZ);
>  		lu_site_purge(env, ed->ed_site, -1);
>  		spin_lock(&ec->ec_lock);
>  	}
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index b8d5adca94e1..0797e671f667 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -934,7 +934,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
>  			   enum osc_extent_state state)
>  {
>  	struct osc_object *obj = ext->oe_obj;
> -	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(600), NULL,
> +	struct l_wait_info lwi = LWI_TIMEOUT_INTR(600 * HZ, NULL,
>  						  LWI_ON_SIGNAL_NOOP, NULL);
>  	int rc = 0;
>  
> @@ -1571,7 +1571,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
>  	struct l_wait_info lwi;
>  	int rc = -EDQUOT;
>  
> -	lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(AT_OFF ? obd_timeout : at_max),
> +	lwi = LWI_TIMEOUT_INTR((AT_OFF ? obd_timeout : at_max) * HZ,
>  			       NULL, LWI_ON_SIGNAL_NOOP, NULL);
>  
>  	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
> diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
> index 6c424f0290bb..6baa8e2e00c9 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_object.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_object.c
> @@ -328,7 +328,7 @@ int osc_object_is_contended(struct osc_object *obj)
>  	 * ll_file_is_contended.
>  	 */
>  	retry_time = cfs_time_add(obj->oo_contention_time,
> -				  cfs_time_seconds(osc_contention_time));
> +				  osc_contention_time * HZ);
>  	if (cfs_time_after(cur_time, retry_time)) {
>  		osc_object_clear_contended(obj);
>  		return 0;
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index bac4b2304bad..0ab13f8e5993 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -766,7 +766,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
>  			 * fail_loc
>  			 */
>  			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(cfs_time_seconds(2));
> +			schedule_timeout(2 * HZ);
>  			set_current_state(TASK_RUNNING);
>  		}
>  	}
> @@ -2284,7 +2284,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
>  			 * We still want to block for a limited time,
>  			 * so we allow interrupts during the timeout.
>  			 */
> -			lwi = LWI_TIMEOUT_INTR_ALL(cfs_time_seconds(1),
> +			lwi = LWI_TIMEOUT_INTR_ALL(HZ,
>  						   ptlrpc_expired_set,
>  						   ptlrpc_interrupted_set, set);
>  		else
> @@ -2293,7 +2293,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
>  			 * interrupts are allowed. Wait until all
>  			 * complete, or an in-flight req times out.
>  			 */
> -			lwi = LWI_TIMEOUT(cfs_time_seconds(timeout ? timeout : 1),
> +			lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
>  					  ptlrpc_expired_set, set);
>  
>  		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
> @@ -2538,8 +2538,8 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
>  		 * Network access will complete in finite time but the HUGE
>  		 * timeout lets us CWARN for visibility of sluggish NALs
>  		 */
> -		lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(LONG_UNLINK),
> -					   cfs_time_seconds(1), NULL, NULL);
> +		lwi = LWI_TIMEOUT_INTERVAL(LONG_UNLINK * HZ,
> +					   HZ, NULL, NULL);
>  		rc = l_wait_event(*wq, !ptlrpc_client_recv_or_unlink(request),
>  				  &lwi);
>  		if (rc == 0) {
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
> index 811b7ab3a582..71f7588570ef 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/events.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
> @@ -517,7 +517,7 @@ static void ptlrpc_ni_fini(void)
>  
>  			/* Wait for a bit */
>  			init_waitqueue_head(&waitq);
> -			lwi = LWI_TIMEOUT(cfs_time_seconds(2), NULL, NULL);
> +			lwi = LWI_TIMEOUT(2 * HZ, NULL, NULL);
>  			l_wait_event(waitq, 0, &lwi);
>  			break;
>  		}
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index 5b0f65536c29..0eba5f18bd3b 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -307,9 +307,9 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
>  		 * have been locally cancelled by ptlrpc_abort_inflight.
>  		 */
>  		lwi = LWI_TIMEOUT_INTERVAL(
> -			cfs_timeout_cap(cfs_time_seconds(timeout)),
> -			(timeout > 1) ? cfs_time_seconds(1) :
> -			cfs_time_seconds(1) / 2,
> +			cfs_timeout_cap(timeout * HZ),
> +			(timeout > 1) ? HZ :
> +			HZ / 2,
>  			NULL, NULL);
>  		rc = l_wait_event(imp->imp_recovery_waitq,
>  				  (atomic_read(&imp->imp_inflight) == 0),
> @@ -431,7 +431,7 @@ void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt)
>  int ptlrpc_reconnect_import(struct obd_import *imp)
>  {
>  	struct l_wait_info lwi;
> -	int secs = cfs_time_seconds(obd_timeout);
> +	int secs = obd_timeout * HZ;
>  	int rc;
>  
>  	ptlrpc_pinger_force(imp);
> @@ -1508,14 +1508,13 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>  
>  		if (AT_OFF) {
>  			if (imp->imp_server_timeout)
> -				timeout = cfs_time_seconds(obd_timeout / 2);
> +				timeout = obd_timeout * HZ / 2;
>  			else
> -				timeout = cfs_time_seconds(obd_timeout);
> +				timeout = obd_timeout * HZ;
>  		} else {
>  			int idx = import_at_get_index(imp,
>  				imp->imp_client->cli_request_portal);
> -			timeout = cfs_time_seconds(
> -				at_get(&imp->imp_at.iat_service_estimate[idx]));
> +			timeout = at_get(&imp->imp_at.iat_service_estimate[idx]) * HZ;
>  		}
>  
>  		lwi = LWI_TIMEOUT_INTR(cfs_timeout_cap(timeout),
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> index 047d712e850c..0c2ded721c49 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> @@ -270,8 +270,8 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
>  		/* Network access will complete in finite time but the HUGE
>  		 * timeout lets us CWARN for visibility of sluggish LNDs
>  		 */
> -		lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(LONG_UNLINK),
> -					   cfs_time_seconds(1), NULL, NULL);
> +		lwi = LWI_TIMEOUT_INTERVAL(LONG_UNLINK * HZ,
> +					   HZ, NULL, NULL);
>  		rc = l_wait_event(*wq, !ptlrpc_client_bulk_active(req), &lwi);
>  		if (rc == 0) {
>  			ptlrpc_rqphase_move(req, req->rq_next_phase);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> index a64e125df95f..c060d6f5015a 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> @@ -267,7 +267,7 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
>  		/* If we cannot get anything for some long time, we better
>  		 * bail out instead of waiting infinitely
>  		 */
> -		lwi = LWI_TIMEOUT(cfs_time_seconds(10), NULL, NULL);
> +		lwi = LWI_TIMEOUT(10 * HZ, NULL, NULL);
>  		rc = l_wait_event(svcpt->scp_rep_waitq,
>  				  !list_empty(&svcpt->scp_rep_idle), &lwi);
>  		if (rc != 0)
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> index af707cb2b62b..010a1cdf05fa 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> @@ -141,7 +141,7 @@ static long pinger_check_timeout(unsigned long time)
>  	}
>  	mutex_unlock(&pinger_mutex);
>  
> -	return cfs_time_sub(cfs_time_add(time, cfs_time_seconds(timeout)),
> +	return cfs_time_sub(cfs_time_add(time, timeout * HZ),
>  					 cfs_time_current());
>  }
>  
> @@ -247,7 +247,7 @@ static int ptlrpc_pinger_main(void *arg)
>  			if (imp->imp_pingable && imp->imp_next_ping &&
>  			    cfs_time_after(imp->imp_next_ping,
>  					   cfs_time_add(this_ping,
> -							cfs_time_seconds(PING_INTERVAL))))
> +							PING_INTERVAL * HZ)))
>  				ptlrpc_update_next_ping(imp, 0);
>  		}
>  		mutex_unlock(&pinger_mutex);
> @@ -264,10 +264,10 @@ static int ptlrpc_pinger_main(void *arg)
>  		CDEBUG(D_INFO, "next wakeup in " CFS_DURATION_T " (%ld)\n",
>  		       time_to_next_wake,
>  		       cfs_time_add(this_ping,
> -				    cfs_time_seconds(PING_INTERVAL)));
> +				    PING_INTERVAL * HZ));
>  		if (time_to_next_wake > 0) {
>  			lwi = LWI_TIMEOUT(max_t(long, time_to_next_wake,
> -						cfs_time_seconds(1)),
> +						HZ),
>  					  NULL, NULL);
>  			l_wait_event(thread->t_ctl_waitq,
>  				     thread_is_stopping(thread) ||
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> index 8b865294d933..dad2f9290f70 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> @@ -230,7 +230,7 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
>  
>  	spin_lock(&req->rq_lock);
>  	if (req->rq_invalid_rqset) {
> -		struct l_wait_info lwi = LWI_TIMEOUT(cfs_time_seconds(5),
> +		struct l_wait_info lwi = LWI_TIMEOUT(5 * HZ,
>  						     back_to_sleep, NULL);
>  
>  		req->rq_invalid_rqset = 0;
> @@ -438,7 +438,7 @@ static int ptlrpcd(void *arg)
>  		int timeout;
>  
>  		timeout = ptlrpc_set_next_timeout(set);
> -		lwi = LWI_TIMEOUT(cfs_time_seconds(timeout ? timeout : 1),
> +		lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
>  				  ptlrpc_expired_set, set);
>  
>  		lu_context_enter(&env.le_ctx);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
> index e4d3f23e9f3a..5bbd23eebfa6 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
> @@ -347,7 +347,7 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
>  
>  	if (!async) {
>  		struct l_wait_info lwi;
> -		int secs = cfs_time_seconds(obd_timeout);
> +		int secs = obd_timeout * HZ;
>  
>  		CDEBUG(D_HA, "%s: recovery started, waiting %u seconds\n",
>  		       obd2cli_tgt(imp->imp_obd), secs);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index 1f22926c1355..6d4229ebc9d9 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -2149,7 +2149,7 @@ static int ptlrpc_main(void *arg)
>  			 * Wait for a timeout (unless something else
>  			 * happens) before I try again
>  			 */
> -			svcpt->scp_rqbd_timeout = cfs_time_seconds(1) / 10;
> +			svcpt->scp_rqbd_timeout = HZ / 10;
>  			CDEBUG(D_RPCTRACE, "Posted buffers: %d\n",
>  			       svcpt->scp_nrqbds_posted);
>  		}
> @@ -2588,7 +2588,7 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
>  {
>  	while (1) {
>  		int rc;
> -		struct l_wait_info lwi = LWI_TIMEOUT(cfs_time_seconds(10),
> +		struct l_wait_info lwi = LWI_TIMEOUT(10 * HZ,
>  						     NULL, NULL);
>  
>  		rc = l_wait_event(svcpt->scp_waitq,
> @@ -2660,8 +2660,8 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
>  			 * of sluggish LNDs
>  			 */
>  			lwi = LWI_TIMEOUT_INTERVAL(
> -					cfs_time_seconds(LONG_UNLINK),
> -					cfs_time_seconds(1), NULL, NULL);
> +					LONG_UNLINK * HZ,
> +					HZ, NULL, NULL);
>  			rc = l_wait_event(svcpt->scp_waitq,
>  					  svcpt->scp_nrqbds_posted == 0, &lwi);
>  			if (rc == -ETIMEDOUT) {
> 
> 
> 
