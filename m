From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 20 Oct 2010 11:27:25 -0600
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF2483.7030805@gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<4CBF01DA.3090505@psc.edu> <4CBF094A.9020302@gmail.com>
	<4CBF1C42.1090109@psc.edu> <4CBF1D82.60508@gmail.com>
	<4CBF22DE.9080204@psc.edu> <4CBF2483.7030805@gmail.com>
Message-ID: <65A68391-7759-403D-A059-704410FFDA03@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-20, at 11:18, bzzz.tomas at gmail.com wrote:
> On 10/20/10 9:11 PM, Paul Nowoczynski wrote:
>> I could be wrong but my guess is that the network congestion caused by
>> this communication pattern is a more serious problem. The mds should be
>> able to easily service lookup rpc's since only the first few necessitate
>> a read I/O from the disk.
> 
> but then the network should be able to deal with storm of
> <max RPC in-flight> * <# clients> to read/write data?
> 
> or it's a specific switch being the bottleneck to specific node?

I think there is definitely non-trivial overhead of the MDS threads descending into the filesystem to do path lookup and permission checking than would be avoided.

> because if it isn't network, but MDS being a real bottleneck,
> then proxy might be a solution like Eric said above. not sure
> is this important in your case, but this would allow to use
> existing apps.
> 
> of course, distribution tree for a handle may scale better.

I don't think the actual distribution of the handle is a significant factor (this can be done via efficient broadcast in MPI layer).  If we want to keep the MDS state consistent with N openers of the file then that may take more effort.  However, I also just thought of a partial solution to the MDS state issue - if the original client doing name_to_handle() also gets the MDS open lock, then it can somewhat act as "proxy" for the remaining clients that are opening via handle.

The MDS will know that the client with the MDS open lock may be doing other opens, and if the handle also contains the layout as Paul proposed, then it seems possible to get at least a reasonable representation of the file on each client w/o having an additional MDS RPC from each one.  Those clients may still have issues if contacting the MDS for that file, but maybe not.

Actually implementing this is left as an exercise for the reader...



Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
