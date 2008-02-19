From: Andreas Dilger <adilger@sun.com>
Date: Tue, 19 Feb 2008 13:19:04 -0700
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <05e801c8730c$87cbc7a0$0281a8c0@ebpc>
References: <47BAA607.1000600@sun.com> <05e801c8730c$87cbc7a0$0281a8c0@ebpc>
Message-ID: <20080219201904.GQ3029@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 19, 2008  15:31 +0000, Eric Barton wrote:
> Rather than discussing this one EA at a time, should we not
> consider any other EAs (e.g. being considered in current 
> architecture work) that might contend for space in the inode?

I wouldn't object to this.  There were several other proposals to add
EAs to the inode, but individually the overhead is high.  If we have
a single aggregated EA struct for Lustre that would be more reasonable.

> > -----Original Message-----
> > From: lustre-devel-bounces at lists.lustre.org 
> > [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
> > Alex Zhuravlev
> > Sent: 19 February 2008 9:49 AM
> > To: lustre-devel at lists.lustre.org
> > Subject: [Lustre-devel] storing SOM epoch in EA
> > 
> > Good day,
> > 
> > some time ago we discussed that it would be very helpful to
> > store epoch in inode on mds. the perfect solution could be
> > to store epoch in old inode body, but there is no much space
> > for this in the body and with DMU we'll have this problem
> > again.
> > 
> > given the minimal inode size we use on MDS is 512 bytes, we
> > can store upto 13 stripes in the body. larger EAs go to a
> > dedicated block. if we add 8 byte epoch, then we can store
> > upto 12 stripes in the body. so, epoch stored in EA affects
> > only files with exactly 13 stripes. files with different
> > stripes are unaffected at all.
> > 
> > couple lesser concerns are:
> > 1) cpu usage
> > 2) epoch on old filesystem with insufficient inode space
> > 
> > any objections to use EA to store SOM epoch?
> > 
> > thanks, Alex
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at lists.lustre.org
> > http://lists.lustre.org/mailman/listinfo/lustre-devel
> > 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
