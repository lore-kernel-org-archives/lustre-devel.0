From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 25 May 2010 14:04:41 -0600
Subject: [Lustre-devel] LNET:where in the code dose the file obeject's
	private data gets filled up.
In-Reply-To: <AANLkTikhDg6RYGCmi0jmwCNerJtc5Y_7oqxkpaq7YhFV@mail.gmail.com>
References: <AANLkTikhDg6RYGCmi0jmwCNerJtc5Y_7oqxkpaq7YhFV@mail.gmail.com>
Message-ID: <C574E2BA-6EF6-4D2B-B516-1F88F5F4DEDA@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-05-25, at 12:07, ankit sharma wrote:
> I am new to Lustre code. So i am sorry if my question is trivial or silly.
> 
> My question:
> 
> On line number 116 of the file lnet/lnet/router_proc.c
> variable ver_p is getting set from the proc file object's private data.
> 
> Can any one tell me which part of the lustre code dose this file object private data gets initialized / set .
> 
> conceptually in can imagine it should (correct me if I am worng) be set in open call of the file ( /proc/sys/lnet/routers ) 
> 
> BUT I cant locate the Lustre code that dose that(sets the private data of file object).

If this is related to porting Lustre to a newer kernel, please search bugzilla for the RHEL6 and/or SLES11 SP1 kernel patches, since it fixes up this bit of code already.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
