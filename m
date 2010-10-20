From: Paul Nowoczynski <pauln@psc.edu>
Date: Wed, 20 Oct 2010 13:25:15 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF2483.7030805@gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>	<4CBEA415.80307@gmail.com>	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>	<4CBEA8A9.9080802@gmail.com>	<00d001cb705a$fd64cb80$f82e6280$@com>
	<4CBF01DA.3090505@psc.edu>	<4CBF094A.9020302@gmail.com>
	<4CBF1C42.1090109@psc.edu>	<4CBF1D82.60508@gmail.com>
	<4CBF22DE.9080204@psc.edu> <4CBF2483.7030805@gmail.com>
Message-ID: <4CBF25FB.5030708@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

have a look at this, it explains the type of problem networks have in 
dealing with these communication patterns. 
http://www.pdl.cmu.edu/Incast/

and yes, a proxy is a workable solution, and probably the most well 
rounded.  The disadvantages  is that it would presumably require more 
engineering to deploy.
p



bzzz.tomas at gmail.com wrote:
> On 10/20/10 9:11 PM, Paul Nowoczynski wrote:
>   
>> I could be wrong but my guess is that the network congestion caused by
>> this communication pattern is a more serious problem. The mds should be
>> able to easily service lookup rpc's since only the first few necessitate
>> a read I/O from the disk.
>>     
>
> but then the network should be able to deal with storm of
> <max RPC in-flight> * <# clients> to read/write data?
>
> or it's a specific switch being the bottleneck to specific node?
>
> because if it isn't network, but MDS being a real bottleneck,
> then proxy might be a solution like Eric said above. not sure
> is this important in your case, but this would allow to use
> existing apps.
>
> of course, distribution tree for a handle may scale better.
>
> thanks, z
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
