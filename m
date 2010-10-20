From: bzzz.tomas at gmail.com <bzzz.tomas@gmail.com>
Date: Wed, 20 Oct 2010 17:40:32 +0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <00d001cb705a$fd64cb80$f82e6280$@com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
Message-ID: <4CBEF150.9000007@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/20/10 5:30 PM, Eric Barton wrote:
> I do like the idea of a collective open, but I'm wondering if it can be
> implemented simply enough to be worth the effort.  True, it avoids the O(n)
> load on the server of all the clients (re)populating their namespace
> caches, but it's only useful for parallel jobs - a scale-out NAS style
> workload can't benefit.  Ultimately the O(n) will have to be replaced with
> something that scales O(log n) (e.g. with a fat tree of caching proxy
> servers).

in long-term I'd prefer proxy approach because this way we could improve
number of cases, including existing POSIX apps doing open, stat, etc.

>>>> another idea was to do whole path traversal on MDS within a single
>>>> RPC.  bug that'd require amount of changes to llite and/or VFS and
>>>> keep MDS a bottleneck.
>
> That's an optimization rather than a scalability feature.  How much does
> it complicate the code?  I'd hate to see something new tricky and fragile
> complicate further development.

yes, this is an optimization. good thing here is that single client can
benefit a lot from this (replacing few RPCs with a single one). bad
thing is that it can be quite quite complicated on the client side (the
server side's part looks OK).

thanks, z
