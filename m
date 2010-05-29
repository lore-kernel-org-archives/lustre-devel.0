From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Sat, 29 May 2010 12:56:44 +0300
Subject: [Lustre-devel] a bug in "lfs find" command (patch attached)
Message-ID: <AANLkTilhS3lwnn0q-V0VdoDfj6j1x_gt0vWNurpDJihB@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hi Lustre people,

One of our clients has found the bug in lfs find, which we have fixed. Patch
is attached. Issue is that find_value_cmp() and how it gets params are
buggy. Inversion made by inverting sign is completely wrong idea. Please see
the patch for details.

Examples:

Let's create some files and try to find them:

[root at victim tests]# touch /mnt/lustre/a
[root at victim tests]# touch /mnt/lustre/b
[root at victim tests]# echo 1 > /mnt/lustre/c
[root at victim tests]# ls -la /mnt/lustre/
total 12
drwxr-xr-x  2 root root 4096 May 29 12:31 .
drwxr-xr-x 11 root root 4096 May  4 22:50 ..
-rw-r--r--  1 root root    0 May 29 12:31 a
-rw-r--r--  1 root root    0 May 29 12:31 b
-rw-r--r--  1 root root    2 May 29 12:31 c

As you can see, there are 2 zero length files and one 2 bytes long file.

Example of how it worked before fix:

[root at victim tests]# ../utils/lfs find /mnt/lustre -s 0

That is nothing found.

[root at victim tests]# ../utils/lfs find /mnt/lustre -s 2

Again nothing is found.

[root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 0

Search for non zero length files also gives nothing.

[root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 1
/mnt/lustre/a
/mnt/lustre/b

This finds two zero files but does not find one 2 bytes long file.

After the fix:

[root at victim tests]# ../utils/lfs find /mnt/lustre -s 0
/mnt/lustre/a
/mnt/lustre/b

[root at victim tests]# ../utils/lfs find /mnt/lustre -s 2
/mnt/lustre/c

[root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 0
/mnt/lustre
/mnt/lustre/c

[root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 1
/mnt/lustre
/mnt/lustre/a
/mnt/lustre/b
/mnt/lustre/c

[root at victim tests]# ../utils/lfs find /mnt/lustre -s +1
/mnt/lustre
/mnt/lustre/c

This found all with size 1 and more.

[root at victim tests]# ../utils/lfs find /mnt/lustre -s -1
/mnt/lustre/a
/mnt/lustre/b

This found all smaller than 1 byte long.

[root at victim tests]# ../utils/lfs find /mnt/lustre -s -0
/mnt/lustre/a
/mnt/lustre/b

This found all that 0 or smaller :)

Should I create bug in bugzilla or posting it to lustre-devel@ is ok?

Thanks.
-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100529/4eefb2e7/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lfs-find-1.8.2.patch
Type: application/octet-stream
Size: 10073 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100529/4eefb2e7/attachment.obj>
