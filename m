From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 20 Oct 2010 12:01:00 -0600
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF297B.9070103@gmail.com>
References: <4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<4CBF01DA.3090505@psc.edu> <4CBF094A.9020302@gmail.com>
	<4CBF1C42.1090109@psc.edu> <4CBF1D82.60508@gmail.com>
	<4CBF22DE.9080204@psc.edu> <4CBF2483.7030805@gmail.com>
	<20101020172956.GV1635@oracle.com> <4CBF297B.9070103@gmail.com>
Message-ID: <51FFCB06-9335-42E4-8EDD-E2CA128F3CB7@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-20, at 11:40, bzzz.tomas at gmail.com wrote:
> On 10/20/10 9:29 PM, Nicolas Williams wrote:
>> MDSes are typically CPU bound, so that's likely the issue.  The problem
>> though is that the MDS does need to track open file state for SOM and
>> for dealing with unlinks.  The semantics of open-by-handle might be such
>> that unlinks of files opened by handle can cause the file to disappear
>> and syscalls on FDs opened by handle could then return EBADF or EIO or
>> some new error code.  But open-by-handle semantics don't allow for that,
>> then the MDS needs to track open file state, and it's hard to see how to
>> avoid RPCs to the MDS to establish that state (the original client could
>> tell the MDS about all the clients that will open-by-handle, but this
>> seems unlikely to perform so much better than N smaller RPCs as to
>> justify it, and the open-by-handle API suddenly gets much more complex).
> 
> I guess for this purpose they may just disable SOM and do few steps away
> from POSIX. probably inter-client data consistency isn't that important
> any more ;) then get rid of MDS and namespace completely using some sort
> of FID.

I don't think that most customers want to drop POSIX and namespaces completely, because of the huge numbers of tools/apps that depend on this, but rather to have an API that can improve the performance of select applications that have a need for it.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
