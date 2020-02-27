From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:48 -0500
Subject: [lustre-devel] [PATCH 000/622] lustre: sync closely to 2.13.52
Message-ID: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These patches need to be applied to the lustre-backport branch
starting at commit a436653f641e4b3e2841f38113620535e918dd3f.
Combining the work of Neil and myself this brings the lustre
linux client up to just btefore the he landing of Direct I/O
(LU-4198) support. Testing shows this work is pretty stable.

Alex Zhuravlev (19):
  lustre: ptlrpc: idle connections can disconnect
  lustre: osc: serialize access to idle_timeout vs cleanup
  lustre: protocol: MDT as a statfs proxy
  lustre: ptlrpc: new request vs disconnect race
  lustre: ldlm: pass preallocated env to methods
  lustre: mdc: use old statfs format
  lustre: osc: re-check target versus available grant
  lustre: ptlrpc: reset generation for old requests
  lustre: osc: propagate grant shrink interval immediately
  lustre: osc: grant shrink shouldn't account skipped OSC
  lnet: libcfs: poll fail_loc in cfs_fail_timeout_set()
  lustre: obdclass: put all service's env on the list
  lustre: obdclass: use RCU to release lu_env_item
  lustre: obd: add rmfid support
  lustre: mdc: polling mode for changelog reader
  lustre: llite: forget cached ACLs properly
  lustre: ptlrpc: return proper error code
  lustre: llite: statfs to use NODELAY with MDS
  lustre: ptlrpc: suppress connection restored message

Alexander Boyko (9):
  lustre: ldlm: fix l_last_activity usage
  lustre: ptlrpc: don't zero request handle
  lustre: mgc: don't proccess cld during stopping
  lustre: llog: add startcat for wrapped catalog
  lustre: llog: add synchronization for the last record
  lustre: mdc: don't use ACL at setattr
  lnet: adds checking msg len
  lustre: llite: prevent mulitple group locks
  lustre: obdclass: don't skip records for wrapped catalog

Alexander Zarochentsev (4):
  lustre: llite: ll_fault should fail for insane file offsets
  lustre: osc: don't re-enable grant shrink on reconnect
  lustre: ptlrpc: grammar fix.
  lustre: osc: glimpse and lock cancel race

Alexey Lyashkov (10):
  lustre: lu_object: improve debug message for lu_object_put()
  lnet: use right rtr address
  lnet: use right address for routing message
  lustre: mdc: reset lmm->lmm_stripe_offset in mdc_save_lovea
  lustre: obdecho: reuse an cl env cache for obdecho survey
  lustre: obdecho: avoid panic with partially object init
  lustre: mgc: config lock leak
  lnet: fix rspt counter
  lnet: lnet response entries leak
  lnet: avoid extra memory consumption

Alexey Zhuravlev (1):
  lustre: grant: prevent overflow of o_undirty

Amir Shehata (87):
  lnet: ko2iblnd: determine gaps correctly
  lnet: refactor lnet_select_pathway()
  lnet: add health value per ni
  lnet: add lnet_health_sensitivity
  lnet: add monitor thread
  lnet: handle local ni failure
  lnet: handle o2iblnd tx failure
  lnet: handle socklnd tx failure
  lnet: handle remote errors in LNet
  lnet: add retry count
  lnet: calculate the lnd timeout
  lnet: sysfs functions for module params
  lnet: timeout delayed REPLYs and ACKs
  lnet: remove duplicate timeout mechanism
  lnet: handle fatal device error
  lnet: reset health value
  lnet: add health statistics
  lnet: Add ioctl to get health stats
  lnet: remove obsolete health functions
  lnet: set health value from user space
  lnet: add global health statistics
  lnet: print recovery queues content
  lnet: health error simulation
  lnet: lnd: conditionally set health status
  lnet: router handling
  lnet: update logging
  lnet: lnd: Clean up logging
  lnet: unlink md if fail to send recovery
  lnet: set the health status correctly
  lnet: Decrement health on timeout
  lnet: properly error check sensitivity
  lnet: configure recovery interval
  lnet: separate ni state from recovery
  lnet: handle multi-md usage
  lnet: socklnd: improve scheduling algorithm
  lnet: lnd: increase CQ entries
  lnet: lnd: bring back concurrent_sends
  lnet: use number of wrs to calculate CQEs
  lnet: recovery event handling broken
  lnet: clean mt_eqh properly
  lnet: handle remote health error
  lnet: setup health timeout defaults
  lnet: fix cpt locking
  lnet: detach response tracker
  lnet: invalidate recovery ping mdh
  lnet: fix list corruption
  lnet: correct discovery LNetEQFree()
  lnet: verify msg is commited for send/recv
  lnet: select LO interface for sending
  lnet: remove route add restriction
  lnet: Discover routers on first use
  lnet: use peer for gateway
  lnet: lnet_add/del_route()
  lnet: Do not allow deleting of router nis
  lnet: router sensitivity
  lnet: cache ni status
  lnet: Cache the routing feature
  lnet: peer aliveness
  lnet: router aliveness
  lnet: simplify lnet_handle_local_failure()
  lnet: Cleanup rcd
  lnet: modify lnd notification mechanism
  lnet: use discovery for routing
  lnet: MR aware gateway selection
  lnet: consider alive_router_check_interval
  lnet: allow deleting router primary_nid
  lnet: transfer routers
  lnet: handle health for incoming messages
  lnet: misleading discovery seqno.
  lnet: drop all rule
  lnet: handle discovery off
  lnet: handle router health off
  lnet: push router interface updates
  lnet: net aliveness
  lnet: discover each gateway Net
  lnet: look up MR peers routes
  lnet: check peer timeout on a router
  lnet: prevent loop in LNetPrimaryNID()
  lnet: fix peer ref counting
  lnet: honor discovery setting
  lnet: warn if discovery is off
  lnet: handle unlink before send completes
  lnet: handle recursion in resend
  lnet: discovery off route state update
  lnet: o2iblnd: cache max_qp_wr
  lnet: fix peer_ni selection
  lnet: peer lookup handle shutdown

