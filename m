From: bzzz.tomas at gmail.com <bzzz.tomas@gmail.com>
Date: Wed, 20 Oct 2010 22:09:51 +0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <51FFCB06-9335-42E4-8EDD-E2CA128F3CB7@oracle.com>
References: <4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com>
	<00d001cb705a$fd64cb80$f82e6280$@com> <4CBF01DA.3090505@psc.edu>
	<4CBF094A.9020302@gmail.com> <4CBF1C42.1090109@psc.edu>
	<4CBF1D82.60508@gmail.com> <4CBF22DE.9080204@psc.edu>
	<4CBF2483.7030805@gmail.com> <20101020172956.GV1635@oracle.com>
	<4CBF297B.9070103@gmail.com>
	<51FFCB06-9335-42E4-8EDD-E2CA128F3CB7@oracle.com>
Message-ID: <4CBF306F.7040308@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/20/10 10:01 PM, Andreas Dilger wrote:
>> I guess for this purpose they may just disable SOM and do few steps away
>> from POSIX. probably inter-client data consistency isn't that important
>> any more ;) then get rid of MDS and namespace completely using some sort
>> of FID.
>
> I don't think that most customers want to drop POSIX and namespaces completely, because of the huge numbers of tools/apps that depend on this, but rather to have an API that can improve the performance of select applications that have a need for it.

oh, sorry for this sort of joke.. what I mean is that
probably we could provide with another user-visible
API which allows to bypass regular namespace, for example.

thanks, z
