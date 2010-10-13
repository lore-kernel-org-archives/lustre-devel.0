From: Brian J. Murrell <brian.murrell@oracle.com>
Date: Wed, 13 Oct 2010 14:39:21 -0400
Subject: [Lustre-devel] How was lustre-1.8.4.tar.gz created?
In-Reply-To: <4CAFC255.8090906@gmail.com>
References: <4CAFC255.8090906@gmail.com>
Message-ID: <1286995161.13574.1.camel@pc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2010-10-08 at 18:16 -0700, Jay Lan wrote:
> So, how was lustre-1.8.4.tar.gz generated?

[ assuming you have a git clone of prime ]
$ git checkout 1.8.4
$ autogen.sh
$ ./configure -disable-modules --disable-utils --disable-liblustre --disable-tests --disable-doc
$ make dist

That's it.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 198 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101013/7f59dfc6/attachment.pgp>
