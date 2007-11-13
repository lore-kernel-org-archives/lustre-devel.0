From: Ricardo Correia <Ricardo.M.Correia@Sun.COM>
Date: Tue, 13 Nov 2007 11:48:38 +0000
Subject: [Lustre-devel] ZFS/DMU benchmarks
In-Reply-To: <C882B223-8FE1-4FA1-9885-97BDFD20B1E7@sun.com>
References: <C882B223-8FE1-4FA1-9885-97BDFD20B1E7@sun.com>
Message-ID: <47398F16.5000504@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi everyone,

Here are some current ZFS/DMU benchmark results that might be of 
interest to you.
These results were obtained on a Sunfire x4500 with these specifications:

- 2 dual-core AMD Opteron processors
- 16 GB main memory
- 48 SATA II HDD (7200 RPM, 500 GB each)
- Solaris 10 update 3
- Userspace DMU from OpenSolaris build 74

The tool used in this particular benchmark was PIOS, which simulates a 
parallel I/O load typically experienced by an OSS. Since PIOS links 
directly with the DMU, it should give a good estimation of the maximum 
throughput of the userspace DMU-OSS. For comparison, you can also see 
the results of running the same PIOS benchmark with normal POSIX I/O on 
the Solaris 10u3 ZFS implementation.

See the attached PDF for the results.

First page provides PIOS throughput information on striped pools with 
10, 24 and 46 disks. uDMU outperforms kernel ZFS with 10 disks, however, 
the kernel ZFS implementation scales better to 24 and 46 disks. 
Surprisingly enough, disabling checksums has a negative impact on the 
throughput with a 10-disk striped pool. This impact can be attributed to 
the differences in the uDMU IO pipeline which are probably causing the 
IOs to not being parallelized when checksumming is disabled. This issue, 
however, should not be hard to fix.

Second page shows the results of running PIOS on RAID-Z, RAID-Z2 and 
mirrored pools. In these configurations, the kernel ZFS currently has a 
better throughput than the userspace DMU.

These results were obtained with only minimal tuning of the DMU (setting 
a maximum cache size and increasing the number of I/O threads). Work is 
already underway to improve the performance of the DMU and we expect to 
see better throughput in the coming months.

Best regards,
Ricardo

-- 
<http://www.sun.com> 	* Ricardo Manuel Correia *

Lustre Engineering Group
*Sun Microsystems, Inc.*
Portugal

Ricardo.M.Correia at Sun.COM

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20071113/a7e9a9ee/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: Lustre-uDMU.pdf
Type: application/pdf
Size: 66695 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20071113/a7e9a9ee/attachment.pdf>
