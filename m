From: Isaac Huang <He.Huang@Sun.COM>
Date: Tue, 17 Mar 2009 17:17:28 -0400
Subject: [Lustre-devel] Deadlock in usocklnd
In-Reply-To: <49BFFF1C.8080203@psc.edu>
References: <49BFFF1C.8080203@psc.edu>
Message-ID: <20090317211728.GV17185@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Mar 17, 2009 at 03:50:52PM -0400, Paul Nowoczynski wrote:
> Hi,
> I've got some code which uses ptlrpc and lnet and a few weeks ago we 
> integrated usocklnd into our environment. This lnd has been working 
> quite well and seems very efficient. The only issue so far is that we're 
> hitting a clear case of deadlock when trying to handle a failed 
> connection. I'm not sure if this code is actually in use by any lustre 
> component as of yet but I thought it best to bring this to your attention.
> paul

The usocklnd was completely rewritten some time ago, and the new code
hasn't been used at any Lustre major site as far as I know. It appeared
to me that you were using the new usocklnd.

It seemed to me that the deadlock had been triggered like:
1. usocklnd_poll_thread -> usocklnd_process_stale_list ->
usocklnd_tear_peer_conn: acquired &peer->up_lock.
2. Then with &peer->up_lock locked, usocklnd_tear_peer_conn -> 
usocklnd_destroy_txlist -> usocklnd_destroy_tx -> lnet_finalize ->
lnet_complete_msg_locked -> lnet_return_credits_locked ->
lnet_post_send_locked -> lnet_ni_send -> usocklnd_send ->
usocklnd_find_or_create_conn
3. And usocklnd_find_or_create_conn would try to acquire the same
&peer->up_lock again.

I'm not 100% certain about the sequence above, but generally it should 
be considered unsafe for a LND to call into LNet with a LND lock held
since LNet would likely call back into the LND again.

Paul, please file a bug and assign it to lustre-spider-team at sun.com
directly.

Thanks,
Isaac

> (gdb) bt
> #0 0x00002b3872336888 in __lll_mutex_lock_wait () from 
> /lib64/libpthread.so.0
> #1 0x00002b38723328a5 in _L_mutex_lock_107 () from /lib64/libpthread.so.0
> #2 0x00002b3872332333 in pthread_mutex_lock () from /lib64/libpthread.so.0
> #3 0x000000000049c9f5 in usocklnd_find_or_create_conn (peer=0x2695270, 
> type=0, connp=0x42803d30, tx=0x2aaad46f5d10, zc_ack=0x0,
> send_immediately=0x42803d2c) at 
> ..//../..//lnet-lite/ulnds/socklnd/conn.c:841
> #4 0x00000000004a2701 in usocklnd_send (ni=0x25e1810, private=0x0, 
> lntmsg=0x2aaacca1ace0) at 
> ..//../..//lnet-lite/ulnds/socklnd/usocklnd_cb.c:124
> #5 0x000000000048d886 in lnet_ni_send (ni=0x25e1810, msg=0x2aaacca1ace0) 
> at ..//../..//lnet-lite/lnet/lib-move.c:863
> #6 0x000000000048dd20 in lnet_post_send_locked (msg=0x2aaacca1ace0, 
> do_send=1) at ..//../..//lnet-lite/lnet/lib-move.c:951
> #7 0x000000000048dfb4 in lnet_return_credits_locked (msg=0x2aaacca1ae40) 
> at ..//../..//lnet-lite/lnet/lib-move.c:1108
> #8 0x0000000000494230 in lnet_complete_msg_locked (msg=0x2aaacca1ae40) 
> at ..//../..//lnet-lite/lnet/lib-msg.c:143
> #9 0x00000000004944f5 in lnet_finalize (ni=0x25e1810, 
> msg=0x2aaacca1ae40, status=-5) at ..//../..//lnet-lite/lnet/lib-msg.c:242
> #10 0x000000000049bff8 in usocklnd_destroy_tx (ni=0x25e1810, 
> tx=0x26950c0) at ..//../..//lnet-lite/ulnds/socklnd/conn.c:562
> #11 0x000000000049c02d in usocklnd_destroy_txlist (ni=0x25e1810, 
> txlist=0x2693650) at ..//../..//lnet-lite/ulnds/socklnd/conn.c:574
> #12 0x000000000049b09c in usocklnd_tear_peer_conn (conn=0x2692550) at 
> ..//../..//lnet-lite/ulnds/socklnd/conn.c:148
> #13 0x000000000049f5c8 in usocklnd_process_stale_list 
> (pt_data=0x25e1c98) at ..//../..//lnet-lite/ulnds/socklnd/poll.c:112
> #14 0x000000000049f7b2 in usocklnd_poll_thread (arg=0x25e1c98) at 
> ..//../..//lnet-lite/ulnds/socklnd/poll.c:169
> #15 0x0000000000450871 in psc_usklndthr_begin (arg=0x25e4370) at 
> ..//../..//psc_fsutil_libs/psc_util/usklndthr.c:16
> #16 0x000000000044f000 in _pscthr_begin (arg=0x7fff389980b0) at 
> ..//../..//psc_fsutil_libs/psc_util/thread.c:237
> #17 0x00002b38723302f7 in start_thread () from /lib64/libpthread.so.0
> #18 0x00002b387281fe3d in clone () from /lib64/libc.so.6
> (gdb) up
> #4 0x00000000004a2701 in usocklnd_send (ni=0x25e1810, private=0x0, 
> lntmsg=0x2aaacca1ace0) at 
> ..//../..//lnet-lite/ulnds/socklnd/usocklnd_cb.c:124
> 124 rc = usocklnd_find_or_create_conn(peer, type, &conn, tx, NULL,
> (gdb) print *peer
> $4 = {up_list = {next = 0x6e1b08, prev = 0x6e1b08}, up_peerid = {nid = 
> 562954416842067, pid = 2147520945}, up_conns = {0x2692550, 0x0, 0x0},
> up_ni = 0x25e1810, up_incarnation = 0, up_incrn_is_set = 0, up_refcount 
> = {counter = 3}, up_lock = {__data = {__lock = 2, __count = 0, __owner = 
> 23283,
> __nusers = 1, __kind = 0, __spins = 0, __list = {__prev = 0x0, __next = 
> 0x0}},
> __size = "\002\000\000\000\000\000\000\000???Z\000\000\001", '\0' <repeats 
> 26 times>, __align = 2}, up_errored = 0, up_last_alive = 0}
> (gdb)
> 
> ## We're waiting for a lock which we already hold!
> * 6 Thread 1115703616 (LWP 23283) 0x00002b3872336888 in 
> __lll_mutex_lock_wait () from /lib64/libpthread.so.0
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
