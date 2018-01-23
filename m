From: Zhen, Liang <liang.zhen@intel.com>
Date: Tue, 23 Jan 2018 09:25:41 +0000
Subject: [lustre-devel] [bug report] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <D6E57F1D-7686-43A5-A8E2-ED9CC29B3D0F@intel.com>
References: <20180115092657.om2gdrcwlajo2tvi@mwanda>
 <87r2qh83np.fsf@notabene.neil.brown.name>
 <D6E57F1D-7686-43A5-A8E2-ED9CC29B3D0F@intel.com>
Message-ID: <4EDC2CF6-F999-4B09-B7CE-71281845F6F6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi, I just realized the ?free_conn? parameter is unused in kernel source, but it?s actually used in the original patch: https://review.whamcloud.com/#/c/17892  , so I think it should be fixed in the kernel.

Regards
Liang

On 23/01/2018, 4:02 PM, "Zhen, Liang" <liang.zhen@intel.com> wrote:

    Hi there, probably the function name is misleading, but 
    
    L3317: kiblnd_destroy_conn(conn, !peer);
    
    This function will NOT free the connection if peer is NULL, and?
    
    L3320:    if (!peer)
    L3321                  continue;
    
    It means the connection is not freed in L3322 and later.
    
    Regards
    Liang
    
    On 23/01/2018, 2:55 PM, "NeilBrown" <neilb@suse.com> wrote:
    
        On Mon, Jan 15 2018, Dan Carpenter wrote:
        
        > [  This code was already buggy, it's just that Neil's change made it
        >    show up in static analysis.  - dan ]
        
        Thanks!
        
        This bug was introduced by
        
         Commit: 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
        
        which added a "free_conn" arg to kiblnd_destroy_conn(), but never used
        the arg.  Presumably it is meant to say "Don't free something", but
        exactly what should be free and what shouldn't isn't immediately clear.
        
        Liang:  do you remember what you intended for that arg to do?
        
        Thanks,
        NeilBrown
        
        >
        > Hello NeilBrown,
        >
        > The patch 3c88bdbbf919: "staging: lustre: replace simple cases of
        > LIBCFS_ALLOC with kzalloc." from Jan 9, 2018, leads to the following
        > static checker warning:
        >
        > 	drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:3323 kiblnd_connd()
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
        >                                                     ^^^^
        > Freed
        >
        >   3318  
        >   3319                          spin_lock_irqsave(lock, flags);
        >   3320                          if (!peer)
        >   3321                                  continue;
        >   3322  
        >   3323                          conn->ibc_peer = peer;
        >                                 ^^^^^^^^^^^^^^
        > Use after free
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
        
    
    
