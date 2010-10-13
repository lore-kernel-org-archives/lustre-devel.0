From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 13 Oct 2010 10:27:55 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <20101013071201.GD1635@oracle.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
	<5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
Message-ID: <49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

eh.. Nicolas,

Format for messages which want to reconstructed after resend and don't want recontructed - is different.

As quick example it is OPEN request (via MDS_REINT command), 
that type message need a have extra buffer to store LOV EA, which to be send to MDS in replay case (with additional flag in header).
(client have a copy data from a mds reply after ptlrpc finish processing request).
That is why i say about "Reconstruct/replay case"

Also format is different is you want to use MDS_REINT + sub commands or you want to use something similar to MDS_SET_INFO.
For MDS_SET_INFO you use single format for all messages (just simple key <> value) buffer,
but for MDS_REINT you need two formats - one for generic MDS_REINT code (get opcode from command, get locks, and possible other)
and own format for each opcode  - such as open, unlink, setxattr, setattr.
all of them have a different number of buffers (fields).


On Oct 13, 2010, at 10:12, Nicolas Williams wrote:

> On Wed, Oct 13, 2010 at 09:25:00AM +0300, Alexey Lyashkov wrote:
>> 
>> On Oct 13, 2010, at 08:42, Nicolas Williams wrote:
>>> 
>>> 
>>> - add handlers for the new RPC to mdt_handler.c (for the MDS) or
>>>  ost_handler.c (for the OST), and so on
>>> 
>>>  The handlers are responsible for knowing which buffers contain what,
>>>  and for swabbing them.  You have to make sure that you don't swab a
>>>  buffer more than once.
>>> 
>> BTW.
>> That not enough.
>> Some of operations wants to have own recostructors for replay/resend.
> 
> I glossed over replay/resend, mostly because I know little about them,
> but also because they are completely orthogonal to the message format
> details.  If you want to add an RPC then the first step should be to get
> the RPC format designed and surrounding code up and running, then you
> can take care of replay/resend.
> 
>> Some of operations want to have a return lock - as example MDS_GETATTR
>> and MDS_REINT commands.
> 
> That too is orthogonal to the message formats.  The message format has
> to have a buffer (field) declared to carry lock (or capability, or
> whatever) bits, and some function has to be invoked to populate the
> buffer in the reply.
> 
> Nico
> -- 
