From: Paul Nowoczynski <pauln@psc.edu>
Date: Wed, 20 Oct 2010 10:51:06 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <00d001cb705a$fd64cb80$f82e6280$@com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>	<4CBEA415.80307@gmail.com>	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>	<4CBEA8A9.9080802@gmail.com>
	<00d001cb705a$fd64cb80$f82e6280$@com>
Message-ID: <4CBF01DA.3090505@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> I do like the idea of a collective open, but I'm wondering if it can be
> implemented simply enough to be worth the effort.  True, it avoids the O(n)
> load on the server of all the clients (re)populating their namespace
> caches, but it's only useful for parallel jobs - a scale-out NAS style
> workload can't benefit.  Ultimately the O(n) will have to be replaced with
> something that scales O(log n) (e.g. with a fat tree of caching proxy
> servers).
Eric makes a good point in that only parallel jobs really need this 
feature. Unfortunately, at scale the system (both clients and servers) 
*really do* need something like this, especially if we continue pushing 
users to perform N-1 file I/O instead of 'file per process'. I too am in 
agreement that some sort of capability mechanism is the best approach. I 
wonder if this is something that could be done outside of POSIX and 
supported through a parallel I/O library? Perhaps a single application 
threads could make a special open call (/proc magic perhaps?) and obtain 
the glob of opaque bytes which are then broadcast to the rest of the 
client via mpi. Traversing the namespace would be avoided on all but one 
client. In such a scenario I don't feel that enforcing unix permissions 
at every level of the path is needed or sensible, the operation should 
be treated as a simple logical open. The question to the lustre experts 
- can enough state be packed into an opaque object such that the 
recv'ing client can construct the necessary cache state?

>
>> On 10/20/10 12:24 PM, Andreas Dilger wrote:
>>> I'm reluctant to expose the whole FID namespace to applications, 
>
> ??? It can just be opaque bytes to the app.
>
>>> since this completely bypasses all directory permissions and allows
>>> opening files only based on their inode permissions.  If we require a
>>> name_to_handle() syscall to succeed first, before allowing
>>> open_by_handle() to work, then at least we know that one of the
>>> involved processes was able to do a full path traversal.
>
> I think this defeats the scalability objective - we trying to avoid having
> to pull the namespace into every client aren't we?
>
>> yes, this is a good point. can be solved if you use FID +
>> capability/signature ?
>
> Yes, I think capabilities are the only way collective open can be made
> secure "properly".  And given the way we believe capabilities have to be
> implemented for scalability (i.e. to keep the capability cache down to a
> reasonable size on the server) any open by one node in a given client
> cluster may well have to confer the right to use the FID by any of its
> peers.
>
>>>> another idea was to do whole path traversal on MDS within a single
>>>> RPC.  bug that'd require amount of changes to llite and/or VFS and
>>>> keep MDS a bottleneck.
>
> That's an optimization rather than a scalability feature.  How much does
> it complicate the code?  I'd hate to see something new tricky and fragile
> complicate further development.
>
>           Cheers,
>                    Eric
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
