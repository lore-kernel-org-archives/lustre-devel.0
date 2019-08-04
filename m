From: James Simmons <jsimmons@infradead.org>
Date: Sun, 4 Aug 2019 20:14:59 +0100 (BST)
Subject: [lustre-devel] Reviewing/approving ports from OpenSFS lustre to
 upstream linux
In-Reply-To: <87a7ctlc1m.fsf@notabene.neil.brown.name>
References: <87a7ctlc1m.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1908042002140.7583@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> 
> Hi all,
>  I have started the task of porting patches from OpenSFS lustre to
>  upstream Linux.
>  I currently have 113 patches ported, and have about 200 remaining
>  (though that is rubbery number as the initial triage is quite
>  imprecise).  This list will get me up to Lustre 2.12.2.
> 
>  I have been porting any patches that make non-trivial changes to files
>  that are in my tree.  This avoids most server-specific patches, but
>  might include a few patches that are not strictly necessary on the
>  client.  I would like to keep them even if they are not needed, as it
>  will make it easier to eventually import the server support.
> 
>  The important question for the moment is: how much review do people
>  think these patches need?
> 
>  A lot of the conversion was assisted by code, but there was still
>  plenty of manual work and so room for error.  I've done some testing and
>  found/fixed some of those errors, but it would be naive to think that
>  I've found them all.
>  I could post them here - whether all at once or in batches of 20 or
>  similar - but I doubt anyone has the patience to look over them,
>  comparing them either to the original or to their understanding of
>  correctness.

Actually I have been looking over all the patches you back ported.
I'm also scanning for any missed ones which I found a few. Not done
with that process yet. I also have been testing them in batches for
any potential regressions. Currently I'm about at 50 of your patches
but I'm doing a second sweep of that set. Also running checkpatch as well
on the patches. The reason for the 50 count is that its the magic
number for me to run the 2.11 test suite without PFL failing in mass.
 
>  My inclination is to just apply them as-is and rely on on-going testing
>  to find problems.
>  Once I have my tree up-to-date with a recent OpenSFS branch, I plan to
>  do a "diff" between the two and write some code to filter out the
>  expected differences so I should be able to find any errors then.
> 
>  Does anyone else have any thoughts, or would anyone like to volunteer
>  to do a review :-)

Sure I will help out :-) I'm already looking at the patches so I'm
already reviewing. I hope to give you feed back in the next few days.

