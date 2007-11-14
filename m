From: Jody McIntyre <scjody@sun.com>
Date: Wed, 14 Nov 2007 16:58:04 -0500
Subject: [Lustre-devel] [Lustre-discuss] ZFS/DMU benchmarks
In-Reply-To: <47398F16.5000504@Sun.COM>
References: <C882B223-8FE1-4FA1-9885-97BDFD20B1E7@sun.com>
	<47398F16.5000504@Sun.COM>
Message-ID: <20071114215804.GJ6168@modernduck.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ricardo,

On Tue, Nov 13, 2007 at 11:48:38AM +0000, Ricardo Correia wrote:

> Here are some current ZFS/DMU benchmark results that might be of 
> interest to you.

It's nice to see these results - thanks for posting them.  When you have
time, could you do a comparison with Lustre 1.6.x on ldiskfs + software
RAID 5?  It would be good to know how ZFS stands up (probably quite
favourably, even at this early stage.)

Cheers,
Jody

> These results were obtained on a Sunfire x4500 with these specifications:
> 
> - 2 dual-core AMD Opteron processors
> - 16 GB main memory
> - 48 SATA II HDD (7200 RPM, 500 GB each)
> - Solaris 10 update 3
> - Userspace DMU from OpenSolaris build 74
> 
> The tool used in this particular benchmark was PIOS, which simulates a 
> parallel I/O load typically experienced by an OSS. Since PIOS links 
> directly with the DMU, it should give a good estimation of the maximum 
> throughput of the userspace DMU-OSS. For comparison, you can also see 
> the results of running the same PIOS benchmark with normal POSIX I/O on 
> the Solaris 10u3 ZFS implementation.
> 
> See the attached PDF for the results.
> 
> First page provides PIOS throughput information on striped pools with 
> 10, 24 and 46 disks. uDMU outperforms kernel ZFS with 10 disks, however, 
> the kernel ZFS implementation scales better to 24 and 46 disks. 
> Surprisingly enough, disabling checksums has a negative impact on the 
> throughput with a 10-disk striped pool. This impact can be attributed to 
> the differences in the uDMU IO pipeline which are probably causing the 
> IOs to not being parallelized when checksumming is disabled. This issue, 
> however, should not be hard to fix.
> 
> Second page shows the results of running PIOS on RAID-Z, RAID-Z2 and 
> mirrored pools. In these configurations, the kernel ZFS currently has a 
> better throughput than the userspace DMU.
> 
> These results were obtained with only minimal tuning of the DMU (setting 
> a maximum cache size and increasing the number of I/O threads). Work is 
> already underway to improve the performance of the DMU and we expect to 
> see better throughput in the coming months.
> 
> Best regards,
> Ricardo
> 
> -- 
> <http://www.sun.com> 	* Ricardo Manuel Correia *
> 
> Lustre Engineering Group
> *Sun Microsystems, Inc.*
> Portugal
> 
> Ricardo.M.Correia at Sun.COM
> 


> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at clusterfs.com
> https://mail.clusterfs.com/mailman/listinfo/lustre-discuss


-- 
