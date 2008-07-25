From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 25 Jul 2008 08:41:30 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <488957EC.1040701@sun.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
Message-ID: <4889597A.6060109@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yong Fan wrote:
> Lockless getattr RPC for "ls -l" is a good idea. But whether all the 
> getattr RPC will be lockless or not?
> If not, how to distinguish them from "stat(2)" case? by intent or 
> something else?
> Statahead is based on forecast, it maybe wrong. We should guarantee the 
> proper lock(s) is held even
> if the statahead is wrong.

no, I don't think we need lock always: you just did getattr and fill inode
with fresh attributes, then you release lock, somebody changes attributes
on the server and only then userspace application gets attributes (already
non-fresh). so, what lock gives you in this case?

> Another optimization (maybe) to be considered is that whether it is 
> necessary to start one statahead thread
> for each "ls -l" operation or not? As said by Nikita, maybe we can use a 
> single thread for all the statahead.

I'm not sure we need any statahead thread at all. what's wrong with issuing
number of async RPCs from ll_getattr_it()? this way user's application drives
statahead directly: each time stat(2) is called you tune statahead window and
send few more RPCs again -- like data read-ahead does.

thanks, Alex
