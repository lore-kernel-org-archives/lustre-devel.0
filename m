From: Oleg Drokin <green@whamcloud.com>
Date: Sun, 16 Jun 2019 03:59:37 +0000
Subject: [lustre-devel] New tag 2.12.55
Message-ID: <6E3FF7D2-78C5-4AC9-A91E-172E9CA92F34@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.12.55 tag in Lustre community master branch.
  This mostly brings remaining 2.13 cycle features like PCC and LNet multirail.

   Here?s the changelog:

Alexander Boyko (1):
      LU-12219 obdfilter: changes PAGE_SIZE variable

Amir Shehata (42):
      LU-12080 lnet: recovery event handling broken
      LU-12080 lnet: clean mt_eqh properly
      LU-12344 lnet: handle remote health error
      LU-11816 lnet: setup health timeout defaults
      LU-12163 lnet: fix cpt locking
      LU-12201 lnet: detach response tracker
      LU-11297 lnet: invalidate recovery ping mdh
      LU-12249 lnet: fix list corruption
      LU-12254 lnet: correct discovery LNetEQFree()
      LU-12199 lnet: verify msg is commited for send/recv
      LU-12339 lnet: select LO interface for sending
      LU-10153 lnet: remove route add restriction
      LU-11292 lnet: Discover routers on first use
      LU-11298 lnet: use peer for gateway
      LU-11299 lnet: lnet_add/del_route()
      LU-11551 lnet: Do not allow deleting of router nis
      LU-11300 lnet: router sensitivity
      LU-11300 lnet: configure lnet router senstivity
      LU-11300 lnet: cache ni status
      LU-11300 lnet: Cache the routing feature
      LU-11300 lnet: peer aliveness
      LU-11300 lnet: router aliveness
      LU-11300 lnet: simplify lnet_handle_local_failure()
      LU-11299 lnet: Cleanup rcd
      LU-11299 lnet: modify lnd notification mechanism
      LU-11299 lnet: use discovery for routing
      LU-11378 lnet: MR aware gateway selection
      LU-11300 lnet: consider alive_router_check_interval
      LU-11475 lnet: allow deleting router primary_nid
      LU-11475 lnet: transfer routers
      LU-11477 lnet: handle health for incoming messages
      LU-11478 lnet: misleading discovery seqno.
      LU-11470 lnet: drop all rule
      LU-11641 lnet: handle discovery off
      LU-11297 lnet: handle router health off
      LU-11297 lnet: set gw sensitivity from lnetctl
      LU-11664 lnet: push router interface updates
      LU-11299 lnet: net aliveness
      LU-11299 lnet: discover each gateway Net
      LU-12053 lnet: look up MR peers routes
      LU-12200 lnet: check peer timeout on a router
      LU-11297 lnet: MR Routing Feature

Andreas Dilger (1):
      LU-1538 tests: standardize test script init - sanity

Arshad Hussain (1):
      LU-6142 ptlrpc: Fix style issues for pinger.c

Chris Horn (5):
      LU-12264 lnet: Protect lp_dc_pendq manipulation with lp_lock
      LU-12199 lnet: Ensure md is detached when msg is not committed
      LU-12387 utils: Read existing ldd data in l_tunedisk
      LU-12387 utils: Avoid passing symlink to tune_block_dev
      LU-12387 tests: Validate l_tunedisk max_sectors_kb tuning

James Nunez (1):
      LU-12267 tests: filter trailing '.' for SELinux

James Simmons (1):
      LU-12381 ko2iblnd: ignore down interfaces

Lai Siyao (5):
      LU-11213 ptlrpc: intent_getattr fetches default LMV
      LU-11213 mdc: add async statfs
      LU-11213 lmv: mkdir with balanced space usage
      LU-9846 utils: hash may be overridden in 'lfs setdirstripe'
      LU-11213 lmv: reuse object alloc QoS code from LOD

Li Dongyang (3):
      LU-11838 ldiskfs: add rhel8 server support
      LU-11838 osd-ldiskfs: inode times switched to timespec64
      LU-12395 build: require python2 for lustre-iokit

Li Xi (1):
      LU-10092 llite: Add persistent cache on client

Mikhail Pershin (2):
      LU-11204 obdclass: remove unprotected access to lu_object
      LU-12014 llite: check correct size in ll_dom_finish_open()

Nathaniel Clark (1):
      LU-12375 scripts: Start lnet after opa

Oleg Drokin (4):
      LU-10092 First phase of persistent client cache project merging
      LU-11623 tests: Fix sanity 27E to ensure getattr RPC
      LU-10948 mdt: Remove openlock compat code with 2.1
      New tag 2.12.55

Patrick Farrell (1):
      LU-12396 utils: lfs should not output 'nul' char

Qian Yingjin (5):
      LU-10092 pcc: Non-blocking PCC caching
      LU-10092 pcc: security and permission for non-root user access
      LU-10918 llite: Rule based auto PCC caching when create files
      LU-10092 pcc: auto attach during open for valid cache
      LU-10092 pcc: change detach behavior and add keep option

Sebastien Buisson (1):
      LU-12399 tests: avoid 'pdsh localhost' in sanity test_420

Sergey Cheremencev (2):
      LU-11758 osp: remove assertion from statfs
      LU-12412 recovery: wake all waiters of trd_finishing

Shaun Tancheff (2):
      LU-12438 llite: vfs_read/write removed, use kernel_read/write
      LU-12355 lnet: Adjust checks for ib_device_ops

Vitaly Fertman (1):
      LU-9846 test: a test number fix

Wang Shilong (2):
      LU-12374 lustre: push rcu_barrier() before destroying slab
      LU-12383 utils: only check project inherit bit for dir