Andreas Dilger (55):
  lustre: llite: increase whole-file readahead to RPC size
  lustre: mdc: fix possible NULL pointer dereference
  lustre: obdclass: allow specifying complex jobids
  lustre: idl: remove obsolete directory split flags
  lustre: obdecho: use vmalloc for lnb
  lustre: mgc: remove obsolete IR swabbing workaround
  lustre: mds: remove obsolete MDS_VTX_BYPASS flag
  lustre: ptlrpc: fix return type of boolean functions
  lustre: ptlrpc: remove obsolete OBD RPC opcodes
  lustre: ptlrpc: assign specific values to MGS opcodes
  lustre: ptlrpc: remove obsolete LLOG_ORIGIN_* RPCs
  lustre: obdclass: remove unused ll_import_cachep
  lustre: ptlrpc: add debugging for idle connections
  lustre: mdc: move RPC semaphore code to lustre/osp
  lustre: misc: name open file handles as such
  lustre: osc: move obdo_cache to OSC code
  lustre: idl: remove obsolete RPC flags
  lustre: osc: clarify short_io_bytes is maximum value
  lustre: misc: quiet console messages at startup
  lustre: idl: use proper ATTR/MDS_ATTR/MDS_OPEN flags
  lustre: lov: add debugging info for statfs
  lustre: hsm: make changelog flag argument an enum
  lustre: uapi: fix warnings when lustre_user.h included
  lustre: ptlrpc: clean up rq_interpret_reply callbacks
  lustre: lov: quiet lov_dump_lmm_ console messages
  lustre: llite: remove cl_file_inode_init() LASSERT
  lnet: libcfs: allow file/func/line passed to CDEBUG()
  lustre: llite: enable flock mount option by default
  lustre: lmv: avoid gratuitous 64-bit modulus
  lustre: Ensure crc-t10pi is enabled.
  lustre: lov: avoid signed vs. unsigned comparison
  lustre: llite: limit statfs ffree if less than OST ffree
  lustre: misc: delete OBD_IOC_PING_TARGET ioctl
  lustre: misc: remove LIBCFS_IOC_DEBUG_MASK ioctl
  lustre: obdclass: improve llog config record message
  lustre: ptlrpc: allow stopping threads above threads_max
  lustre: llite: improve max_readahead console messages
  lustre: uapi: fix file heat support
  lustre: mdt: improve IBITS lock definitions
  lustre: obdclass: don't send multiple statfs RPCs
  lustre: uapi: add unused enum obd_statfs_state
  lustre: mdc: hold lock while walking changelog dev list
  lustre: ptlrpc: make DEBUG_REQ messages consistent
  lustre: obdclass: align to T10 sector size when generating guard
  lustre: ptlrpc: fix watchdog ratelimit logic
  lustre: llite: clear flock when using localflock
  lustre: llite: limit max xattr size by kernel value
  lustre: llite: report latency for filesystem ops
  lustre: osc: allow increasing osc.*.short_io_bytes
  lustre: ptlrpc: update wiretest for new values
  lustre: uapi: LU-12521 llapi: add separate fsname and instance API
  lustre: ptlrpc: show target name in req_history
  lustre: llite: proper names/types for offset/pages
  lustre: uapi: remove unused LUSTRE_DIRECTIO_FL
  lnet: use conservative health timeouts

Andrew Perepechko (5):
  lustre: build: armv7 client build fixes
  lustre: osc: speed up page cache cleanup during blocking ASTs
  lustre: ptlrpc: improve memory allocation for service RPCs
  lustre: llite: optimizations for not granted lock processing
  lnet: libcfs: crashes with certain cpu part numbers

Andriy Skulysh (16):
  lustre: ptlrpc: ptlrpc_register_bulk() LBUG on ENOMEM
  lustre: ptlrpc: Serialize procfs access to scp_hist_reqs using mutex
  lustre: ptlrpc: ASSERTION(!list_empty(imp->imp_replay_cursor))
  lustre: ptlrpc: connect vs import invalidate race
  lnet: o2iblnd: ibc_rxs is created and freed with different size
  lustre: ldlm: Lost lease lock on migrate error
  lnet: o2iblnd: kib_conn leak
  lustre: ptlrpc: Bulk assertion fails on -ENOMEM
  lustre: ptlrpc: ASSERTION (req_transno < next_transno) failed
  lustre: ptlrpc: ocd_connect_flags are wrong during reconnect
  lustre: ptlrpc: Add increasing XIDs CONNECT2 flag
  lustre: ptlrpc: don't reset lru_resize on idle reconnect
  lustre: ptlrpc: resend may corrupt the data
  lustre: ldlm: FLOCK request can be processed twice
  lustre: ldlm: signal vs CP callback race
  lustre: llite: eviction during ll_open_cleanup()

Ann Koehler (8):
  lustre: llite: yield cpu after call to ll_agl_trigger
  lustre: ptlrpc: Do not map unrecognized ELDLM errnos to EIO
  lustre: llite: Lock inode on tiny write if setuid/setgid set
  lustre: statahead: sa_handle_callback get lli_sa_lock earlier
  lustre: ptlrpc: Add jobid to rpctrace debug messages
  lnet: libcfs: Reduce memory frag due to HA debug msg
  lustre: llite: release active extent on sync write commit
  lustre: ptlrpc: ptlrpc_register_bulk LBUG on ENOMEM

Arshad Hussain (17):
  lustre: osc: truncate does not update blocks count on client
  lustre: lmv: Fix style issues for lmv_fld.c
  lustre: llite: Fix style issues for llite_nfs.c
  lustre: llite: Fix style issues for lcommon_misc.c
  lustre: llite: Fix style issues for symlink.c
  lustre: ptlrpc: Change static defines to use macro for sec_gc.c
  lustre: ldlm: Fix style issues for ldlm_lockd.c
  lustre: ldlm: Fix style issues for ldlm_request.c
  lustre: ptlrpc: Fix style issues for sec_bulk.c
  lustre: ldlm: Fix style issues for ptlrpcd.c
  lustre: ptlrpc: Fix style issues for sec_null.c
  lustre: ptlrpc: Fix style issues for service.c
  lustre: ldlm: Fix style issues for ldlm_resource.c
  lustre: ptlrpc: Fix style issues for sec_gc.c
  lustre: ptlrpc: Fix style issues for llog_client.c
  lnet: Change static defines to use macro for module.c
  lustre: ldlm: Fix style issues for ldlm_lib.c

Artem Blagodarenko (1):
  lnet: add fault injection for bulk transfers