>  The ported patches are in lustre/linux-backport branch of my github
>  tree:
> 
>  https://github.com/neilbrown/linux/commits/lustre/lustre-backport
> 
>  A few of them are substantially different from the original, even after
>  factoring obvious differences like no-server-code no-tools-code
>  and changes to allocation and GOTO and RETURN etc.
>  In particular:
>   https://github.com/neilbrown/linux/commit/755bfeaa7bf7bc636d82043200a5ad56815a9bf8
> 
>  This was originally
>     Lustre-commit: 08479b74ec35 ("LU-9221 jobstats: Create a pid-based hash for jobid values")
>  but is now:
>    lustre: jobstats: move jobstats code into separate file.
>  as there is no need to cache values extracted from the process
>  environment, as my tree doesn't get jobids from the environment.
> 
>  Also
>    https://github.com/neilbrown/linux/commit/61e6cb7516646117a9c61468fa8649109be87747
>  This was
>    Lustre-commit: e7cf1b060ba3 ("LU-8272 ldlm: Use interval tree to update kms")
>  but now uses the Linux interval tree and uses it in a different way
>  which makes the code slightly more efficient (intervals are stored in
>  the tree in reverse order).
> 
>  A couple of other patches are much smaller than the original because
>  some, but not all, of the patch had already landed.
> 
> The full list of ported patches is below, followed by the list of patches
> that I still have to look at (and which I hope to have processed by the
> end of August).
> The commit ids in the first list will probably change in the
> not-to-distance future, as I expect I'll need to rebase.
> 
> Any input most welcome,
> 
> Thanks,
> NeilBrown
> 
> lustre/lustre-backport patches already processed:
> 
> a7620addd738 lustre: seq: make seq_proc_write_common() safer
> 55fac30b837d lustre: ptlrpc: Fix an rq_no_reply assertion failure
> e158cee7f933 lustre: fld: resend seq lookup RPC if it is on LWP
> db5a43c893d3 lustre: fld: retry fld rpc even for ESHUTDOWN
> 97dc0d7b3669 lustre: fld: retry fld rpc until the import is closed
> ff39da9bc171 lustre: fld: fld client lookup should retry
> 63f923c8746c lustre: tests: testcases for multiple modify RPCs feature
> 58c7f07da615 lustre: ldlm: Don't check opcode with NULL rq_reqmsg
> 4ca5cb491688 lustre: lnet: Allocate MEs and small MDs in own kmem_caches
> a658251de37b lustre: all: remove remaining Sun license and URL references
> 61e6cb751664 lustre: ldlm: Use interval tree to update kms
> 8cc201ca2436 lustre: osc: prepare OSC code to be used from MDC
> 7bc8d08d78ae lustre: statahead: support striped directory
> a2d865342ddb lustre: readdir: improve striped readdir
> d87c8ca43d53 lustre: llite: NULL pointer dereference in cl_object_top()
> ae9099a46266 lustre: ptlrpc: remove incorrect pid printing
> 8c8c881302c2 lustre: llite: Reduce overhead for ll_do_fast_read
> 66983035bbbf lustre: ptlrpc: Use C99 initializer in ptlrpc_register_rqbd()
> 8c40e52c4d82 lustre: lnet: Use C99 struct initializer in framework.c
> a6774fdb376b lustre: lnet: fix memory leak and lnet_interfaces_max
> c801da873cc2 lustre: lnet: decref on peer after use
> 6217efece99a lustre: lnet: resolve unsafe list access
> a7db1e0b879e lustre: llite: Implement ladvise lockahead
> 37212f736d60 lustre: ldlm: don't use jiffies as sysfs parameter
> 413f1faff69c lustre: lnet: Handle ping buffer with only loopback NID
> ce47540e9e3d lustre: llite: enable readahead for small read_ahead_per_file
> 59a52336bc61 lustre: lnet: don't discover loopback interface
> 5bb6e637c8c6 lustre: lnet: reduce logging severity
> 044692ea9bc4 lustre: mdc: add cl_device to the MDC
> 75c77ee36ccd lustre: mdt: IO request handling in MDT
> 690226c9de92 lustre: lov: add MDT target to the LOV device
> 8632b26c7a33 lustre: osc: common client setup/cleanup
> 739710ebe26f lustre: mdc: add IO methods to the MDC
> b30da0319f72 lustre: lvbo: pass lock as parameter to lvbo_update()
> 3f4a0e832b0c lustre: mds: add IO locking to the MDC and MDT
> 8577e5258a42 lustre: mdc: add IO stats in mdc
> ab8111fde9a1 lustre: mds: combine DoM bit with other IBITS
> 570d90291e81 lustre: llite: check layout size after cl_object_layout_get
> 702c0cd22218 lustre: lov: allow lov.*.stripe{size,count}=-1 param
> a27a5bb7fed9 lustre: lov: take lov layout lock for I/O with ignore_layout
> 6dfb1e2b6693 lustre: lov: pack lsm_flags from layout
> 669663dd5486 lustre: clio: introduce CIT_GLIMPSE for glimpse
> 05746117e394 lustre: flr: lfs setstripe to create a new mirror
> ecefe6f3ceff lustre: clio: no glimpse for data immutable file
> d68c1208de79 lustre: test: add Data-on-MDT tests and fixes

I got up to here with the testing.

