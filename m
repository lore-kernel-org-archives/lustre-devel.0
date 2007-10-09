From: serge at terascala.com <serge@terascala.com>
Date: Tue, 9 Oct 2007 14:52:12 -0600
Subject: [Lustre-devel] [Bug 13840] New: Problems compiling with OFED 1.2.5
Message-ID: <200710092052.l99KqCI1019435@shell.clusterfs.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Please don't reply to lustre-devel. Instead, comment in Bugzilla by using the following link:
https://bugzilla.lustre.org/show_bug.cgi?id=13840



When I try to compile the lnet module o2ib with OFED 1.2.5.1, I get the
following error: 
/local/home/serge/2.6.16-46/bnx2/lustre/1.6.2/trunk/lustre_shadow_dir/lnet/klnds/o2iblnd/o2iblnd.c
In file included from
/usr/local/home/serge/2.6.16-46/bnx2/lustre/1.6.2/trunk/lustre_shadow_dir/lnet/klnds/o2iblnd/o2iblnd.c:24:
/usr/local/home/serge/2.6.16-46/bnx2/lustre/1.6.2/trunk/lustre_shadow_dir/lnet/klnds/o2iblnd/o2iblnd.h:330:
error: parse error before "DECLARE_PCI_UNMAP_ADDR"

Serge Pirotte
Terascala
