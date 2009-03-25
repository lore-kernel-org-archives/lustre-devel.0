From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 25 Mar 2009 13:59:25 -0400
Subject: [Lustre-devel] some observations about metadata writeback cache
In-Reply-To: <m3ljqtlcc2.fsf@bzzz.home.net>
References: <m37i2x3mny.fsf@bzzz.home.net>
	<3AF28E58-CF74-49C9-AED7-86BDBB5EEC65@sun.com>
	<m3prg5lerf.fsf@bzzz.home.net>
	<878C772A-9A7F-4B1B-A7FB-31815306CA42@sun.com>
	<m3ljqtlcc2.fsf@bzzz.home.net>
Message-ID: <34C324F2-81EA-46CC-83FC-86D0265E4192@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 25, 2009, at 1:52 PM, Alex Zhuravlev wrote:
> RR> Simple clients
> RR> - don't participate in global epochs
>>> hmm. if committed (in terms of transno) request can be reverted
>>> during global recovery, then even simple client has to retain
>>> request on replay list till it's stable in terms of epochs?
> OD> Supposedly, server that performed the operation on behalf of the  
> client
> OD> can do this? So the simple client semantic does not change - the  
> moment
> OD> server has some stable record about hte operation, client can  
> throw the
> OD> data away (otherwise simple clients would need to know how to
> OD> participate
> OD> in rollback/replay even when the server the operation was sent  
> to did
> OD> not
> OD> go down).
> hmm. then wouldn't be simpler to do replay before global recovery  
> and then
> do global replay from server's undo logs?

Yes, but aside from that, losing a caching client leads to global  
recovery,
but losing simple client is not, since server tracks its status.

Bye,
     Oleg
