From: kbuild test robot <lkp@intel.com>
Date: Fri, 28 Oct 2016 07:40:43 +0800
Subject: [lustre-devel] [PATCH 12/29] staging: lustre: mdc: manage
 number of modify RPCs in flight
In-Reply-To: <1477606323-30325-13-git-send-email-jsimmons@infradead.org>
Message-ID: <201610280708.j7eKR02q%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Gregoire,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on next-20161027]
[cannot apply to v4.9-rc2]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/Batch-one-for-work-from-2-7-55-to-2-7-59/20161028-061814
config: openrisc-allmodconfig (attached as .config)
compiler: or32-linux-gcc (GCC) 4.5.1-or32-1.0rc1
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/obdclass/genops.c: In function 'obd_mod_rpc_stats_seq_show':
>> drivers/staging/lustre/lustre/obdclass/genops.c:1518:6: warning: format '%lu' expects type 'long unsigned int', but argument 3 has type 'time64_t'

vim +1518 drivers/staging/lustre/lustre/obdclass/genops.c

  1502	}
  1503	EXPORT_SYMBOL(obd_set_max_mod_rpcs_in_flight);
  1504	
  1505	#define pct(a, b) (b ? (a * 100) / b : 0)
  1506	
  1507	int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
  1508	{
  1509		unsigned long mod_tot = 0, mod_cum;
  1510		struct timespec64 now;
  1511		int i;
  1512	
  1513		ktime_get_real_ts64(&now);
  1514	
  1515		spin_lock(&cli->cl_mod_rpcs_lock);
  1516	
  1517		seq_printf(seq, "snapshot_time:         %lu.%lu (secs.usecs)\n",
> 1518			   now.tv_sec, now.tv_nsec / 1000);
  1519		seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
  1520			   cli->cl_mod_rpcs_in_flight);
  1521	
  1522		seq_puts(seq, "\n\t\t\tmodify\n");
  1523		seq_puts(seq, "rpcs in flight        rpcs   %% cum %%\n");
  1524	
  1525		mod_tot = lprocfs_oh_sum(&cli->cl_mod_rpcs_hist);
  1526	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 39323 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161028/ffa2d0c0/attachment-0001.bin>
