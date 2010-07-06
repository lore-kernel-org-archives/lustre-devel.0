From: Dan Bassett <dbassett@oreilly.com>
Date: Tue, 06 Jul 2010 14:05:24 -0500
Subject: [Lustre-devel] e2fsprogs-1.41.10.sun2-0redhat provides issues
Message-ID: <4C337E74.2060306@oreilly.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I have e2fsprogs-1.41.10.sun2-0redhat from the lustre downloads page 
installed as part of my lustre 1.8.3 installation and it's causing some 
weird dependency issues on my OSS's.  When I attempt to upgrade or 
install new packages on the system I get errors like:

krb5-libs-1.6.1-36.el5_5.4.i386 from updates has depsolving problems
  --> Missing Dependency: libcom_err.so.2 is needed by package 
krb5-libs-1.6.1-36.el5_5.4.i386 (updates)

libcom_err.so.2 is provided as part of the lustre patched e2fsprogs 
package, whereas it is usually part of e2fsprogs-libs if you get it 
directly from redhat.  The issue seems to be in how the provides are 
defined for the package:

[root at oss0 ~]# rpm -q --provides e2fsprogs
e2fsprogs-libs = 1.41.10.sun2
ldiskfsprogs 
libblkid.so.1()(64bit) 
libcom_err.so.2()(64bit) 
libe2p.so.2()(64bit) 
libext2fs.so.2()(64bit) 
libss.so.2()(64bit) 
libuuid.so.1()(64bit) 
e2fsprogs = 1.41.10.sun2-0redhat

And on a CentOS 5 machine that doesn't have lustre installed:

[root at node2 ~]# rpm -q --provides e2fsprogs-libs
libblkid.so.1()(64bit) 
libcom_err.so.2()(64bit) 
libe2p.so.2()(64bit) 
libext2fs.so.2()(64bit) 
libss.so.2()(64bit) 
libuuid.so.1()(64bit) 
e2fsprogs-libs = 1.39-23.el5
libblkid.so.1 
libcom_err.so.2 
libe2p.so.2 
libext2fs.so.2 
libss.so.2 
libuuid.so.1 
e2fsprogs-libs = 1.39-23.el5

More to the point:
[root at oss0 ~]# rpm -q --whatprovides libcom_err.so.2
no package provides libcom_err.so.2
[root at oss0 ~]# rpm -q --whatprovides "libcom_err.so.2()(64bit)"
e2fsprogs-1.41.10.sun2-0redhat

The library is installed, however my guess is that due to the extra 
"()(64bit)" in the provides, rpm refuses to recognize it.  Is this 
something that can be fixed in the e2fsprogs package?  Thanks!

Dan
