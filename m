From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 14 Oct 2010 06:38:16 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <20101014002844.GY1635@oracle.com>
References: <AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
	<20101014002844.GY1635@oracle.com>
Message-ID: <FC5171E3-DC54-4FC2-B723-7787BE41BD80@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 14, 2010, at 03:28, Nicolas Williams wrote:

> On Wed, Oct 13, 2010 at 07:51:37PM -0400, Vilobh Meshram wrote:
>> 1) Is it possible that without writing a new RPC in Lustre 1.8.1.1 I can
>> append some string such as "Hello" to the exsisting message sent by the
>> Client (with the buffer size set at client side by the count,size fields).I
>> tried modifying the "size" of the request for one of the RPC in-built in
>> Lustre
> 
> Yes, it's possible to add buffers to requests.  It's not possible to add
> buffers to _replies_ to existing RPCs unless you know the client expects
> those additional buffers -- existing clients expect a given maxsize for
> each reply, and if your reply is bigger then it will get dropped.
It is wrong for last ~1year.
~1year ago i add code to ptlrpc layer which a adjust buffer for reply, and resend a request.

        if (ev->mlength < ev->rlength ) {
                CDEBUG(D_RPCTRACE, "truncate req %p rpc %d - %d+%d\n", req,
                       req->rq_replen, ev->rlength, ev->offset);
                req->rq_reply_truncate = 1;
                req->rq_replied = 1;
                req->rq_status = -EOVERFLOW;
                req->rq_nob_received = ev->rlength + ev->offset;

...

        if (req->rq_reply_truncate) {
                if (ptlrpc_no_resend(req)) {
                        DEBUG_REQ(D_ERROR, req, "reply buffer overflow,"
                                  " expected: %d, actual size: %d",
                                  req->rq_nob_received, req->rq_repbuf_len);
                        RETURN(-EOVERFLOW);
                }

                sptlrpc_cli_free_repbuf(req);
                /* Pass the required reply buffer size (include
                 * space for early reply).
                 * NB: no need to roundup because alloc_repbuf
                 * will roundup it */
                req->rq_replen       = req->rq_nob_received;
                req->rq_nob_received = 0;
                req->rq_resend       = 1;
                RETURN(0);
        }


--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
