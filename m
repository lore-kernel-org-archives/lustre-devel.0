From: Smith, Stan <stan.smith@intel.com>
Date: Mon, 2 Nov 2015 20:46:10 +0000
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running
 a kernel.org linux-3.12.39
In-Reply-To: <D25D229F.28B1%jevans@cray.com>
References: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
	<5637B5CB.9090106@cray.com> <D25D229F.28B1%jevans@cray.com>
Message-ID: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FEB0@ORSMSX105.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Ben Evans
Sent: Monday, November 2, 2015 11:26 AM
To: Patrick Farrell <paf@cray.com>; lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] porting Lustre server to RHEL6.7 distro running a kernel.org linux-3.12.39

Using ZFS as a backing filesystem may be a simpler way to go here if you want to stay with kernel.org.  The lustre server + ZFS is patchless, and if you're writing a new LND, you probably don't care about the backing filesystem anyway.

You are 100% spot-on, at this juncture in the LND development, I don't really care so much about the backing filesystem; whatever builds/works such that I can continue LND testing in the client/server environment. I suspect a large step between LNet selftests and full-on LFS.

It's Monday after a time zone change, hence a small clarification on your statement 'The lustre server + ZFS is patchless'.
By patchless you saying the lustre source kernel patches are not required when using ZFS? Just to be crystal-clear.

Stan.


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
  I'm currently unable to search the lustre-devel archives + 1st post to this list.

Having read lustre documentation I find only references to building lustre server for stock 'distro' kernels.

Does someone have suggestions on how to patch ldiskfs for a kernel.org kernel.....specifically weeding out RHEL/SLES/* distro FS enhancements from a kernel.org base?

I have written a Reliable Datagram LND which passes the LNet selftests (client lustre build) now entering the world of lustre server building.
Patching the kernel.org kernel for lustre server was fairly straightforward, creating the patch series for ldiskfs is another story.

Thanks,

Stan.




_______________________________________________

lustre-devel mailing list

lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/745814fa/attachment.htm>
