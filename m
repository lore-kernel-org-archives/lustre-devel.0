From: kelly.zhang at emc.com <kelly.zhang@emc.com>
Date: Thu, 8 Mar 2012 05:01:10 -0500
Subject: [Lustre-devel] if "--enable-split" option is still (or to be)
	supported?
Message-ID: <F62E2618FCA29E42AB21F281C9511BB413751B6FC1@MX26A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

I am configuring and building Lustre.  While I met a problem which needs you guys to take a look.

When compiling with "--enable-split" option, "make rpms" will fail.  But if without this option, it works correctly.

The error message would look like:
$ ./configure  --enable-split   --with-linux=/home/build/kernel/rpmbuild/BUILD/kernel-2.6.32-220.4.2.el6/linux-2.6.32-220.4.2.el6.x86_64/
$ make rpms
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c: In function 'cmm_object_find':
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c:256: error: 'fid' undeclared (first use in this function)
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c:256: error: (Each undeclared identifier is reported only once
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c:256: error: for each function it appears in.)
  cc1: warnings being treated as errors
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c: In function 'cmm_split_slave_create':
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c:309: error: format '%llu' expects type 'long long unsigned int', but argument 10 has type 'mdsno_t'
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c: In function 'cmm_split_dir':
  /home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.c:742: error: 'MDS_LMV_MD_NAME' undeclared (first use in this function)
  make[8]: *** [/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm/cmm_split.o] Error 1
  make[7]: *** [/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre/cmm] Error 2
  make[6]: *** [/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56/lustre] Error 2
  make[5]: *** [_module_/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56] Error 2
  make[5]: Leaving directory `/home/build2/kernel/rpmbuild/BUILD/kernel-2.6.32-220.4.2.el6/linux-2.6.32-220.4.2.el6.x86_64'
  make[4]: *** [modules] Error 2
  make[4]: Leaving directory `/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56'
  make[3]: *** [all-recursive] Error 1
  make[3]: Leaving directory `/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56'
  make[2]: *** [all] Error 2
  make[2]: Leaving directory `/home/build2/kernel/rpmbuild/BUILD/lustre-2.1.56'
  error: Bad exit status from /var/tmp/rpm-tmp.NXaQK0 (%build)

kernel source used: 2.6.32-220.4.2.el6.x86_64

After checking the related code, it seems that piece of code is either still under development or silently dropped:
git blame cmm_split.c -L252,257
d2d56f38 (tappro 2007-07-30 21:08:59 +0000 252) struct cmm_object *cmm_object_find(const struct lu_env *env,
d2d56f38 (tappro 2007-07-30 21:08:59 +0000 253)                                    struct cmm_device *d,
d2d56f38 (tappro 2007-07-30 21:08:59 +0000 254)                                    const struct lu_fid *f)
d2d56f38 (tappro 2007-07-30 21:08:59 +0000 255) {
0ad352cf (nikita 2008-10-18 17:14:45 +0000 256)         return md2cmm_obj(md_object_find_slice(env, &d->cmm_md_dev, fid));
d2d56f38 (tappro 2007-07-30 21:08:59 +0000 257) }

So:  Just want to confirm that if "--enable-split" is still (or to be) supported?


Thanks for your time. Your help are much more appreciated.

Best Regards,
Kelly Zhang(EMC)
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120308/81bdb0c9/attachment.htm>
