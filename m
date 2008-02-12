From: Eric Barton <eeb@sun.com>
Date: Tue, 12 Feb 2008 19:43:44 +0000
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <20080212172321.GQ3029@webber.adilger.int>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
	<47B062BA.1070809@cea.fr> <47B0B0FF.7060805@sun.com>
	<20080212035557.GP3029@webber.adilger.int>
	<026801c86d67$01a0beb0$0281a8c0@ebpc> <47B1BA52.8040304@cea.fr>
	<20080212172321.GQ3029@webber.adilger.int>
Message-ID: <032701c86daf$94333f30$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

Is this requirement documented?  I'd appreciate any pointers... 

> -----Original Message-----
> From: Andreas.Dilger at Sun.COM [mailto:Andreas.Dilger at Sun.COM] 
> On Behalf Of Andreas Dilger
> Sent: 12 February 2008 5:23 PM
> To: Aurelien Degremont
> Cc: Eric Barton; lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] Lustre HSM HLD draft
> 
> On Feb 12, 2008  16:25 +0100, Aurelien Degremont wrote:
> > Eric Barton a ?crit :
> > > Sorry if these questions duplicates previous debate.
> > > 
> > > Have I understood correctly that the design allows 
> individual objects
> > > within a lustre file (i.e. stripes?) to be purged independently?
> > > 
> > > If so why is this needed?
> > > 
> > > I would have thought that when you purge a file, you need 
> only record
> > > the purged extent as an attribute of the whole lustre 
> file and punch
> > > its stripes to free the space.  Am I missing a use case?
> > 
> > Since the beginning CFS required this feature. It seems a 
> lab ask for 
> > it. I do not know who. Unfortunately we have no use case 
> for what they 
> > want to do with this.
> > I'm wondering if their need could not be met with other 
> features like 
> > the internal Lustre migration...
> 
> That is my understanding also - I believe one of the Labs wanted this
> (to be able to do HSM on a per-stripe basis instead of a 
> per-file basis).
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> 
