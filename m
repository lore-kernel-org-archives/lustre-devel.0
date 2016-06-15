From: Jay Lan <jay.j.lan@nasa.gov>
Date: Wed, 15 Jun 2016 16:57:50 -0700
Subject: [lustre-devel] lustre 2.7.1 server 2.7.1-5.1nasS tarball
Message-ID: <5761EB7E.1020100@nasa.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Mahmoud,

I cherry-picked LU-6911 <https://jira.hpdd.intel.com/browse/LU-6911> 
ldiskfs: mds crash kernel at fs/inode.c:1358
patch set #4 and built a new 2.7.1 server 5.1nasS tarball.

This patch is to fix the LU-8286 problem we experienced at nbp9 today:
     LU-8286: kernel BUG at fs/inode.c:1358!

The patch I cherry-picked had conflicts at a rhel7 code. Since we
are running centos 6.6, I cherry-picked the patch without the changes
to ldiskfs/kernel_patches/patches/rhel7/ext4-large-eas.patch.

When the fix (to conflicts) is available, today's patch will be reverted
for the new patch.

Here is the tarball at lfe:~jlan/swbuild/lustre271/
     lustre-2.7.1-5.1nasS_mofed31v5.el66.20151008.tgz

Thanks,
Jay

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160615/44d444f7/attachment.htm>
