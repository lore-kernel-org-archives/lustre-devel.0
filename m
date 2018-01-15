From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Mon, 15 Jan 2018 18:27:26 +0000
Subject: [lustre-devel] [bug report] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <20180115092657.om2gdrcwlajo2tvi@mwanda>
References: <20180115092657.om2gdrcwlajo2tvi@mwanda>
Message-ID: <9FC73D3DBECE0941BD2ED069D26863425CE75889@irsmsx110.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Dan,

The function kiblnd_destroy_conn() is conditionally free the conn pointer.

void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
{
[?]
                if (free_conn)
                               LIBCFS_FREE(conn, sizeof(*conn));
}

Therefore
>   3317                          kiblnd_destroy_conn(conn, !peer);
>                                                     ^^^^ Freed

Conditionally free if !peer.

>   3318
>   3319                          spin_lock_irqsave(lock, flags);
>   3320                          if (!peer)
>   3321                                  continue;
                                         ^^^^^^^^^^
Check for freed or not. If freed go to next loop.

>   3322
>   3323                          conn->ibc_peer = peer;
>                                 ^^^^^^^^^^^^^^ Use after free

This access is legal because of It was not freed.

Dmitry.
> -----Original Message-----
> From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf
> Of Dan Carpenter
> Sent: Monday, January 15, 2018 12:27 PM
> To: neilb at suse.com
> Cc: devel at driverdev.osuosl.org; lustre-devel at lists.lustre.org
> Subject: [lustre-devel] [bug report] staging: lustre: replace simple cases of
> LIBCFS_ALLOC with kzalloc.
> 
> [  This code was already buggy, it's just that Neil's change made it
>    show up in static analysis.  - dan ]
> 
> Hello NeilBrown,
> 
> The patch 3c88bdbbf919: "staging: lustre: replace simple cases of
> LIBCFS_ALLOC with kzalloc." from Jan 9, 2018, leads to the following static
> checker warning:
> 
> 	drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:3323
> kiblnd_connd()
> 	error: dereferencing freed memory 'conn'
> 
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
>   3303                  if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
>   3304                          struct kib_peer *peer = NULL;
>   3305
>   3306                          conn = list_entry(kiblnd_data.kib_connd_zombies.next,
>   3307                                            struct kib_conn, ibc_list);
>   3308                          list_del(&conn->ibc_list);
>   3309                          if (conn->ibc_reconnect) {
>   3310                                  peer = conn->ibc_peer;
>   3311                                  kiblnd_peer_addref(peer);
>   3312                          }
>   3313
>   3314                          spin_unlock_irqrestore(lock, flags);
>   3315                          dropped_lock = 1;
>   3316
>   3317                          kiblnd_destroy_conn(conn, !peer);
>                                                     ^^^^ Freed
> 
>   3318
>   3319                          spin_lock_irqsave(lock, flags);
>   3320                          if (!peer)
>   3321                                  continue;
>   3322
>   3323                          conn->ibc_peer = peer;
>                                 ^^^^^^^^^^^^^^ Use after free
> 
>   3324                          if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
>   3325                                  list_add_tail(&conn->ibc_list,
>                                                        ^^^^^^^^^^^^^^
> 
>   3326                                                &kiblnd_data.kib_reconn_list);
>   3327                          else
>   3328                                  list_add_tail(&conn->ibc_list,
>                                                        ^^^^^^^^^^^^^^
> 
>   3329                                                &kiblnd_data.kib_reconn_wait);
>   3330                  }
> 
> regards,
> dan carpenter
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--------------------------------------------------------------------
Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park,
17 Krylatskaya Str., Bldg 4, Moscow 121614,
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
