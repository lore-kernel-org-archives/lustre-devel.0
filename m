From: Patrick Farrell <paf@cray.com>
Date: Mon, 2 Nov 2015 13:13:15 -0600
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running
 a kernel.org linux-3.12.39
In-Reply-To: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
References: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
Message-ID: <5637B5CB.9090106@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Stan,

Why not work with the CentOS 7 kernel on the server anyway?  Is 
something your LND needs not available?  CentOS 7 is freely available 
and isn't far off in terms of kernel version from 3.12.

You may be hard pressed to get useful advice on changing the ldiskfs 
patch series, that has the potential to be a pretty big job.

Regards,
- Patrick Farrell
On 11/02/2015 01:05 PM, Smith, Stan wrote:
>
> Hello,
>
>   I'm currently unable to search the lustre-devel archives + 1^st post 
> to this list.
>
> Having read lustre documentation I find only references to building 
> lustre server for stock 'distro' kernels.
>
> Does someone have suggestions on how to patch ldiskfs for a kernel.org 
> kernel.....specifically weeding out RHEL/SLES/* distro FS enhancements 
> from a kernel.org base?
>
> I have written a Reliable Datagram LND which passes the LNet selftests 
> (client lustre build) now entering the world of lustre server building.
>
> Patching the kernel.org kernel for lustre server was fairly 
> straightforward, creating the patch series for ldiskfs is another story.
>
> Thanks,
>
> Stan.
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/e9b4448b/attachment.htm>
