From: wenjing wu <wuwj@umich.edu>
Date: Fri, 12 Dec 2008 16:14:01 -0500
Subject: [Lustre-devel] building lustre from source on Linux kernel 2.6.24
Message-ID: <01ac01c95c9e$8e941f70$4262d38d@um7d7332d2a74e>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi, 

I was trying to build lustre from the source (lustre-source-1.6.6-2.6.9_67.0.22.EL_lustre.1.6.6smp.x86_64) on linux kernel 2.6.24, but it failed with these errors:

/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:315:47: macro "bio_io_error" passed 2 arguments, but takes just 1
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c: In function `loop_make_request':
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:315: error: `bio_io_error' undeclared (first use in this function)
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:315: error: (Each undeclared identifier is reported only once
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:315: error: for each function it appears in.)
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c: At top level:
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:325: warning: `request_queue_t' is deprecated (declared at /usr/src/kernels/2.6.24-7UL3-smp-x86_64//include/linux/blkdev.h:26)
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c: In function `loop_handle_bio':
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.c:337: error: too many arguments to function `bio_endio'
make[8]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite/lloop.o] Error 1
make[7]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lustre/llite] Error 2
make[7]: *** Waiting for unfinished jobs....
/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function `kiblnd_setup_rd_iov':
/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd/o2iblnd_cb.c:646: error: structure has no member named `page'
/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function `kiblnd_setup_rd_kiov':
/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd/o2iblnd_cb.c:711: error: structure has no member named `page'
make[9]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd/o2iblnd_cb.o] Error 1
make[9]: *** Waiting for unfinished jobs....
make[8]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds/o2iblnd] Error 2
make[7]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lnet/klnds] Error 2
make[7]: *** Waiting for unfinished jobs....
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/lov/lproc_lov.c: In function `lov_target_seq_open':
/usr/src/redhat/BUILD/lustre-1.6.6/lustre/lov/lproc_lov.c:323: error: structure has no member named `deleted'
make[8]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lustre/lov/lproc_lov.o] Error 1
make[8]: *** Waiting for unfinished jobs....
make[7]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lustre/lov] Error 2
make[6]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lustre] Error 2
make[6]: *** Waiting for unfinished jobs....
make[6]: *** [/usr/src/redhat/BUILD/lustre-1.6.6/lnet] Error 2
make[5]: *** [_module_/usr/src/redhat/BUILD/lustre-1.6.6] Error 2
make[5]: Leaving directory `/usr/src/kernels/2.6.24-7UL3-smp-x86_64'
make[4]: *** [modules] Error 2
make[4]: Leaving directory `/usr/src/redhat/BUILD/lustre-1.6.6'
make[3]: *** [all-recursive] Error 1
make[3]: Leaving directory `/usr/src/redhat/BUILD/lustre-1.6.6'
make[2]: *** [all] Error 2
make[2]: Leaving directory `/usr/src/redhat/BUILD/lustre-1.6.6'
error: Bad exit status from /var/tmp/rpm-tmp.80654 (%build)


RPM build errors:
    Bad exit status from /var/tmp/rpm-tmp.80654 (%build)
make[1]: *** [rpms-real] Error 1
make[1]: Leaving directory `/usr/src/lustre-1.6.6'



but I could build it successfully on kernel both 2.6.9 and 2.6.20, I wonder if  the recent lustre 1.6.6 surports the 2.6.24 kernel , 


thanks


wenjing 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081212/6b2473a0/attachment.htm>
