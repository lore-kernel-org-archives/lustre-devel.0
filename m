From: kbuild test robot <lkp@intel.com>
Date: Wed, 20 Dec 2017 15:14:30 +0800
Subject: [lustre-devel] [PATCH 03/15] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <151355799030.6200.8100283223734974485.stgit@noble>
References: <151355799030.6200.8100283223734974485.stgit@noble>
Message-ID: <201712201404.5ovmUtOH%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi NeilBrown,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on next-20171220]
[cannot apply to v4.15-rc4]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/NeilBrown/staging-lustre-convert-most-LIBCFS-ALLOC-to-k-malloc/20171220-113029
config: x86_64-randconfig-r0-12200451 (attached as .config)
compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c: In function 'kiblnd_dev_failover':
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2395:2: error: 'kdev' undeclared (first use in this function)
     kdev = kzalloc(sizeof(*hdev), GFP_NOFS);
     ^~~~
   drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2395:2: note: each undeclared identifier is reported only once for each function it appears in

vim +/kdev +2395 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c

  2329	
  2330	int kiblnd_dev_failover(struct kib_dev *dev)
  2331	{
  2332		LIST_HEAD(zombie_tpo);
  2333		LIST_HEAD(zombie_ppo);
  2334		LIST_HEAD(zombie_fpo);
  2335		struct rdma_cm_id *cmid  = NULL;
  2336		struct kib_hca_dev *hdev  = NULL;
  2337		struct ib_pd *pd;
  2338		struct kib_net *net;
  2339		struct sockaddr_in addr;
  2340		unsigned long flags;
  2341		int rc = 0;
  2342		int i;
  2343	
  2344		LASSERT(*kiblnd_tunables.kib_dev_failover > 1 ||
  2345			dev->ibd_can_failover || !dev->ibd_hdev);
  2346	
  2347		rc = kiblnd_dev_need_failover(dev);
  2348		if (rc <= 0)
  2349			goto out;
  2350	
  2351		if (dev->ibd_hdev &&
  2352		    dev->ibd_hdev->ibh_cmid) {
  2353			/*
  2354			 * XXX it's not good to close old listener at here,
  2355			 * because we can fail to create new listener.
  2356			 * But we have to close it now, otherwise rdma_bind_addr
  2357			 * will return EADDRINUSE... How crap!
  2358			 */
  2359			write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
  2360	
  2361			cmid = dev->ibd_hdev->ibh_cmid;
  2362			/*
  2363			 * make next schedule of kiblnd_dev_need_failover()
  2364			 * return 1 for me
  2365			 */
  2366			dev->ibd_hdev->ibh_cmid  = NULL;
  2367			write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
  2368	
  2369			rdma_destroy_id(cmid);
  2370		}
  2371	
  2372		cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, dev, RDMA_PS_TCP,
  2373					     IB_QPT_RC);
  2374		if (IS_ERR(cmid)) {
  2375			rc = PTR_ERR(cmid);
  2376			CERROR("Failed to create cmid for failover: %d\n", rc);
  2377			goto out;
  2378		}
  2379	
  2380		memset(&addr, 0, sizeof(addr));
  2381		addr.sin_family      = AF_INET;
  2382		addr.sin_addr.s_addr = htonl(dev->ibd_ifip);
  2383		addr.sin_port	= htons(*kiblnd_tunables.kib_service);
  2384	
  2385		/* Bind to failover device or port */
  2386		rc = rdma_bind_addr(cmid, (struct sockaddr *)&addr);
  2387		if (rc || !cmid->device) {
  2388			CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
  2389			       dev->ibd_ifname, &dev->ibd_ifip,
  2390			       cmid->device, rc);
  2391			rdma_destroy_id(cmid);
  2392			goto out;
  2393		}
  2394	
> 2395		kdev = kzalloc(sizeof(*hdev), GFP_NOFS);
  2396		if (!hdev) {
  2397			CERROR("Failed to allocate kib_hca_dev\n");
  2398			rdma_destroy_id(cmid);
  2399			rc = -ENOMEM;
  2400			goto out;
  2401		}
  2402	
  2403		atomic_set(&hdev->ibh_ref, 1);
  2404		hdev->ibh_dev   = dev;
  2405		hdev->ibh_cmid  = cmid;
  2406		hdev->ibh_ibdev = cmid->device;
  2407	
  2408		pd = ib_alloc_pd(cmid->device, 0);
  2409		if (IS_ERR(pd)) {
  2410			rc = PTR_ERR(pd);
  2411			CERROR("Can't allocate PD: %d\n", rc);
  2412			goto out;
  2413		}
  2414	
  2415		hdev->ibh_pd = pd;
  2416	
  2417		rc = rdma_listen(cmid, 0);
  2418		if (rc) {
  2419			CERROR("Can't start new listener: %d\n", rc);
  2420			goto out;
  2421		}
  2422	
  2423		rc = kiblnd_hdev_get_attr(hdev);
  2424		if (rc) {
  2425			CERROR("Can't get device attributes: %d\n", rc);
  2426			goto out;
  2427		}
  2428	
  2429		write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
  2430	
  2431		swap(dev->ibd_hdev, hdev); /* take over the refcount */
  2432	
  2433		list_for_each_entry(net, &dev->ibd_nets, ibn_list) {
  2434			cfs_cpt_for_each(i, lnet_cpt_table()) {
  2435				kiblnd_fail_poolset(&net->ibn_tx_ps[i]->tps_poolset,
  2436						    &zombie_tpo);
  2437	
  2438				if (net->ibn_fmr_ps)
  2439					kiblnd_fail_fmr_poolset(net->ibn_fmr_ps[i],
  2440								&zombie_fpo);
  2441			}
  2442		}
  2443	
  2444		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
  2445	 out:
  2446		if (!list_empty(&zombie_tpo))
  2447			kiblnd_destroy_pool_list(&zombie_tpo);
  2448		if (!list_empty(&zombie_ppo))
  2449			kiblnd_destroy_pool_list(&zombie_ppo);
  2450		if (!list_empty(&zombie_fpo))
  2451			kiblnd_destroy_fmr_pool_list(&zombie_fpo);
  2452		if (hdev)
  2453			kiblnd_hdev_decref(hdev);
  2454	
  2455		if (rc)
  2456			dev->ibd_failed_failover++;
  2457		else
  2458			dev->ibd_failed_failover = 0;
  2459	
  2460		return rc;
  2461	}
  2462	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 30875 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171220/9a89b2c6/attachment-0001.bin>
