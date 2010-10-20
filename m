From: bzzz.tomas at gmail.com <bzzz.tomas@gmail.com>
Date: Wed, 20 Oct 2010 20:49:06 +0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF1C42.1090109@psc.edu>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com>
	<00d001cb705a$fd64cb80$f82e6280$@com> <4CBF01DA.3090505@psc.edu>
	<4CBF094A.9020302@gmail.com> <4CBF1C42.1090109@psc.edu>
Message-ID: <4CBF1D82.60508@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/20/10 8:43 PM, Paul Nowoczynski wrote:
> It's for scalability reasons. When N clients traverse the namespace with
> the purpose of opening the same file the result is a storm of RPC
> requests which bear down on the metadata server. This type of activity
> becomes prohibitive especially when you start considering client counts
>  > 10^4. An operation such as this is ripe for optimization because
> every client in the network is trying to build the same state. If you
> have a method for a single client to 'learn' the final state, i.e. the
> pathname -> fid translation, and broadcast it to its cohorts, it's a
> huge win because it eliminates an O(N) operation.
> paul

clear enough, but what is the bottleneck here: MDS to handle lots of
RPCs or network to pass RPCs ?

thanks, z
