From: kbuild test robot <lkp@intel.com>
Date: Fri, 11 May 2018 01:39:07 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Fix crash in
 kiblnd_handle_early_rxs()
In-Reply-To: <1525930679-15227-1-git-send-email-dougso@me.com>
References: <1525930679-15227-1-git-send-email-dougso@me.com>
Message-ID: <201805110116.e7LGjXEs%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Doug,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on v4.17-rc4 next-20180510]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Doug-Oucharek/staging-lustre-o2iblnd-Fix-crash-in-kiblnd_handle_early_rxs/20180511-004953
config: i386-randconfig-x078-201818 (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/kernel.h:10:0,
                    from include/linux/list.h:9,
                    from include/linux/module.h:9,
                    from drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h:38,
                    from drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:38:
   drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_handle_early_rxs':
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1975:5: error: 'kib_rx_t' undeclared (first use in this function); did you mean 'kib_rx'?
        kib_rx_t, rx_list);
        ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
   drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1975:5: note: each undeclared identifier is reported only once for each function it appears in
        kib_rx_t, rx_list);
        ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
>> include/linux/kernel.h:962:48: error: expected expression before ')' token
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                                                   ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
   In file included from include/linux/list.h:9:0,
                    from include/linux/module.h:9,
                    from drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h:38,
                    from drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:38:
   include/linux/kernel.h:965:10: error: expected expression before ')' token
     ((type *)(__mptr - offsetof(type, member))); })
             ^
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
--
   In file included from include/linux/kernel.h:10:0,
                    from include/linux/list.h:9,
                    from include/linux/module.h:9,
                    from drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd.h:38,
                    from drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:38:
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_handle_early_rxs':
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1975:5: error: 'kib_rx_t' undeclared (first use in this function); did you mean 'kib_rx'?
        kib_rx_t, rx_list);
        ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1975:5: note: each undeclared identifier is reported only once for each function it appears in
        kib_rx_t, rx_list);
        ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
>> include/linux/kernel.h:962:48: error: expected expression before ')' token
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                                                   ^
   include/linux/compiler.h:316:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:339:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:45:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:962:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~
   In file included from include/linux/list.h:9:0,
                    from include/linux/module.h:9,
                    from drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd.h:38,
                    from drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:38:
   include/linux/kernel.h:965:10: error: expected expression before ')' token
     ((type *)(__mptr - offsetof(type, member))); })
             ^
   include/linux/list.h:366:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^~~~~~~~~~~~
   drivers/staging/lustre//lnet/klnds/o2iblnd/o2iblnd_cb.c:1974:8: note: in expansion of macro 'list_entry'
      rx = list_entry(conn->ibc_early_rxs.next,
           ^~~~~~~~~~

vim +1975 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c

  1962	
  1963	static void
  1964	kiblnd_handle_early_rxs(struct kib_conn *conn)
  1965	{
  1966		unsigned long flags;
  1967		struct kib_rx *rx;
  1968	
  1969		LASSERT(!in_interrupt());
  1970		LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
  1971	
  1972		write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
  1973		while (!list_empty(&conn->ibc_early_rxs)) {
> 1974			rx = list_entry(conn->ibc_early_rxs.next,
> 1975					kib_rx_t, rx_list);
  1976			list_del(&rx->rx_list);
  1977			write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
  1978	
  1979			kiblnd_handle_rx(rx);
  1980	
  1981			write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
  1982		}
  1983		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
  1984	}
  1985	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 31657 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180511/0e57f981/attachment-0001.bin>
