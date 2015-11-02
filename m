From: Smith, Stan <stan.smith@intel.com>
Date: Mon, 2 Nov 2015 19:35:56 +0000
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running
 a kernel.org linux-3.12.39
In-Reply-To: <5637B5CB.9090106@cray.com>
References: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
	<5637B5CB.9090106@cray.com>
Message-ID: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FE29@ORSMSX105.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Patrick Farrell
Sent: Monday, November 2, 2015 11:13 AM
To: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] porting Lustre server to RHEL6.7 distro running a kernel.org linux-3.12.39

Stan,

Why not work with the CentOS 7 kernel on the server anyway?  Is something your LND needs not available?  CentOS 7 is freely available and isn't far off in terms of kernel version from 3.12.

Yes -I'm somewhat stuck on RHEL 6.x series as I use warewulf as a cluster provisioning system (diskless compute nodes), so far have not found a functional warewulf for RHEL7.
I did choose linux-3.12.39 as a kernel base believing it to be somewhat close to RHEL7; although I'm finding this to less so than hoped for....
Additionally the RD drivers I'm using have not been ported to RHEL7;
In examining lustre-2_7.62 I found support for sles12 based on 3.12.39 kernel.; thinking the lustre patches would be close...
So now I'm wedged between RHEL7 ldiskfs patches and SLES12 ldiskfs patches - figure out distro specific enhancements vs lustre enhancements.

You may be hard pressed to get useful advice on changing the ldiskfs patch series, that has the potential to be a pretty big job.

I'm starting to understand the magnitude of the ldiskfs task.......

I'm ignorant about zfs*, would zfs be a better (read that as path-of-least-resistance) approach ?  What are the zfs pitfalls?

Thanks,

Stan.


Regards,
- Patrick Farrell
On 11/02/2015 01:05 PM, Smith, Stan wrote:
Hello,
  I'm currently unable to search the lustre-devel archives + 1st post to this list.

Having read lustre documentation I find only references to building lustre server for stock 'distro' kernels.

Does someone have suggestions on how to patch ldiskfs for a kernel.org kernel.....specifically weeding out RHEL/SLES/* distro FS enhancements from a kernel.org base?

I have written a Reliable Datagram LND which passes the LNet selftests (client lustre build) now entering the world of lustre server building.
Patching the kernel.org kernel for lustre server was fairly straightforward, creating the patch series for ldiskfs is another story.

Thanks,

Stan.




_______________________________________________

lustre-devel mailing list

lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>

http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/a13f51df/attachment-0001.htm>
