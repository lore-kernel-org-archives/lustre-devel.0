From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Mon, 31 Jul 2017 12:20:32 +0200
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <BN6PR1101MB2132360AE4E81FD3597240F7CBBF0@BN6PR1101MB2132.namprd11.prod.outlook.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	,<1500650130.3158.6.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1500992740.4728.5.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132DD0CCFF2F83BB3BE7F54CBB90@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1501143960.3412.3.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132BBFB8979EA3FBFA4AE2DCBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1501235847.3412.12.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132018DF6EED212C690693FCBBF0@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1501254736.3412.16.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132360AE4E81FD3597240F7CBBF0@BN6PR1101MB2132.namprd11.prod.outlook.com>
Message-ID: <1501496432.3864.1.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2017-07-28 at 16:53 +0000, Patrick Farrell wrote:
> Ah, OK.  Reading this, I understand now that your intention is to
> keep the data compressed on disk - I hadn't thought through the
> implications of that fully.  There's obviously a lot of benefit from
> that.
> 
> That said, it seems like it would be relatively straightforward to
> make a version of this that uncompressed the data on arrival at the
> server, simply unpacking that buffer before writing it to disk. 
> (Straightforward, that is, once the actual compression/decompression
> code is ready...)

Sure, this should be easily doable independent from backend, although I
don't see many use cases when the efforts would pay off. 

> 
> That obviously takes more CPU on the server side and does not reduce
> the space required, but...
> 
> If you don't mind, when you consider the performant version of the
> compression code to be ready for at least testing, I'd like to see
> the code so I can try out the on-the-wire-only compression idea.  It
> might have significant benefits for a case of interest to me, and if
> it worked well, it could (long term) probably coexist with the larger
> on-disk compression idea.  (Since who knows if we'll ever implement
> the whole thing for ldiskfs.)

Sure, the client part should be stable very soon and I will share it. 

> Thanks again for engaging with me on this.
> 
> - Patrick

Same to you.

Anna
> From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
> Sent: Friday, July 28, 2017 10:12:16 AM
> To: Patrick Farrell; Xiong, Jinshan
> Cc: Matthew Ahrens; Zhuravlev, Alexey; lustre-devel
> Subject: Re: [lustre-devel] Design proposal for client-side
> compression
>  
> 
> > Ah.  As it turns out, much more complicated than I anticipated.
> >  Thanks for explaining...
> > 
> > I have no expertise in compression algorithms, so that I will have
> to
> > just watch from the sidelines.  Good luck.
> > 
> > When you are further along, I remain interested in helping out with
> > the Lustre side of things.
> > 
> > One more question - Do you have a plan to make this work *without*
> > the ZFS integration as well, for those using ldiskfs?  That seems
> > straightforward enough - compress/decompress at send and recieve
> time
> > - even if the benefits would be smaller, but not everyone (Cray,
> > f.x.) is using ZFS, so I'm very interested in something that would
> > help ldiskfs as well.  (Which is not to say don't do the deeper
> > integration with ZFS.  Just that we'd like something available for
> > ldiskfs too.)
> 
> I fear it is also much more complicated :)
> 
> At the very beginning of the project proposal we hoped we wouldn't
> need
> to touch the server so much. It turned out wrong, moreover we have to
> modify not only the Lustre server, but also pretty much the backend
> itself. We chose ZFS since it already provides a lot of
> infrastructure
> that we would need to implement completely new in ldiskfs. Since, at
> least for me, it is a research project, ldiskfs is out of scope. Once
> we proved the concept, one could re-implement the whole compression
> stack for ldiskfs. So it is not impossible, but not our focus for
> this
> project. 
> 
> Nevertheless we tried to keep our changes as far as possible not very
> backend specific. For example we need some additional information to
> be
> stored per compressed chunk. One possibility would be to change the
> block pointer of ZFS and add those fields, but I don't think anyone
> except of us would like the BP to be modified :) So we decided to
> store
> them as a header for every chunk. For ldiskfs, since one would need
> to
> implement everything from scratch anyway, one might not need that
> header, but take the required fields into account from the beginning
> and add them to ldiskfs' "block pointer". For that reason, we wanted
> to
> leave the compressed data "headerless" on client-side, and add the
> header only on the server side if the corresponding backend requires
> it. 
> 
> Well, we did it, and it even works sometimes, but it looks horrible 
> and is really counterintuitive. We send less data from client than
> lands on the OST, recalculate offsets, since we add the header during
> receiving on server side, recalculate the sent and received sizes,
> shift buffers by offsets and so on. The only advantage of this
> approach
> is client's independence from backend. We decided the price is too
> high. So now, I will construct the chunk with the header just after
> compressing the data on client-side, get rid of all those offset
> stuff
> on the server. But ldiskfs will have to deal with that ZFS-motivated
> details. 
> 
> However, a light version of compression could work with smaller
> changes
> to ldiskfs, when we only allow a completely compressed or not
> compressed files and allow potential performance drops for broken
> read-
> ahead (due to gaps within the data). 
> 
> Hope it is somehow more clear now.
> 
> Regards,
> Anna
> 
