From: Paul Nowoczynski <pauln@psc.edu>
Date: Wed, 20 Oct 2010 11:16:59 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <20101020145556.GR1635@oracle.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<4CBF01DA.3090505@psc.edu> <20101020145556.GR1635@oracle.com>
Message-ID: <4CBF07EB.3090001@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes! I think I was at this HEC meeting a few years ago?? :)
Here are the pointers to the manpages if anyone else is interested. 
http://www.opengroup.org/platform/hecewg/

So my question wasn't so much about the interface which is why I posed a 
scenario based on MPI.  But rather, how feasible is it to import the 
necessary state the from the client issuing openg() to the rest?
paul


Nicolas Williams wrote:
> On Wed, Oct 20, 2010 at 10:51:06AM -0400, Paul Nowoczynski wrote:
>   
>> Eric makes a good point in that only parallel jobs really need this 
>> feature. Unfortunately, at scale the system (both clients and servers) 
>> *really do* need something like this, especially if we continue pushing 
>> users to perform N-1 file I/O instead of 'file per process'. I too am in 
>> agreement that some sort of capability mechanism is the best approach. I 
>> wonder if this is something that could be done outside of POSIX and 
>> supported through a parallel I/O library? Perhaps a single application 
>> threads could make a special open call (/proc magic perhaps?) and obtain 
>> the glob of opaque bytes which are then broadcast to the rest of the 
>> client via mpi. Traversing the namespace would be avoided on all but one 
>> client. In such a scenario I don't feel that enforcing unix permissions 
>> at every level of the path is needed or sensible, the operation should 
>> be treated as a simple logical open. The question to the lustre experts 
>> - can enough state be packed into an opaque object such that the 
>> recv'ing client can construct the necessary cache state?
>>     
>
> POSIX already has what you're asking for, and it's called openg() ;)
>   
