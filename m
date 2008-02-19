From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 12:48:55 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
Message-ID: <47BAA607.1000600@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Good day,

some time ago we discussed that it would be very helpful to
store epoch in inode on mds. the perfect solution could be
to store epoch in old inode body, but there is no much space
for this in the body and with DMU we'll have this problem
again.

given the minimal inode size we use on MDS is 512 bytes, we
can store upto 13 stripes in the body. larger EAs go to a
dedicated block. if we add 8 byte epoch, then we can store
upto 12 stripes in the body. so, epoch stored in EA affects
only files with exactly 13 stripes. files with different
stripes are unaffected at all.

couple lesser concerns are:
1) cpu usage
2) epoch on old filesystem with insufficient inode space

any objections to use EA to store SOM epoch?

thanks, Alex