Aurelien Degremont (1):
  lnet: support non-default network namespace

Ben Evans (1):
  lustre: headers: define pct(a,b) once

Bobi Jam (11):
  lustre: osc: depart grant shrinking from pinger
  lustre: osc: enable/disable OSC grant shrink
  lustre: flr: add 'nosync' flag for FLR mirrors
  lustre: mdc: grow lvb buffer to hold layout
  lustre: flr: add mirror write command
  lustre: llite: protect reading inode->i_data.nrpages
  lustre: osc: limit chunk number of write submit
  lustre: osc: prevent use after free
  lustre: llite: error handling of ll_och_fill()
  lustre: flr: avoid reading unhealthy mirror
  lustre: llite: file write pos mimatch

Bruno Faccini (6):
  lustre: obdclass: fix llog_cat_cleanup() usage on Client
  lustre: ptlrpc: fix test_req_buffer_pressure behavior
  lustre: ldlm: cleanup LVB handling
  lustre: security: return security context for metadata ops
  lustre: lov: new foreign LOV format
  lustre: lmv: new foreign LMV format

Chris Horn (28):
  lnet: Cleanup lnet_get_rtr_pool_cfg
  lnet: Fix NI status in debugfs for loopback ni
  lustre: ptlrpc: Add more flags to DEBUG_REQ_FLAGS macro
  lnet: Protect lp_dc_pendq manipulation with lp_lock
  lnet: Ensure md is detached when msg is not committed
  lnet: Do not allow gateways on remote nets
  lnet: Convert noisy timeout error to cdebug
  lnet: Misleading error from lnet_is_health_check
  lnet: Sync the start of discovery and monitor threads
  lnet: Deprecate live and dead router check params
  lnet: Detach rspt when md_threshold is infinite
  lnet: Return EHOSTUNREACH for unreachable gateway
  lnet: Defer rspt cleanup when MD queued for unlink
  lnet: Don't queue msg when discovery has completed
  lnet: Use alternate ping processing for non-mr peers
  lnet: o2ib: Record rc in debug log on startup failure
  lnet: o2ib: Reintroduce kiblnd_dev_search
  lnet: Optimize check for routing feature flag
  lnet: Wait for single discovery attempt of routers
  lnet: Prefer route specified by rtr_nid
  lnet: Add peer level aliveness information
  lnet: Refactor lnet_find_best_lpni_on_net
  lnet: Avoid comparing route to itself
  lnet: Avoid extra lnet_remotenet lookup
  lnet: Remove unused vars in lnet_find_route_locked
  lnet: Refactor lnet_compare_routes
  lnet: Fix source specified route selection
  lnet: Do not assume peers are MR capable

Christopher J. Morrone (1):
  lustre: ldlm: Make kvzalloc | kvfree use consistent

Di Wang (1):
  lustre: llite: handle ORPHAN/DEAD directories

Emoly Liu (4):
  lnet: fix nid range format '*@<net>' support
  lustre: checksum: enable/disable checksum correctly
  lustre: ptlrpc: check lm_bufcount and lm_buflen
  lustre: ptlrpc: check buffer length in lustre_msg_string()

Fan Yong (3):
  lustre: llite: return compatible fsid for statfs
  lustre: llite: decrease sa_running if fail to start statahead
  lustre: lfsck: layout LFSCK for mirrored file

Gu Zheng (3):
  lustre: osc: cancel osc_lock list traversal once found the lock is
    being used
  lustre: ldlm: always cancel aged locks regardless enabling or
    disabling lru resize
  lustre: uapi: fix building fail against Power9 little endian

Hongchao Zhang (8):
  lustre: mdc: resend quotactl if needed
  lustre: quota: add default quota setting support
  lustre: ptlrpc: race in AT early reply
  lustre: ptlrpc: always unregister bulk
  lustre: quota: protect quota flags at OSC
  lustre: quota: make overquota flag for old req
  lustre: fld: let's caller to retry FLD_QUERY
  lustre: mdc: hold obd while processing changelog

Jacek Tomaka (1):
  lustre: llite: Mark lustre_inode_cache as reclaimable

Jadhav Vikram (1):
  lustre: lov: protected ost pool count updation

James Nunez (1):
  lustre: llite: limit smallest max_cached_mb value

James Simmons (33):
  lustre: always enable special debugging, fhandles, and quota support.
  lustre: osc_cache: remove __might_sleep()
  lustre: uapi: remove enum hsm_progress_states
  lustre: uapi: sync enum obd_statfs_state
  lustre: obd: create ping sysfs file
  lustre: ldlm: change LDLM_POOL_ADD_VAR macro to inline function
  lustre: osc: fix idle_timeout handling
  lustre: ptlrpc: replace simple_strtol with kstrtol
  lustre: obd: use correct ip_compute_csum() version
  lustre: llite: create checksums to replace checksum_pages
  lustre: obd: use correct names for conn_uuid
  lustre: mgc: restore mgc binding for sptlrpc
  lustre: update version to 2.11.99
  lustre: obdclass: report all obd states for OBD_IOC_GETDEVICE
  lustre: sysfs: make ping sysfs file read and writable
  lustre: sptlrpc: split sptlrpc_process_config()
  lustre: clio: fix incorrect invariant in cl_io_iter_fini()
  lustre: obd: use ldo_process_config for mdc and osc layer
  lustre: obd: make health_check sysfs compliant
  lnet: properly cleanup lnet debugfs files
  lustre: obd: update udev event handling
  lustre: obd: replace class_uuid with linux kernel version.
  lustre: obd: round values to nearest MiB for *_mb syfs files
  lustre: obdclass: add comment for rcu handling in lu_env_remove
  lustre: ptlrpc: change IMPORT_SET_* macros into real functions
  lustre: obd: harden debugfs handling
  lustre: update version to 2.13.50
  lnet: timers: correctly offset mod_timer.
  lustre: obd: perform proper division
  lustre: llite: don't cache MDS_OPEN_LOCK for volatile files
  lnet: socklnd: rename struct ksock_peer to struct ksock_peer_ni
  lustre: sysfs: use string helper like functions for sysfs
  lustre: uapi: properly pack data structures

