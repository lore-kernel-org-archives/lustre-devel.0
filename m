From: Benjamin Bennett <ben@psc.edu>
Date: Mon, 23 Jun 2008 23:11:02 -0400
Subject: [Lustre-devel] Unsafe directory modes in lustre-source RPMs
Message-ID: <486065C6.7020302@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lustre.spec uses 'make distdir ...' to setup the source tree which will 
be packaged into the lustre-source rpm.

Automake sets all directories in the distdir tree to mode 777 
(world-writable, search for "brain-dead tar" in 
/usr/share/automake-1.7/am/distdir.am).

These modes are kept in rpm packaging, and once the rpm is installed 
/usr/src/lustre-${version} and its descendant directories will be mode 
777 (world-writable).

This can be seen in the release rpms, and those generated from cvs, with 
a command such as:
  $ rpm -qlp --dump lustre-source.rpm | \
    awk '{if ($5 ~ "^04") print $5,$1}'


This is obviously less than ideal for any system with unprivileged 
users.  I've added a find setting the directory modes to 755 just after 
the make distdir (see patch).  Please let me know if there's any reason 
this can't be committed.


thanks,

--ben
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lustre-source-fix-unsafe-dir-modes.patch
Type: text/x-patch
Size: 557 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080623/b7b54cb4/attachment.bin>
