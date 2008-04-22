From: Eric Barton <eeb@sun.com>
Date: Tue, 22 Apr 2008 14:06:10 +0100
Subject: [Lustre-devel] New Pools DLD
In-Reply-To: <20080419002217.GC2775@webber.adilger.int>
References: <20080225100425.GC3108@webber.adilger.int>
	<18373.20125.724151.421930@gargle.gargle.HOWL>
	<20080419002217.GC2775@webber.adilger.int>
Message-ID: <019701c8a479$a2e42d40$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Comment in-line below...

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org 
> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
> Andreas Dilger
> Sent: 19 April 2008 1:22 AM
> To: Lustre Development Mailing List
> Cc: Mike Pershin; Nikita Danilov; Yuriy Umanets
> Subject: Re: [Lustre-devel] New Pools DLD
> 
> On Feb 27, 2008  14:50 +0300, Nikita Danilov wrote:
> > Andreas Dilger writes:
> > > are you aware of any desirable LOV EA changes that would be good
> > > to include with the changes for the v3 "pool" EA (attached)?
> > > Are there any changes that are desirable for e.g. FIDs or
> > > similar?
> > 
> > I think that if we are introducing incompatible LOV EA format, we
> > can as well go forward with changes hinted to at
> > 
> > 
> http://arch.lustre.org/index.php?title=MDS_striping_format#Future_developments
> 
> Nikita, sorry to take a long time to get back to this issue, but I
> think it is quite valuable to pursue if we are already going to
> change the on-disk format.
> 
> Since we are already need to change the LOV_MAGIC value, we may as
> well do as you suggest and have 0x0BD3ssss instead of 0x0BD30BD0,
> where ssss = size of EA in bytes.

That seems a hack - why overload magic like this rather than have a
separate field?

> That would limit us to a 65536-byte striping EA, but it still larger
> than what is supported today, and the plans for wide striping also
> do not call for larger EAs.  Even supporting 64kB EAs would be an
> issue with the current nifrastructure because the client always has
> to preallocate a receive buffer large enough for the largest EA
> because it does not know the EA size in advance.
> 
> The question is whether you think we should also add a magic + size
> to the lov_ost_data_v1 structure, which is currently the same for
> all EA types.  Adding a per-stripe magic + size would reduce the
> number of stripes we can allocate per file, and the 160-stripe limit
> is already a problem for some systems with more than 160 OSTs.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