Jian Yu (4):
  lustre: mdt: revoke lease lock for truncate
  lustre: llite: swab LOV EA user data
  lustre: llite: swab LOV EA data in ll_getxattr_lov()
  lustre: llite: fetch default layout for a directory

Jinshan Xiong (4):
  lustre: llite: rename FSFILT_IOC_* to system flags
  lustre: llite: optimize read on open pages
  lustre: dne: performance improvement for file creation
  lustre: llite: do not cache write open lock for exec file

John L. Hammond (12):
  lustre: llite: reorganize variable and data structures
  lustre: hsm: ignore compound_id
  lustre: llog: remove obsolete llog handlers
  lustre: obd: keep dirty_max_pages a round number of MB
  lustre: llite: handle zero length xattr values correctly
  lustre: mdc: remove obsolete intent opcodes
  lustre: ldlm: correct logic in ldlm_prepare_lru_list()
  lustre: llite: zero lum for stripeless files
  lustre: mdc: move empty xattr handling to mdc layer
  lustre: obd: remove portals handle from OBD import
  lustre: llite: handle -ENODATA in ll_layout_fetch()
  lustre: ldlm: remove trace from ldlm_pool_count()

Kit Westneat (1):
  lnet: remove .nf_min_max handling

Lai Siyao (27):
  lustre: ptlrpc: add dir migration connect flag
  lustre: lmv: dir page is released while in use
  lustre: migrate: pack lmv ea in migrate rpc
  lustre: migrate: migrate striped directory
  lustre: lmv: support accessing migrating directory
  lustre: llite: add lock for dir layout data
  lustre: lmv: allocate fid on parent MDT in migrate
  lustre: obdclass: lu_dirent record length missing '0'
  lustre: uapi: reserve connect flag for plain layout
  lustre: dne: allow access to striped dir with broken layout
  lustre: dne: add new dir hash type "space"
  lustre: ptlrpc: intent_getattr fetches default LMV
  lustre: mdc: add async statfs
  lustre: lmv: mkdir with balanced space usage
  lustre: lmv: reuse object alloc QoS code from LOD
  lustre: obdclass: generate random u64 max correctly
  lustre: uapi: change "space" hash type to hash flag
  lustre: obdclass: 0-nlink race in lu_object_find_at()
  lustre: mdc: dir page ldp_hash_end mistakenly adjusted
  lustre: lmv: disable remote file statahead
  lustre: lmv: use lu_tgt_descs to manage tgts
  lustre: lmv: share object alloc QoS code with LMV
  lustre: obdclass: qos penalties miscalculated
  lustre: obdclass: lu_tgt_descs cleanup
  lustre: lmv: alloc dir stripes by QoS
  lustre: uapi: introduce OBD_CONNECT2_CRUSH
  lustre: llite: fix deadlock in ll_update_lsm_md()

Li Dongyang (9):
  lustre: ldlm: check double grant race after resource change
  lustre: clio: use pagevec_release for many pages
  lustre: osc: reduce atomic ops in osc_enter_cache_try
  lustre: osc: check if opg is in lru list without locking
  lustre: osc: don't check capability for every page
  lustre: osc: reduce lock contention in osc_unreserve_grant
  lustre: obdclass: protect imp_sec using rwlock_t
  lustre: llite: create obd_device with usercopy whitelist
  lustre: obdclass: remove assertion for imp_refcount

Li Xi (6):
  lustre: osc: add T10PI support for RPC checksum
  lustre: osc: wrong page offset for T10PI checksum
  lustre: llite: add file heat support
  lustre: llite: console message for disabled flock call
  lustre: llite: cleanup stats of LPROC_LL_*
  lustre: osc: add preferred checksum type support

Liang Zhen (2):
  lustre: ldlm: don't disable softirq for exp_rpc_lock
  lustre: obdclass: new wrapper to convert NID to string

Mike Marciniszyn (1):
  lnet: libcfs: remove unnecessary set_fs(KERNEL_DS)

Mikhail Pershin (28):
  lustre: mdc: deny layout swap for DoM file
  lustre: ldlm: expose dirty age limit for flush-on-glimpse
  lustre: ldlm: IBITS lock convert instead of cancel
  lustre: ptlrpc: add LOCK_CONVERT connection flag
  lustre: ldlm: handle lock converts in cancel handler
  lustre: ldlm: don't add canceling lock back to LRU
  lustre: mdt: read on open for DoM files
  lustre: llite: check truncate race for DOM pages
  lustre: ldlm: don't cancel DoM locks before replay
  lustre: ptlrpc: don't change buffer when signature is ready
  lustre: ldlm: update l_blocking_lock under lock
  lustre: ldlm: don't apply ELC to converting and DOM locks
  lustre: ldlm: don't skip bl_ast for local lock
  lustre: mdt: fix read-on-open for big PAGE_SIZE
  lustre: ldlm: don't convert wrong resource
  lustre: mdc: prevent glimpse lock count grow
  lustre: mdc: return DOM size on open resend
  lustre: osc: pass client page size during reconnect too
  lustre: mdt: fix mdt_dom_discard_data() timeouts
  lustre: dom: per-resource ELC for WRITE lock enqueue
  lustre: dom: mdc_lock_flush() improvement
  lustre: obdclass: remove unprotected access to lu_object
  lustre: llite: check correct size in ll_dom_finish_open()
  lustre: ptlrpc: fix reply buffers shrinking and growing
  lustre: dom: manual OST-to-DOM migration via mirroring
  lustre: ptlrpc: do lu_env_refill for any new request
  lustre: dom: check read-on-open buffer presents in reply
  lustre: llog: keep llog handle alive until last reference

