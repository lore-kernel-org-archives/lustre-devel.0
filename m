From: Smith, Stan <stan.smith@intel.com>
Date: Mon, 2 Nov 2015 19:05:30 +0000
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running a
 kernel.org linux-3.12.39
Message-ID: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
  I'm currently unable to search the lustre-devel archives + 1st post to this list.

Having read lustre documentation I find only references to building lustre server for stock 'distro' kernels.

Does someone have suggestions on how to patch ldiskfs for a kernel.org kernel.....specifically weeding out RHEL/SLES/* distro FS enhancements from a kernel.org base?

I have written a Reliable Datagram LND which passes the LNet selftests (client lustre build) now entering the world of lustre server building.
Patching the kernel.org kernel for lustre server was fairly straightforward, creating the patch series for ldiskfs is another story.

Thanks,

Stan.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/997dc499/attachment-0001.htm>
