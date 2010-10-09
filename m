From: Jay Lan <jay.zen.lan@gmail.com>
Date: Fri, 08 Oct 2010 18:16:05 -0700
Subject: [Lustre-devel] How was lustre-1.8.4.tar.gz created?
Message-ID: <4CAFC255.8090906@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There is a lustre-1.8.4.tar.gz 
<http://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_SMI-Site/en_US/-/USD/VerifyItem-Start/lustre-1.8.4.tar.gz?BundledLineItemUUID=neSJ_hCyazAAAAErvoBKP45J&OrderID=z0qJ_hCyYf0AAAErAH9KP45J&ProductID=QUOJ_hCxLIwAAAEqfGgMmTUo&FileName=/lustre-1.8.4.tar.gz> 
at the download site.
At the top dir, comparing to the tree you check out from
git, it does not have augogen.sh and misses the libcfs
directory completely, but it contains tree_status that
should be generated later in building.

So, how was lustre-1.8.4.tar.gz generated?
I used 'git archive v1_8_4' to populate a workarea,
and built lustre software with that. The resulting rpm
caused 2.6.18-194.3.1 kernel to crash when modprobe
lustre.ko at  ib_core:rdma_node_get_transport+0x14/0x2.
However, if I built using the tar ball from the download area,
it worked great. So, what was the trick? How would I be able
to build a 1.8.4 for rhel5.5 from the git repository?

Thanks,
Jay