Mr NeilBrown (47):
  lustre: obdclass: allow per-session jobids.
  lustre: fld: remove fci_no_shrink field.
  lustre: lustre: remove ldt_obd_type field of lu_device_type
  lustre: lustre: remove imp_no_timeout field
  lustre: llog: remove olg_cat_processing field.
  lustre: ptlrpc: remove struct ptlrpc_bulk_page
  lustre: ptlrpc: remove bd_import_generation field.
  lustre: ptlrpc: remove srv_threads from struct ptlrpc_service
  lustre: ptlrpc: remove scp_nthrs_stopping field.
  lustre: ldlm: remove unused ldlm_server_conn
  lustre: llite: remove lli_readdir_mutex
  lustre: llite: remove ll_umounting field
  lustre: llite: align field names in ll_sb_info
  lustre: llite: remove lti_iter field
  lustre: llite: remove ft_mtime field
  lustre: llite: remove sub_reenter field.
  lustre: osc: remove oti_descr oti_handle oti_plist
  lustre: osc: remove oe_next_page
  lnet: o2iblnd: remove some unused fields.
  lnet: socklnd: remove ksnp_sharecount
  lnet: change ln_mt_waitq to a completion.
  lustre: import: Fix missing spin_unlock()
  lustre: use simple sleep in some cases
  lustre: modules: Use LIST_HEAD for declaring list_heads
  lnet: remove pt_number from lnet_peer_table.
  lustre: obdclass: Allow read-ahead for write requests
  lnet: discard lnd_refcount
  lnet: change ksocknal_create_peer() to return pointer
  lnet: discard ksnn_lock
  lnet: discard LNetMEInsert
  lustre: all: prefer sizeof(*var) for alloc
  lnet: always check return of try_module_get()
  lnet: prepare to make lnet_lnd const.
  lnet: discard struct ksock_peer
  lnet: socklnd: initialize the_ksocklnd at compile-time.
  lnet: remove locking protection ln_testprotocompat
  lustre: handle: remove locking from class_handle2object()
  lustre: obdclass: convert waiting in cl_sync_io_wait().
  lnet: modules: use list_move were appropriate.
  lnet: fix small race in unloading klnd modules.
  lnet: me: discard struct lnet_handle_me
  lnet: socklnd: convert peers hash table to hashtable.h
  lustre: ptlrpc: simplify wait_event handling in unregister functions
  lustre: ptlrpc: use l_wait_event_abortable in ptlrpcd_add_reg()
  lnet: use LIST_HEAD() for local lists.
  lustre: lustre: use LIST_HEAD() for local lists.
  lnet: remove lnd_query interface.

Nathaniel Clark (1):
  lustre: lov: Correct bounds checking

NeilBrown (18):
  lustre: llite: Don't clear d_fsdata in ll_release()
  lustre: llite: move agl_thread cleanup out of thread.
  lustre/lnet: remove unnecessary use of msecs_to_jiffies()
  lnet: net_fault: don't pass struct member to do_div()
  lustre: obd: discard unused enum
  lustre: lov: use wait_event() in lov_subobject_kill()
  lustre: llite: use wait_event in cl_object_put_last()
  lustre: handle: move refcount into the lustre_handle.
  lustre: ldlm: separate buckets from ldlm hash table
  lustre: handle: discard OBD_FREE_RCU
  lnet: use list_move where appropriate.
  lustre: ldlm: add a counter to the per-namespace data
  lustre: rename ops to owner
  lustre: ldlm: simplify ldlm_ns_hash_defs[]
  lustre: u_object: factor out extra per-bucket data
  lustre: llite: replace lli_trunc_sem
  lustre: handle: use hlist for hash lists.
  lustre: handle: discard h_lock.

Olaf Faaland (2):
  lnet: create existing net returns EEXIST
  lustre: llite: Update mdc and lite stats on open|creat

Olaf Weber (1):
  lnet: use after free in lnet_discover_peer_locked()

Oleg Drokin (6):
  lustre: ptlrpc: Add WBC connect flag
  lustre: lov: Move lov_tgts_kobj init to lov_setup
  lustre: osc: increase default max_dirty_mb to 2G
  lustre: llite: Revalidate dentries in ll_intent_file_open
  lustre: llite: hash just created files if lock allows
  lustre: ptlrpc: Properly swab ll_fiemap_info_key

Patrick Farrell (30):
  lustre: osc: Do not request more than 2GiB grant
  lustre: ldlm: Reduce debug to console during eviction
  lustre: ptlrpc: Make CPU binding switchable
  lustre: osc: Do not walk full extent list
  lustre: ldlm: Adjust search_* functions
  lustre: mdc: Improve xattr buffer allocations
  lustre: llite: Initialize cl_dirty_max_pages
  lustre: llite: ll_fault fixes
  lustre: osd: Set max ea size to XATTR_SIZE_MAX
  lustre: lov: Remove unnecessary assert
  lustre: obd: Add overstriping CONNECT flag
  lustre: lov: Add overstriping support
  lustre: uapi: Add nonrotational flag to statfs
  lustre: llite: collect debug info for ll_fsync
  lustre: lu_object: Add missed qos_rr_init
  lustre: osc: Do not assert for first extent
  lustre: ptlrpc: Don't get jobid in body_v2
  lustre: lov: Correct write_intent end for trunc
  lustre: osc: Fix dom handling in weight_ast
  lustre: llite: Fix extents_stats
  lustre: ptlrpc: Stop sending ptlrpc_body_v2
  lustre: uapi: Remove unused CONNECT flag
  lustre: llite: Fix page count for unaligned reads
  lustre: llite: Improve readahead RPC issuance
  lustre: lov: Move page index to top level
  lustre: ptlrpc: Hold imp lock for idle reconnect
  lustre: osc: glimpse - search for active lock
  lnet: o2iblnd: Make credits hiw connection aware
  lustre: vvp: dirty pages with pagevec
  lustre: llite: Accept EBUSY for page unaligned read

Qian Yingjin (16):
  lustre: mdt: Lazy size on MDT
  lustre: uapi: add new changerec_type
  lustre: lsom: Add an OBD_CONNECT2_LSOM connect flag
  lustre: pcc: Reserve a new connection flag for PCC
  lustre: rpc: support maximum 64MB I/O RPC
  lustre: llite: Add persistent cache on client
  lustre: pcc: Non-blocking PCC caching
  lustre: pcc: security and permission for non-root user access
  lustre: llite: Rule based auto PCC caching when create files
  lustre: pcc: auto attach during open for valid cache
  lustre: pcc: change detach behavior and add keep option
  lustre: som: integrate LSOM with lfs find
  lustre: pcc: Auto attach for PCC during IO
  lustre: pcc: Incorrect size after re-attach
  lustre: pcc: auto attach not work after client cache clear
  lustre: pcc: Init saved dataset flags properly

Quentin Bouget (1):
  lustre: uapi: turn struct lustre_nfs_fid to userland fhandle

Rahul Deshmukh (1):
  lustre: obdecho: turn on async flag only for mode 3

