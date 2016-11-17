From: kbuild test robot <lkp@intel.com>
Date: Fri, 18 Nov 2016 05:46:13 +0800
Subject: [lustre-devel] [PATCH v2] staging: lustre: llog: fix wrong
 offset in llog_process_thread()
In-Reply-To: <1479411818-30863-1-git-send-email-jsimmons@infradead.org>
Message-ID: <201611180531.NI3A2Y05%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Mikhail,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on next-20161117]
[cannot apply to v4.9-rc5]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/staging-lustre-llog-fix-wrong-offset-in-llog_process_thread/20161118-042856
config: i386-allmodconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/obdclass/llog.c: In function 'llog_process_thread':
>> drivers/staging/lustre/lustre/obdclass/llog.c:221:12: warning: unused variable 'last_offset' [-Wunused-variable]
     __u64     last_offset;
               ^~~~~~~~~~~

vim +/last_offset +221 drivers/staging/lustre/lustre/obdclass/llog.c

d7e09d039 Peng Tao           2013-05-02  205  	if (rc) {
11c647caf Andreas Dilger     2016-10-27  206  		kvfree(llh);
d7e09d039 Peng Tao           2013-05-02  207  		handle->lgh_hdr = NULL;
d7e09d039 Peng Tao           2013-05-02  208  	}
0a3bdb007 Greg Kroah-Hartman 2013-08-03  209  	return rc;
d7e09d039 Peng Tao           2013-05-02  210  }
d7e09d039 Peng Tao           2013-05-02  211  EXPORT_SYMBOL(llog_init_handle);
d7e09d039 Peng Tao           2013-05-02  212  
d7e09d039 Peng Tao           2013-05-02  213  static int llog_process_thread(void *arg)
d7e09d039 Peng Tao           2013-05-02  214  {
d7e09d039 Peng Tao           2013-05-02  215  	struct llog_process_info	*lpi = arg;
d7e09d039 Peng Tao           2013-05-02  216  	struct llog_handle		*loghandle = lpi->lpi_loghandle;
d7e09d039 Peng Tao           2013-05-02  217  	struct llog_log_hdr		*llh = loghandle->lgh_hdr;
d7e09d039 Peng Tao           2013-05-02  218  	struct llog_process_cat_data	*cd  = lpi->lpi_catdata;
d7e09d039 Peng Tao           2013-05-02  219  	char				*buf;
ede733b28 Mikhail Pershin    2016-11-17  220  	u64				 cur_offset, tmp_offset;
d7e09d039 Peng Tao           2013-05-02 @221  	__u64				 last_offset;
11c647caf Andreas Dilger     2016-10-27  222  	int chunk_size;
d7e09d039 Peng Tao           2013-05-02  223  	int				 rc = 0, index = 1, last_index;
d7e09d039 Peng Tao           2013-05-02  224  	int				 saved_index = 0;
d7e09d039 Peng Tao           2013-05-02  225  	int				 last_called_index = 0;
d7e09d039 Peng Tao           2013-05-02  226  
11c647caf Andreas Dilger     2016-10-27  227  	if (!llh)
11c647caf Andreas Dilger     2016-10-27  228  		return -EINVAL;
11c647caf Andreas Dilger     2016-10-27  229  

:::::: The code at line 221 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 56934 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161118/6db721af/attachment-0001.bin>
