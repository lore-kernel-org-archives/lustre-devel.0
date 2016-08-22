From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Aug 2016 18:07:20 +0100 (BST)
Subject: [lustre-devel] [linux-next:master 1892/3082]
 drivers/staging/lustre/lustre/llite/xattr.c:309:24: warning: unused
 variable 'lli'
In-Reply-To: <201608222300.modY0gpw%fengguang.wu@intel.com>
References: <201608222300.modY0gpw%fengguang.wu@intel.com>
Message-ID: <alpine.LFD.2.20.1608221803340.9872@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   d18b09e429ad4520272dcdcd8faa01aabc171fd0
> commit: 1e1f9ff406fd5f6003a5dab2ab5a26c4c5bb8cbd [1892/3082] staging: lustre: llite: break ll_getxattr_common into 2 functions
> config: x86_64-randconfig-s3-08200515 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         git checkout 1e1f9ff406fd5f6003a5dab2ab5a26c4c5bb8cbd
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    drivers/staging/lustre/lustre/llite/xattr.c: In function 'll_getxattr_common':
> >> drivers/staging/lustre/lustre/llite/xattr.c:309:24: warning: unused variable 'lli' [-Wunused-variable]
>      struct ll_inode_info *lli = ll_i2info(inode);
>                            ^~~

Besides this warning Oleg found in testing a regression with the new 
xattr hander code that I didn't see  so this coming weekend I will 
investigate and with that fix include this cleanup.