Rob Latham (1):
  lustre: uapi: Make lustre_user.h c++-legal

Ryan Haasken (1):
  lustre: obdclass: Add lbug_on_eviction option

Sebastien Buisson (7):
  lustre: obd: check '-o network' and peer discovery conflict
  lustre: cfg: reserve flags for SELinux status checking
  lustre: sec: create new function sptlrpc_get_sepol()
  lnet: check for asymmetrical route messages
  lustre: ptlrpc: manage SELinux policy info at connect time
  lustre: ptlrpc: manage SELinux policy info for metadata ops
  lustre: sec: reserve flags for client side encryption

Sergey Cheremencev (1):
  lustre: ptlrpc: IR doesn't reconnect after EAGAIN

Shaun Tancheff (7):
  lustre: lov: return error if cl_env_get fails
  lustre: llite: MS_* flags and SB_* flags split
  lustre: clio: support custom csi_end_io handler
  lnet: Fix style issues for selftest/rpc.c
  lnet: Fix style issues for module.c conctl.c
  lnet: libcfs: provide an scnprintf and start using it
  lnet: libcfs: Cleanup use of bare printk

Sonia Sharma (6):
  lnet: Fix selftest backward compatibility post health
  lnet: socklnd: dynamically set LND parameters
  lnet: peer deletion code may hide error
  lnet: increase lnet transaction timeout
  lnet: Avoid lnet debugfs read/write if ctl_table does not exist
  lnet: check if current->nsproxy is NULL before using

Swapnil Pimpale (1):
  lustre: lustre: Reserve OST_FALLOCATE(fallocate) opcode

Tatsushi Takamura (1):
  lnet: handling device failure by IB event handler

Teddy Chan (1):
  lustre: ptlrpc: Add QoS for uid and gid in NRS-TBF

Teddy Zheng (2):
  lustre: hsm: add OBD_CONNECT2_ARCHIVE_ID_ARRAY to pass archive_id
    lists in array
  lustre: hsm: increase upper limit of maximum HSM backends registered
    with MDT

Vitaly Fertman (6):
  lustre: ptlrpc: Add more flags to DEBUG_REQ_FLAGS macro
  lustre: ldlm: layout lock fixes
  lustre: osc: layout and chunkbits alignment mismatch
  lustre: osc: wrong cache of LVB attrs
  lustre: osc: wrong cache of LVB attrs, part2
  lustre: ldlm: fix lock convert races

Vladimir Saveliev (6):
  lustre: obdclass: make mod rpc slot wait queue FIFO
  lustre: lov: fix lov_iocontrol for inactive OST case
  lnet: libcfs: do not calculate debug_mb if it is set
  lustre: llite: improve ll_dom_lock_cancel
  lustre: lov: check all entries in lov_flush_composite
  lustre: lmv: disable statahead for remote objects

Wang Shilong (24):
  lustre: llite: fix setstripe for specific osts upon dir
  lnet: libcfs: fix wrong check in libcfs_debug_vmsg2()
  lustre: quota: fix setattr project check
  lustre: llite: make sure name pack atomic
  lustre: ptlrpc: handle proper import states for recovery
  lustre: llite: switch to use ll_fsname directly
  lustre: llite: fill copied dentry name's ending char properly
  lustre: llite, readahead: fix to call ll_ras_enter() properly
  lnet: libcfs: fix panic for too large cpu partitions
  lustre: lov: fix wrong calculated length for fiemap
  lustre: push rcu_barrier() before destroying slab
  lustre: llite,readahead: don't always use max RPC size
  lustre: llite: improve single-thread read performance
  lustre: llite: fix deadloop with tiny write
  lustre: llite: make sure readahead cover current read
  lustre: llite: don't check vmpage refcount in ll_releasepage()
  lustre: osc: reserve lru pages for read in batch
  lustre: llite: don't miss every first stride page
  lustre: llite: extend readahead locks for striped file
  lustre: readahead: convert stride page index to byte
  lnet: eliminate uninitialized warning
  lustre: llite: support page unaligned stride readahead
  lustre: ptlrpc: always reset generation for idle reconnect
  lustre: lmv: fix to return correct MDT count

