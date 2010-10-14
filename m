From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 14 Oct 2010 08:46:24 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <20101014051852.GZ1635@oracle.com>
References: <AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
	<20101014002844.GY1635@oracle.com>
	<FC5171E3-DC54-4FC2-B723-7787BE41BD80@clusterstor.com>
	<20101014051852.GZ1635@oracle.com>
Message-ID: <D879E022-A163-4BC8-B1A5-DFAEBCA0016D@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 14, 2010, at 08:18, Nicolas Williams wrote:

> On Thu, Oct 14, 2010 at 06:38:16AM +0300, Alexey Lyashkov wrote:
>> On Oct 14, 2010, at 03:28, Nicolas Williams wrote:
>>> Yes, it's possible to add buffers to requests.  It's not possible to add
>>> buffers to _replies_ to existing RPCs unless you know the client expects
>>> those additional buffers -- existing clients expect a given maxsize for
>>> each reply, and if your reply is bigger then it will get dropped.
>> It is wrong for last ~1year.
>> ~1year ago i add code to ptlrpc layer which a adjust buffer for reply, and resend a request.
> 
> Ah, I didn't know that was in 1.8.
that is added near of 1.8.1 and easy to check by grep -rn rq_reply_truncate in ptlrpc directory.

Severity   : normal
Bugzilla   : 19526
Description: can't stat file in some situation.
Details    : improve initialize osc date when target is added to mds and
             ability to resend too big getattr request is client isn't have info
             about ost.


>  Are there interop issues (with older
> clients) though with sending larger replies than expected?
I not clearly understand that question, but 

main propose of that change - problem with LOV EA buffer size for files with ACL (look to some conf-sanity tests).
In some situation - MDS can have larger LOV EA buffer, when client expected 
(some files with wide striping have a reference to OST which removed from a cluster, or configuration lost, or new OST added but OST isn't connected to client or bad call shrink reply buffer, or other ... - you can find more references in bugzilla.)
in that case MDS have send larger buffer to client.
older client have infinity loop on connect  or in stat syscall (because of messages without rq_no_resend flag)
new client have a resend message - and adjust maximal size of LOV EA after got a valid reply, to avoid that's problem in future.



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