> 9fc350b7f641 lustre: flr: read support for flr
> ebcc207b3bcf lustre: lov: rework write intent on componect instantiation
> 86f8cbf9c797 lustre: ptlrpc: use lu_extent in layout_intent
> 27fecdc05ee6 lustre: flr: Send write intent RPC to mdt
> 7b354c05fd9f lustre: flr: extend DATA_VERSION API to read layout version
> a66ab9cec3ab lustre: lov: skip empty pages in lov_io_submit()
> 589c789b5d09 lustre: mdc: don't assert on name pack
> c92fc844755a lustre: flr: mirror read and write
> 25a29f93d513 lustre: flr: resync support and test tool
> 5d5dd900019d lustre: flr: randomize mirror pick
> b23835ef2994 lustre: flr: instantiate component for truncate
> 935afa1a1d46 lustre: lustre: Add an additional set of 64 changelog flags.
> ab001306e8b9 lustre: ldlm: assume OBD_CONNECT_IBITS
> 5b7ec0d41cd8 lustre: llite: assume OBD_CONNECT_ATTRFID
> 118289d111c1 lustre: llite: simplify ll_inode_revalidate()
> decdb3ba5bad lustre: obd: free obd_svc_stats when all users are gone
> 3ea96ddf0512 lustre: lustre: add uid/gid to Changelogs entries
> 77ebd7e76506 lustre: mdc: resend quotactl if needed
> 7fec496ae4d7 lustre: quota: add default quota setting support
> 75964e26df88 lustre: scrub: remove an unused enum.
> e864834eef53 lustre: llite: don't reconnect MGC if connecting
> 27658d870897 lustre: libcfs: call proper crypto algo when keys are passed in
> 5414a07d219d lustre: clio: remove unused cl_lock layers
> 3c9d4c8efa07 lustre: llite: avoid live-lock when concurrent mmap()s
> 7e5740c68899 lustre: dne: allow mkdir with specific MDTs
> 2f2a0fc36b74 lustre: fid: improve seq allocation error messages
> 43db8d4299ac lustre: mdc: interruptable during RPC retry for EINPROGRESS
> 91af55d54004 lustre: vvp: Print discarded page warning on -EIO
> 0a24fa7cc327 lustre: clio: Use readahead for partial page write
> 41069b28ed8f lustre: flr: comp-flags support when creating mirrors
> a4095929832b lustre: obd: remove s2dhms time function
> e20863e177b8 lustre: ptlrpc: migrate pinger to 64 bit time
> 85a7cd9f1213 lustre: ldlm: migrate the rest of the code to 64 bit time
> d296a820198f lustre: sec: migrate to 64 bit time
> d3427d159a26 lustre: llite: change lli_glimpse_time to ktime
> 7dc668a320be lustre: osc: migrate to 64 bit time
> 30079f0d0cde lustre: libcfs: remove the remaining cfs_time wrappers
> e94d951293be lustre: libcfs: remove cfs_time_XXX_64 wrappers
> 83b3f57d8d1e lustre: lov: fill no-extent fiemap on object with no stripe.
> 970ab78779e0 lustre: lnet: ensure peer put back on dc request queue
> 53ac1c273c2a lustre: lustre: move LA_* flags to lustre_user.h
> a0f68c1a8351 lustre: flr: revise lease API
> 74c91f14041d lustre: acl: prepare small buffer for ACL RPC reply
> 3855dd19a197 lustre: lnet: safe access in debug print
> d261bdff5ab4 lustre: lnet: Remove LASSERT on userspace data
> 68bb78619156 lustre: flr: split a mirror from mirrored file
> a69b75d52f16 lustre: util: rename LCM_FL_NOT_FLR to LCM_FL_NONE
> 70f3f5d90d2d lustre: flr: layout truncate compatibility
> 6f89dc33b38f lustre: llite: Add tiny write support
> e7fb7e63603c lustre: llite: have ll_write_end to sync for DIO
> 8484cb9769bf lustre: obd: add check to obd_statfs
> 60030e2a954b lustre: obd: fix statfs handling
> 0cf1d167597c lustre: dom: support DATA_VERSION IO type
> 8fd3754b6bd3 lustre: osc: add a bit to indicate osc_page in cache tree
> 776882024895 lustre: ldlm: fix export reference
> af32a69ec44b lustre: llite: Add exit for filedata allocation failed
> 46f6d286f3e5 lustre: misc: Wrong checksum return value
> 5e337c29c4e2 lustre: obd: fix mount error handing
> c98f5793acaa lustre:: Disable tiny writes for append
> d995ac7d72a4 lustre: lustre: replace FMODE_{READ,WRITE} with MDS_* equivs
> 594dc4753261 lustre: lnet: reduce discovery timeout
> 3e86dc262321 lustre: mdc: fix possible NULL pointer dereference
> 755bfeaa7bf7 lustre: jobstats: move jobstats code into separate file.
> 25f171224130 lustre: obdclass: allow specifying complex jobids
> 9ecfd7cee1d7 lustre: ldlm: don't disable softirq for exp_rpc_lock
> 779fa73a292b lustre: obdclass: new wrapper to convert NID to string
> bb5b7634360f lustre: ptlrpc: Add QoS for uid and gid in NRS-TBF
> 88f76812c467 lustre: libcfs: remove unnecessary set_fs(KERNEL_DS) calls.
> 
> OpenSFS patches yet to be processed:
> 
> a0c644fde340 LU-1644 mgc: remove obsolete IR swabbing workaround
> c1d465de13cc LU-6655 ptlrpc: skip delayed replay requests
> 14b98596fa24 LU-4684 ptlrpc: add dir migration connect flag
> da028f98ea11 LU-10805 ldlm: convert ACCESS_ONCE() to READ_ONCE()
> 9b5337b695be LU-10850 fld: handle empty ranges in fld_index_init()
> 69727e45b4c0 LU-10413 ldlm: expose dirty age limit for flush-on-glimpse
> 37932c4beb98 LU-10175 ldlm: IBITS lock convert instead of cancel
> e2cac9fb9baf LU-1644 ptlrpc: fix return type of boolean functions
> 6b8638bf7920 LU-10992 llite: decrease sa_running if fail to start statahead
> b51e8d6b53a3 LU-9857 lmv: dir page is released while in use
> afd9e3c298ec LU-10560 llite: remove assigning f_version in ll_readir.
> 782ff36d50c7 LU-10805 libcfs: timer_setup() API changes
> 651f2cdd2d8d LU-9230 ldlm: speed up preparation for list of lock cancel
> e37335b2d8c2 LU-6399 lnet: socket cleanup
> e9b13cd1daf9 LU-10906 checksum: enable/disable checksum correctly
> 454a5f5c5496 LU-9859 libcfs: rearrange placement of CPU partition management code.
> 4325b1e45664 LU-4684 xattr: add list support for remote object
> e09d273cb5f2 LU-10945 ldlm: fix l_last_activity usage
> f024aabf8bbf LU-10938 ptlrpc: Add WBC connect flag
> 2a77dd3bee76 LU-11003 ldlm: fix for l_lru usage
> 313ac16698db LU-11015 lov: Move lov_tgts_kobj init to lov_setup
> 520c2959244e LU-8130 ldlm: store name directly in namespace.
> 200115bc8145 LU-10264 misc: fix possible array overflow
> b1e7be00cb6e LU-10472 osc: add T10PI support for RPC checksum
> f92fcb863cb9 LU-10648 ldlm: Reduce debug to console during eviction
> d66bba81fc64 LU-11054 lnet: remove non-error error message
> f8df907e8aae LU-11069 llite: correct file position after appending writes
> 5a6ceb664f07 LU-7236 ptlrpc: idle connections can disconnect
> 44a2092f08ca LU-10175 ptlrpc: add LOCK_CONVERT connection flag
> 541902a3f934 LU-10175 ldlm: handle lock converts in cancel handler
> 5761b9576d39 LU-10527 obdclass: don't recycle loghandle upon ENOSPC
> 413a738a37d7 LU-11004 ptlrpc: Serialize procfs access to scp_hist_reqs using mutex
> ad52f394bd82 LU-11003 ldlm: don't add canceling lock back to LRU
> 00c72ab6bb43 LU-11117 ptlrpc: don't zero request handle
> e40ea6fd4494 LU-11064 lnd: determine gaps correctly
> 164231a7a29b LU-11079 llite: control concurrent statahead instances
> 92e2b514e06c LU-10990 osc: increase default max_dirty_mb to 2G
> 7d89a5b8aefc LU-10855 ptlrpc: remove obsolete OBD RPC opcodes
> 12c5a26609f1 LU-10855 ptlrpc: assign specific values to MGS opcodes
> 830ce1b10f3a LU-10855 ptlrpc: remove obsolete LLOG_ORIGIN_* RPCs
> d69d488e1778 LU-11098 ptlrpc: ASSERTION(!list_empty(imp->imp_replay_cursor))
> dea1cde92014 LU-11074 mdc: set correct body eadatasize for getxattr()
> d3f88d376c49 LU-11157 obd: keep dirty_max_pages a round number of MB
> fc915a43786e LU-8708 osc: depart grant shrinking from pinger
> 41a804a16638 LU-11138 lfs: getstripe display certain mirror(s)
> 954cc6754b19 LU-11102 ldlm: run local lock bl_ast only when necessary
> 0e5c12ac29a9 LU-10916 lfs: improve lfs mirror resync
> 470bdeec6ca5 LU-4684 migrate: pack lmv ea in migrate rpc
> 4e48761a5719 LU-9120 lnet: refactor lnet_select_pathway()
> d54afb86116c LU-9120 lnet: add health value per ni
> 63cf744d0fdf LU-9120 lnet: add lnet_health_sensitivity
> b01e6fce1c98 LU-9120 lnet: add monitor thread
> 70616605dd44 LU-9120 lnet: handle local ni failure
> 8cf835e425d8 LU-9120 lnet: handle o2iblnd tx failure
> 25c1cb2c4d6f LU-9120 lnet: handle socklnd tx failure
> 76fad19c2dea LU-9120 lnet: handle remote errors in LNet
> 20e23980eae2 LU-9120 lnet: add retry count
> 84f3af43c4bd LU-9120 lnet: calculate the lnd timeout
> 5169827bf790 LU-9120 lnet: sysfs functions for module params
> a57fa1176e74 LU-9120 lnet: timeout delayed REPLYs and ACKs
> 0b1947d14188 LU-9120 lnet: remove duplicate timeout mechanism
> 6b1571209a99 LU-9120 lnet: handle fatal device error
> 2f5a6d1233ac LU-9120 lnet: reset health value
> 67908ab34371 LU-9120 lnet: add health statistics
> 10958cac798d LU-9120 lnet: Add ioctl to get health stats
> ba05b3a98a0c LU-9120 lnet: remove obsolete health functions
> 29f21e2c850a LU-9120 lnet: set retry count from lnetctl
> cf47570b0273 LU-9120 lnet: set transaction timeout from lnetctl
> 4a7357d5e945 LU-9120 lnet: set health sensitivity from lnetctl
> 60fc3c747570 LU-9120 lnet: show local ni health stats
> f64abb795a89 LU-9120 lnet: show peer ni health stats
> c0ad398fd716 LU-9120 lnet: set health value from user space
> 15020fd977af LU-9120 lnet: add global health statistics
> 826ea19c077b LU-9120 lnet: print recovery queues content
> 5c17777d97bd LU-9120 lnet: health error simulation
> 82fe90a1d07d LU-11224 obd: use correct ip_compute_csum() version
> 5874da0b670b LU-11175 osc: serialize access to idle_timeout vs cleanup
> 511ea5850f25 LU-11014 mdc: remove obsolete intent opcodes
> ac40000d4bde LU-11200 libcfs: handle DECLARE_TIMER reduced to two arguments
> c027cbd8a449 LU-9120 lnet: LNet Health/Resiliency Feature
> 39fad9dc60dd LU-11154 llite: use proper flags for FS_IOC_{FSSET,FSGET}XATTR
> 3e070e30a98d LU-8708 osc: enable/disable OSC grant shrink
> b500d5193360 LU-10018 protocol: MDT as a statfs proxy
> aecafb57d5b6 LU-11075 ldlm: correct logic in ldlm_prepare_lru_list()
> 0f7d7b200b58 LU-11275 llite: check truncate race for DOM pages
> cf3cc2c72e6e LU-11271 lnd: conditionally set health status
> 05becd69bc0c LU-11272 lnet: router handling
> 2269d27e07cb LU-11057 obd: check '-o network' and peer discovery conflict
> 40f70cd4cb1b LU-10818 obdecho: don't set ma_need in echo_attr_get_complex()
> b9523f474346 LU-11273 lnet: update logging
> 3f2b6d2a7c4a LU-10654 lnet: lnetctl doesn't error out on mistyped options
> bef1069506c3 LU-8130 libcfs: prepare rhashtable support
> 40295e5ca3e5 LU-11006 lnet: fix show peer yaml tree with no peer
> 605a139a193e LU-11304 misc: update all url links to whamcloud
> 43e4befc2efa LU-11328 ldlm: fix compile problem with --disable-lru-size
> b44b1ff8c7fc LU-10961 ldlm: don't cancel DoM locks before replay
> b04c35874dca LU-11283 lnet: fix setting health value manually
> cdf462b19345 LU-11309 lnd: Clean up logging
> ecc46547d127 LU-11165 llite: set iflags and catch error from md_setattr() properly
> 48e409e65edd LU-11281 ptlrpc: race in AT early reply
> 8ad9453ee66e LU-11016 obdclass: change JobID error into warning
> 169738e30a7e LU-4684 migrate: migrate striped directory
> 99494a28e6af LU-10124 lnet: Correctly add peer MR value while importing
> e23250110729 LU-10899 obdclass: remove unused ll_import_cachep
> 0aa58d26f5df LU-11128 ptlrpc: add debugging for idle connections
> 97381ffc9231 LU-5026 obdclass: Add lbug_on_eviction option
> 976b609abcdf LU-4684 lmv: support accessing migrating directory
> 7b3f9e5d6c50 LU-8130 ptlrpc: convert conn_hash to rhashtable
> 9b83e0e3fc5a LU-11268 mdc: use smaller buffers for getxattr
> 4037c1462730 LU-11373 libcfs: fix wrong check in libcfs_debug_vmsg2()
> 93d20d171c20 LU-11128 ptlrpc: new request vs disconnect race
> 159ccd46747f LU-6081 user: adding llapi_create_volatile_param()
> e02cb40761ff LU-11164 ldlm: pass env to lvbo methods
> 48df66be72c9 LU-10899 osc: move obdo_cache to OSC code
> fab95b4345db LU-11380 llite: zero lum for stripeless files
> f63366a3c285 LU-11397 idl: remove obsolete RPC flags
> 8a0554450eaa LU-11400 flr: add 'nosync' flag for FLR mirrors
> 123ee3cf96dd LU-10906 llite: create checksums to replace checksum_pages
> cf503e047c7f LU-11414 ptlrpc: don't change buffer when signature is ready
> 2a520282888d LU-11287 ldlm: update l_blocking_lock under lock
> bda43cbe369a LU-10595 mgc: don't proccess cld during stopping
> e9e598b9b2c5 LU-11370 lnet: cleanup ni_cptlist
> 7fa0fd415770 LU-11441 obdclass: make mod rpc slot wait queue FIFO
> fba98579efc4 LU-6202 libcfs: replace libcfs_register_ioctl with a blocking notifier_chain
> e70a6fd8a640 LU-11375 mdc: use old statfs format
> 60f6f2b480b4 LU-11422 lnet: Fix selftest backward compatibility post health
> 3eb7a1dfc3e7 LU-11454 ptlrpc: Make CPU binding switchable
> 70a01a6c9c7c LU-11276 ldlm: don't apply ELC to converting and DOM locks
> 1eeb1455c277 LU-11482 flr: Inherit flags from template
> 68bc3984975b LU-11453 class: use INIT_LIST_HEAD_RCU instead INIT_LIST_HEAD
> fef1020406a0 LU-8391 ldlm: check double grant race after resource change
> e0132e16df15 LU-11474 lnet: unlink md if fail to send recovery
> 02e766f5ed95 LU-11427 llite: optimize read on open pages
> 5d77f0d8dc74 LU-11476 lnet: set the health status correctly
> b917406a7f0a LU-7770 lov: fix statfs for conf-sanity test_50b
> 139d69141b73 LU-11472 lnet: Decrement health on timeout
> 1ca7f6329833 LU-11163 libcfs: fix CPT NUMA memory failures
> 1d94072c63f5 LU-11371 socklnd: dynamically set LND parameters
> 14171e787dd0 LU-10258 lfs: lfs mirror write command
> a5c1cd5ec240 LU-11530 lnet: properly error check sensitivity
> 9b790ba0f560 LU-11152 lnd: test fpo_fmr_poool pointer instead of special bool
> ae828cd3b092 LU-4684 llite: add lock for dir layout data
> dc1f5f08b420 LU-11468 lnet: configure recovery interval
> 7f8143cf85b7 LU-11423 osc: Do not walk full extent list
> 307d877e5124 LU-11469 lnet: fix "debug recovery" output
> 2be10428ac22 LU-11514 lnet: separate ni state from recovery
> b7f8d156db69 LU-11468 lnet: set recovery interval from lnetctl
> 0f42b388432c LU-11380 mdc: move empty xattr handling to mdc layer
> 59729e4c0867 LU-11445 obd: remove portals handle from OBD import
> 3f65f631c74d LU-11599 ldlm: printing negative time on logs for recovery
> 6c73ab942fef LU-11570 lnet: update changelog
> ca9300e53dc2 LU-10937 mgc: restore mgc binding for sptlrpc
> a3b6109705dc LU-10876 lnet: peer deletion code may hide error
> 75a417fa0065 LU-11102 ldlm: don't skip bl_ast for local lock
> b4a959eb61bc LU-9906 clio: use pagevec_release for many pages
> a857446dc648 LU-11642 lmv: allocate fid on parent MDT in migrate
> 641e1d546742 LU-9793 ptlrpc: Do not map unrecognized ELDLM errnos to EIO
> 04c172b68676 LU-11582 llite: protect reading inode->i_data.nrpages
> e3f367f3660d LU-11662 llite: handle -ENODATA in ll_layout_fetch()
> c1f052055446 LU-11697 osc: wrong page offset for T10PI checksum
> 73fdd1579d87 LU-11389 lnet: increase lnet transaction timeout
> 8c249097e627 LU-11734 lnet: handle multi-md usage
> a13e4991a135 LU-11753 obdclass: index_page support variable length rec
> 77f01308c509 LU-11753 obdclass: lu_dirent record length missing '0'
> cd294a12553a LU-11809 llite: don't use %p to generate cfg_instance
> f60637d9379d LU-11568 ldlm: Remove use of SLAB_DESTROY_BY_RCU for ldlm lock slab
> 8f887156d466 LU-11834 llite: fix temporary instance buffer size
> e8ea17ff9235 LU-11579 llite: remove cl_file_inode_init() LASSERT
> 29d627f860bc LU-8130 libcfs: don't include rhashtable if unavailable
> ca5c65909759 LU-11647 ptlrpc: always unregister bulk
> 0205858f6533 LU-12065 lnd: increase CQ entries
> e1ff19d73c77 LU-11658 lov: cl_cache could miss initialize
> 3921cf2544d8 LU-12020 llite: make sure name pack atomic
> f95ab9a42241 LU-11894 lnet: check for asymmetrical route messages
> 6669e463d7eb LU-11974 llapi: improve llapi_layout_get_by_xattr(3) API
> a4bef2a01633 LU-11752 osc: pass client page size during reconnect too
> 6c2ecb0c7251 LU-9706 dt: remove dt_txn_hook_commit()
> 82dad29511b3 LU-11964 mdc: prevent glimpse lock count grow
> 182731f92c4a LU-11999 dne: performance improvement for file creation
> ec964395b249 LU-11415 socklnd: improve scheduling algorithm
> e13cc954a776 LU-11798 grant: prevent overflow of o_undirty
> 7c8d60106acd LU-11919 llite: Initialize cl_dirty_max_pages
> c4eed4899ac7 LU-11830 lov: avoid signed vs. unsigned comparison
> 81fe463c5ac1 LU-11825 clio: Remove pio feature
> 845338af031a LU-11930 llite: Restore pio flags
> 009ee0ba61e9 LU-11944 llite: Lock inode on tiny write if setuid/setgid set
> 4e737a6a8a0f LU-11825 llite: Remove ptask framework
> 54ca5e471d9f LU-11986 lnet: Avoid lnet debugfs read/write if ctl_table does not exist
> 78ddbc595302 LU-11951 ptlrpc: reset generation for old requests
> 60e12ac3a7b0 LU-8955 cfg: reserve flags for SELinux status checking
> 70aea00ecb39 LU-8955 ptlrpc: manage SELinux policy info at connect time
> 88bb40aa14d9 LU-8955 ptlrpc: manage SELinux policy info for metadata ops
> 7aa5ae2673f7 LU-9193 security: return security context for metadata ops
> 056fe83188f0 LU-11931 lnd: bring back concurrent_sends
> 03caa311ca92 LU-12021 lsom: Add an OBD_CONNECT2_LSOM connect flag
> 9d42660e173e LU-11986 lnet: properly cleanup lnet debugfs files
> 672e85cfb907 LU-12276 lnet: check const parameters for ib_post_send and ib_post_recv
> 61270a9330e7 LU-12279 lnet: use number of wrs to calculate CQEs
> 
