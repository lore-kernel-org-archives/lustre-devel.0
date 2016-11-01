From: W. Zhang <wszhang159@gmail.com>
Date: Tue, 1 Nov 2016 10:15:20 +0800
Subject: [lustre-devel] Failed to build a Lustre Storage Client on OpenVZ
	Kernel ! Is this a bug?
Message-ID: <CAAXb9Ms-4+aDuS10g3Y4qbPiJyaP74Fk-Gh+4=7KaTLacvAZRA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I'm trying to build a Lustre client on OpenVZ kernel (version:
042stab120.5, based on RHEL 6.8 kernel 2.6.32-642.6.1.el6), and some bugs
occured:

(1) When build version v2_8_59_0 in git tag repo of Lustre, I encountered
the following errors:
"
LD [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/fld/ fld.o
CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/lloop.o
In file included from
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit e/lloop.c:109:
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/llite_internal.h:1469: error: conflicting types for 'iov_iter_iovec'
include/linux/fs.h:765: note: previous definition of 'iov_iter_iovec' was
here
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/llite_internal.h: In function 'iov_iter_iovec':
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/llite_internal.h:1472: error: 'const struct iov_iter' has no member named
'iov'
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/llite_internal.h:1473: error: 'const struct iov_iter' has no member named
'iov'
cc1: warnings being treated as errors
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/llite_internal.h:1473: error: type defaults to 'int' in declaration of
'_min2'
...
"

(2) When build old version v2_8_50_0 in git tag repo of Lustre, the
following errors display:
"
CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/vvp_lock.o
CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/vvp_io.o
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit e/vvp_io.c: In
function 'vvp_mmap_locks':
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/vvp_io.c:423: error: 'struct iov_iter' has no member named 'iov'
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit e/vvp_io.c: In
function 'vvp_io_advance':
/opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
e/vvp_io.c:514: error: 'struct iov_iter' has no member named 'iov'
...
"

Files with full error context are attached.

So, How can I fix the problem? Is this a bug which need to be fixed?

Thanks! Any suggestion is appreciated!

Best Wishes!
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161101/790a900f/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: log.zip
Type: application/zip
Size: 13180 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161101/790a900f/attachment.zip>