Yang Sheng (6):
  lustre: ldlm: speed up preparation for list of lock cancel
  lustre: ldlm: fix for l_lru usage
  lustre: class: use INIT_LIST_HEAD_RCU instead INIT_LIST_HEAD
  lustre: lov: cl_cache could miss initialize
  lustre: lov: remove KEY_CACHE_SET to simplify the code
  lustre: import: fix race between imp_state & imp_invalid

 fs/lustre/Kconfig                             |    5 +
 fs/lustre/fid/fid_request.c                   |    7 +
 fs/lustre/fld/fld_cache.c                     |   15 +-
 fs/lustre/fld/fld_internal.h                  |    1 -
 fs/lustre/fld/fld_request.c                   |   23 +-
 fs/lustre/include/cl_object.h                 |   73 +-
 fs/lustre/include/lprocfs_status.h            |   33 +-
 fs/lustre/include/lu_object.h                 |  238 +-
 fs/lustre/include/lustre_disk.h               |    1 +
 fs/lustre/include/lustre_dlm.h                |  155 +-
 fs/lustre/include/lustre_dlm_flags.h          |   33 +-
 fs/lustre/include/lustre_export.h             |   29 +-
 fs/lustre/include/lustre_ha.h                 |    2 +-
 fs/lustre/include/lustre_handles.h            |   21 +-
 fs/lustre/include/lustre_import.h             |   45 +-
 fs/lustre/include/lustre_lmv.h                |   82 +-
 fs/lustre/include/lustre_log.h                |    4 +-
 fs/lustre/include/lustre_mdc.h                |  120 -
 fs/lustre/include/lustre_net.h                |  159 +-
 fs/lustre/include/lustre_osc.h                |   27 +-
 fs/lustre/include/lustre_req_layout.h         |   15 +-
 fs/lustre/include/lustre_sec.h                |   12 +
 fs/lustre/include/lustre_swab.h               |    2 +
 fs/lustre/include/obd.h                       |  151 +-
 fs/lustre/include/obd_cksum.h                 |  130 +-
 fs/lustre/include/obd_class.h                 |  150 +-
 fs/lustre/include/obd_support.h               |   59 +-
 fs/lustre/ldlm/ldlm_extent.c                  |    2 +-
 fs/lustre/ldlm/ldlm_inodebits.c               |  111 +-
 fs/lustre/ldlm/ldlm_internal.h                |   42 +-
 fs/lustre/ldlm/ldlm_lib.c                     |   59 +-
 fs/lustre/ldlm/ldlm_lock.c                    |  359 +--
 fs/lustre/ldlm/ldlm_lockd.c                   |  224 +-
 fs/lustre/ldlm/ldlm_pool.c                    |   28 +-
 fs/lustre/ldlm/ldlm_request.c                 |  444 +++-
 fs/lustre/ldlm/ldlm_resource.c                |  196 +-
 fs/lustre/llite/Makefile                      |    2 +-
 fs/lustre/llite/dcache.c                      |    1 -
 fs/lustre/llite/dir.c                         |  731 ++++--
 fs/lustre/llite/file.c                        |  987 ++++++--
 fs/lustre/llite/glimpse.c                     |    1 +
 fs/lustre/llite/lcommon_cl.c                  |   35 +-
 fs/lustre/llite/lcommon_misc.c                |   47 +-
 fs/lustre/llite/llite_internal.h              |  444 +++-
 fs/lustre/llite/llite_lib.c                   |  719 ++++--
 fs/lustre/llite/llite_mmap.c                  |   63 +-
 fs/lustre/llite/llite_nfs.c                   |   59 +-
 fs/lustre/llite/lproc_llite.c                 |  465 +++-
 fs/lustre/llite/namei.c                       |  717 ++++--
 fs/lustre/llite/pcc.c                         | 2614 ++++++++++++++++++++
 fs/lustre/llite/pcc.h                         |  264 ++
 fs/lustre/llite/rw.c                          | 1091 ++++++---
 fs/lustre/llite/rw26.c                        |    4 -
 fs/lustre/llite/statahead.c                   |  182 +-
 fs/lustre/llite/super25.c                     |   23 +-
 fs/lustre/llite/symlink.c                     |   21 +-
 fs/lustre/llite/vvp_dev.c                     |    1 +
 fs/lustre/llite/vvp_internal.h                |   22 +-
 fs/lustre/llite/vvp_io.c                      |  176 +-
 fs/lustre/llite/vvp_object.c                  |   11 +-
 fs/lustre/llite/vvp_page.c                    |   19 +-
 fs/lustre/llite/xattr.c                       |  109 +-
 fs/lustre/llite/xattr_security.c              |   19 +
 fs/lustre/lmv/lmv_fld.c                       |   17 +-
 fs/lustre/lmv/lmv_intent.c                    |  201 +-
 fs/lustre/lmv/lmv_internal.h                  |  162 +-
 fs/lustre/lmv/lmv_obd.c                       | 2078 +++++++++-------
 fs/lustre/lmv/lproc_lmv.c                     |  143 +-
 fs/lustre/lov/Makefile                        |    2 +-
 fs/lustre/lov/lov_cl_internal.h               |   28 +-
 fs/lustre/lov/lov_ea.c                        |  117 +-
 fs/lustre/lov/lov_internal.h                  |   49 +-
 fs/lustre/lov/lov_io.c                        |   89 +-
 fs/lustre/lov/lov_obd.c                       |  162 +-
 fs/lustre/lov/lov_object.c                    |  159 +-
 fs/lustre/lov/lov_offset.c                    |    2 +
 fs/lustre/lov/lov_pack.c                      |   73 +-
 fs/lustre/lov/lov_page.c                      |   17 +-
 fs/lustre/lov/lov_pool.c                      |   19 +-
 fs/lustre/lov/lov_request.c                   |   29 +-
 fs/lustre/lov/lovsub_page.c                   |   68 -
 fs/lustre/lov/lproc_lov.c                     |    4 +-
 fs/lustre/mdc/lproc_mdc.c                     |   87 +-
 fs/lustre/mdc/mdc_changelog.c                 |  154 +-
 fs/lustre/mdc/mdc_dev.c                       |  171 +-
 fs/lustre/mdc/mdc_internal.h                  |   14 +-
 fs/lustre/mdc/mdc_lib.c                       |   86 +-
 fs/lustre/mdc/mdc_locks.c                     |  277 ++-
 fs/lustre/mdc/mdc_reint.c                     |  106 +-
 fs/lustre/mdc/mdc_request.c                   |  476 +++-
 fs/lustre/mgc/lproc_mgc.c                     |   12 +-
 fs/lustre/mgc/mgc_request.c                   |   86 +-
 fs/lustre/obdclass/Makefile                   |    2 +-
 fs/lustre/obdclass/cl_io.c                    |   49 +-
 fs/lustre/obdclass/cl_object.c                |   23 +-
 fs/lustre/obdclass/cl_page.c                  |   36 +-
 fs/lustre/obdclass/class_obd.c                |  151 +-
 fs/lustre/obdclass/genops.c                   |  139 +-
 fs/lustre/obdclass/integrity.c                |  273 +++
 fs/lustre/obdclass/jobid.c                    |  282 ++-
 fs/lustre/obdclass/llog.c                     |  126 +-
 fs/lustre/obdclass/llog_cat.c                 |   59 +-
 fs/lustre/obdclass/llog_internal.h            |    4 +-
 fs/lustre/obdclass/lprocfs_status.c           |  277 ++-
 fs/lustre/obdclass/lu_object.c                |  518 +++-
 fs/lustre/obdclass/lu_tgt_descs.c             |  682 ++++++
 fs/lustre/obdclass/lustre_handles.c           |   61 +-
 fs/lustre/obdclass/obd_cksum.c                |  151 ++
 fs/lustre/obdclass/obd_config.c               |   39 +-
 fs/lustre/obdclass/obd_mount.c                |   23 +-
 fs/lustre/obdclass/obd_sysfs.c                |  101 +-
 fs/lustre/obdclass/obdo.c                     |    7 +-
 fs/lustre/obdecho/echo_client.c               |   77 +-
 fs/lustre/osc/lproc_osc.c                     |  232 +-
 fs/lustre/osc/osc_cache.c                     |  172 +-
 fs/lustre/osc/osc_dev.c                       |   19 +-
 fs/lustre/osc/osc_internal.h                  |   48 +-
 fs/lustre/osc/osc_io.c                        |  115 +-
 fs/lustre/osc/osc_lock.c                      |  156 +-
 fs/lustre/osc/osc_object.c                    |   28 +-
 fs/lustre/osc/osc_page.c                      |   20 +-
 fs/lustre/osc/osc_quota.c                     |   18 +-
 fs/lustre/osc/osc_request.c                   |  619 +++--
 fs/lustre/ptlrpc/client.c                     |  282 ++-
 fs/lustre/ptlrpc/errno.c                      |   27 +
 fs/lustre/ptlrpc/events.c                     |   12 +-
 fs/lustre/ptlrpc/import.c                     |  507 ++--
 fs/lustre/ptlrpc/layout.c                     |  172 +-
 fs/lustre/ptlrpc/llog_client.c                |   15 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c               |   66 +-
 fs/lustre/ptlrpc/niobuf.c                     |  102 +-
 fs/lustre/ptlrpc/pack_generic.c               |  236 +-
 fs/lustre/ptlrpc/pinger.c                     |   50 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h            |    3 +-
 fs/lustre/ptlrpc/ptlrpcd.c                    |   21 +-
 fs/lustre/ptlrpc/recover.c                    |   23 +-
 fs/lustre/ptlrpc/sec.c                        |  146 +-
 fs/lustre/ptlrpc/sec_bulk.c                   |   71 +-
 fs/lustre/ptlrpc/sec_config.c                 |   89 +-
 fs/lustre/ptlrpc/sec_gc.c                     |   16 +-
 fs/lustre/ptlrpc/sec_lproc.c                  |   74 +
 fs/lustre/ptlrpc/sec_null.c                   |   16 +-
 fs/lustre/ptlrpc/sec_plain.c                  |    7 +-
 fs/lustre/ptlrpc/service.c                    |  427 ++--
 fs/lustre/ptlrpc/wiretest.c                   |  342 ++-
 include/linux/libcfs/libcfs.h                 |    1 +
 include/linux/libcfs/libcfs_debug.h           |   69 +-
 include/linux/libcfs/libcfs_fail.h            |   46 +-
 include/linux/lnet/api.h                      |   34 +-
 include/linux/lnet/lib-lnet.h                 |  225 +-
 include/linux/lnet/lib-types.h                |  355 ++-
 include/uapi/linux/lnet/libcfs_debug.h        |    4 +-
 include/uapi/linux/lnet/libcfs_ioctl.h        |   13 +-
 include/uapi/linux/lnet/lnet-dlc.h            |   42 +
 include/uapi/linux/lnet/lnet-types.h          |   49 +-
 include/uapi/linux/lnet/lnetctl.h             |   23 +
 include/uapi/linux/lnet/nidstr.h              |    2 +
 include/uapi/linux/lustre/lustre_cfg.h        |    1 +
 include/uapi/linux/lustre/lustre_fid.h        |    7 +
 include/uapi/linux/lustre/lustre_idl.h        |  392 +--
 include/uapi/linux/lustre/lustre_ioctl.h      |    5 +-
 include/uapi/linux/lustre/lustre_kernelcomm.h |   15 +-
 include/uapi/linux/lustre/lustre_user.h       |  575 +++--
 include/uapi/linux/lustre/lustre_ver.h        |    6 +-
 mm/page-writeback.c                           |    1 +
 net/lnet/klnds/o2iblnd/o2iblnd.c              |  357 ++-
 net/lnet/klnds/o2iblnd/o2iblnd.h              |   63 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c           |  169 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c    |   30 +-
 net/lnet/klnds/socklnd/socklnd.c              |  737 +++---
 net/lnet/klnds/socklnd/socklnd.h              |   95 +-
 net/lnet/klnds/socklnd/socklnd_cb.c           |  139 +-
 net/lnet/klnds/socklnd/socklnd_proto.c        |   24 +-
 net/lnet/libcfs/debug.c                       |    5 +-
 net/lnet/libcfs/fail.c                        |   15 +-
 net/lnet/libcfs/libcfs_cpu.c                  |   11 +-
 net/lnet/libcfs/libcfs_lock.c                 |    2 +-
 net/lnet/libcfs/linux-crypto.c                |    5 +-
 net/lnet/libcfs/module.c                      |   33 +-
 net/lnet/libcfs/tracefile.c                   |   50 +-
 net/lnet/lnet/acceptor.c                      |   27 +-
 net/lnet/lnet/api-ni.c                        |  828 +++++--
 net/lnet/lnet/config.c                        |   57 +-
 net/lnet/lnet/lib-eq.c                        |    4 +-
 net/lnet/lnet/lib-md.c                        |   23 +-
 net/lnet/lnet/lib-me.c                        |  135 +-
 net/lnet/lnet/lib-move.c                      | 3266 +++++++++++++++++++------
 net/lnet/lnet/lib-msg.c                       |  711 +++++-
 net/lnet/lnet/lib-ptl.c                       |    2 +-
 net/lnet/lnet/lib-socket.c                    |   17 +-
 net/lnet/lnet/lo.c                            |    1 -
 net/lnet/lnet/module.c                        |    8 +-
 net/lnet/lnet/net_fault.c                     |  126 +-
 net/lnet/lnet/nidstrings.c                    |  272 +-
 net/lnet/lnet/peer.c                          |  725 ++++--
 net/lnet/lnet/router.c                        | 1613 ++++++------
 net/lnet/lnet/router_proc.c                   |  212 +-
 net/lnet/selftest/conctl.c                    |    4 +-
 net/lnet/selftest/console.c                   |   10 +-
 net/lnet/selftest/framework.c                 |   28 +-
 net/lnet/selftest/module.c                    |    2 +-
 net/lnet/selftest/rpc.c                       |   43 +-
 net/lnet/selftest/rpc.h                       |   10 +-
 203 files changed, 25222 insertions(+), 10485 deletions(-)
 create mode 100644 fs/lustre/llite/pcc.c
 create mode 100644 fs/lustre/llite/pcc.h
 delete mode 100644 fs/lustre/lov/lovsub_page.c
 create mode 100644 fs/lustre/obdclass/integrity.c
 create mode 100644 fs/lustre/obdclass/lu_tgt_descs.c
 create mode 100644 fs/lustre/obdclass/obd_cksum.c

-- 
1.8.3.1
