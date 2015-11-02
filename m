From: Ben Evans <bevans@cray.com>
Date: Mon, 2 Nov 2015 19:25:54 +0000
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running
 a kernel.org linux-3.12.39
In-Reply-To: <5637B5CB.9090106@cray.com>
References: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
	<5637B5CB.9090106@cray.com>
Message-ID: <D25D229F.28B1%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Using ZFS as a backing filesystem may be a simpler way to go here if you want to stay with kernel.org.  The lustre server + ZFS is patchless, and if you?re writing a new LND, you probably don?t care about the backing filesystem anyway.

-Ben Evans

From: lustre-devel <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>> on behalf of Patrick Farrell <paf at cray.com<mailto:paf@cray.com>>
Date: Monday, November 2, 2015 at 3:13 PM
To: "lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>" <lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Subject: Re: [lustre-devel] porting Lustre server to RHEL6.7 distro running a kernel.org linux-3.12.39

Stan,

Why not work with the CentOS 7 kernel on the server anyway?  Is something your LND needs not available?  CentOS 7 is freely available and isn't far off in terms of kernel version from 3.12.

You may be hard pressed to get useful advice on changing the ldiskfs patch series, that has the potential to be a pretty big job.

Regards,
- Patrick Farrell
On 11/02/2015 01:05 PM, Smith, Stan wrote:
Hello,
  I?m currently unable to search the lustre-devel archives + 1st post to this list.

Having read lustre documentation I find only references to building lustre server for stock ?distro? kernels.

Does someone have suggestions on how to patch ldiskfs for a kernel.org kernel?..specifically weeding out RHEL/SLES/* distro FS enhancements from a kernel.org base?

I have written a Reliable Datagram LND which passes the LNet selftests (client lustre build) now entering the world of lustre server building.
Patching the kernel.org kernel for lustre server was fairly straightforward, creating the patch series for ldiskfs is another story.

Thanks,

Stan.



_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/89540b8b/attachment.htm>
