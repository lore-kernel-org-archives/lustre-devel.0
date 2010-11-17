From: Nic Henke <nic@cray.com>
Date: Wed, 17 Nov 2010 08:59:43 -0600
Subject: [Lustre-devel] extend lnet_notify to public LNet API
In-Reply-To: <9EC72A67-A9FB-41A8-8564-99903E08F047@clusterstor.com>
References: <4CE2AAAA.3000508@cray.com>
	<9EC72A67-A9FB-41A8-8564-99903E08F047@clusterstor.com>
Message-ID: <4CE3EDDF.2090007@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/17/2010 01:52 AM, Alexey Lyashkov wrote:
> Nic,
>
> that idea discussed some time ago (as i remember with green and maxim), but have some objection.
> Currently LNet hide from ptlrpc layer any network flaps, and LNet will resend request without notify ptlrpc about flap until ptlrpc request timeout.

I'm missing something - to my knowledge, LNet never retries messages.

> But if ptlrpc will see node down event, ptlrpc will try reconnect  - that will produce extra overhead, because need to resend too much requests from sending and delay lists instead of lots requests in network flap time.
> So, you need separate network flap from node down situation - before implementing that.
> currently node marked down if node don't respond for request in ptlrpc timeout, which include network transmit and processing times, but it different then LNet message timeout.

I think that is a valid upper layer decision to make, but separate from 
implementing the LNet callbacks on network 'flap'. I wouldn't want to 
force ptlrpc to use it.

Cheers,
Nic
