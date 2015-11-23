From: kbuild test robot <lkp@intel.com>
Date: Tue, 24 Nov 2015 06:10:08 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: constify
	ptlrpc_sec_cops structs
In-Reply-To: <20151123214234.GA9568@waves>
Message-ID: <201511240637.yUtwbW4T%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on v4.4-rc2 next-20151123]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/staging-lustre-ptlrpc-constify-ptlrpc_sec_cops-structs/20151124-054437
config: tile-allyesconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=tile 

All warnings (new ones prefixed by >>):

>> drivers/staging/lustre/lustre/ptlrpc/sec_null.c:404:2: warning: initialization discards 'const' qualifier from pointer target type [enabled by default]

vim +/const +404 drivers/staging/lustre/lustre/ptlrpc/sec_null.c

d7e09d039 Peng Tao 2013-05-02  388  	.free_reqbuf	    = null_free_reqbuf,
d7e09d039 Peng Tao 2013-05-02  389  	.free_repbuf	    = null_free_repbuf,
d7e09d039 Peng Tao 2013-05-02  390  	.enlarge_reqbuf	 = null_enlarge_reqbuf,
d7e09d039 Peng Tao 2013-05-02  391  };
d7e09d039 Peng Tao 2013-05-02  392  
d7e09d039 Peng Tao 2013-05-02  393  static struct ptlrpc_sec_sops null_sec_sops = {
d7e09d039 Peng Tao 2013-05-02  394  	.accept		 = null_accept,
d7e09d039 Peng Tao 2013-05-02  395  	.alloc_rs	       = null_alloc_rs,
d7e09d039 Peng Tao 2013-05-02  396  	.authorize	      = null_authorize,
d7e09d039 Peng Tao 2013-05-02  397  	.free_rs		= null_free_rs,
d7e09d039 Peng Tao 2013-05-02  398  };
d7e09d039 Peng Tao 2013-05-02  399  
d7e09d039 Peng Tao 2013-05-02  400  static struct ptlrpc_sec_policy null_policy = {
d7e09d039 Peng Tao 2013-05-02  401  	.sp_owner	       = THIS_MODULE,
d7e09d039 Peng Tao 2013-05-02  402  	.sp_name		= "sec.null",
d7e09d039 Peng Tao 2013-05-02  403  	.sp_policy	      = SPTLRPC_POLICY_NULL,
d7e09d039 Peng Tao 2013-05-02 @404  	.sp_cops		= &null_sec_cops,
d7e09d039 Peng Tao 2013-05-02  405  	.sp_sops		= &null_sec_sops,
d7e09d039 Peng Tao 2013-05-02  406  };
d7e09d039 Peng Tao 2013-05-02  407  
d7e09d039 Peng Tao 2013-05-02  408  static void null_init_internal(void)
d7e09d039 Peng Tao 2013-05-02  409  {
d7e09d039 Peng Tao 2013-05-02  410  	static HLIST_HEAD(__list);
d7e09d039 Peng Tao 2013-05-02  411  
d7e09d039 Peng Tao 2013-05-02  412  	null_sec.ps_policy = &null_policy;

:::::: The code at line 404 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 42380 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151124/ef8ffe65/attachment-0001.obj>
