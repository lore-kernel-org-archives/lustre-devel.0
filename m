From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 13 Oct 2010 02:43:46 -0500
Subject: [Lustre-devel] Query to understand the Lustre request/reply
 message
In-Reply-To: <49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
References: <5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
Message-ID: <20101013074345.GH1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 13, 2010 at 10:27:55AM +0300, Alexey Lyashkov wrote:
> eh.. Nicolas,
> 
> Format for messages which want to reconstructed after resend and don't
> want recontructed - is different.
> 
> As quick example it is OPEN request (via MDS_REINT command), that type
> message need a have extra buffer to store LOV EA, which to be send to
> MDS in replay case (with additional flag in header).  (client have a
> copy data from a mds reply after ptlrpc finish processing request).
> That is why i say about "Reconstruct/replay case"

Sure, but this buffer needs to be declared a priori.  If you won't know
whether you'll need a buffer until later, that's OK: you declare it
anyways and you set its size to zero if you don't need it.

You can't change a capsule's format to add buffers; you can only set the
size of unnecessary buffers to zero.  This is because the header of a
ptlrpc (not the ptlrpc_body, mind you) has a count of buffers then a
variable length (64-bit aligned) set of that many 32-bit buffer lengths
(I'm going from memory here), and adding buffers can put a reply over
the expected max size on the client side, leading to it being dropped.

You can change a capsule's format to change the definition of a field
from one without a swabber to one with a swabber.

You'll see in many cases that the presence of a field (meaning, whether
it's checked for or whether it has a non-zero size) is dependent on a
flag in the mdt or ost body, as you mention.  Replays are not the only
interesting case here.  Capabilities are another.

Some of these flags could be removed and replaced instead with checks of
buffer size (0 -> flag not set, >0 -> flag set).

> Also format is different is you want to use MDS_REINT + sub commands
> or you want to use something similar to MDS_SET_INFO.  For
> MDS_SET_INFO you use single format for all messages (just simple key
> <> value) buffer, but for MDS_REINT you need two formats - one for
> generic MDS_REINT code (get opcode from command, get locks, and
> possible other) and own format for each opcode  - such as open,
> unlink, setxattr, setattr.  all of them have a different number of
> buffers (fields).

The SET_INFO RPCs are kinda gross.  I should know, since I finished the
conversion of ost_handler.c to the new API.  You can see that I used
req_capsule_extend() to handle some SET_INFO cases.  No, I didn't cover
this detail, nor others, because I figured Vilobh needed a starting
point, and that's all I was going to provide tonight.

Nico
-- 
