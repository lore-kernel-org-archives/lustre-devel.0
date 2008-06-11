From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 11 Jun 2008 18:35:19 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <200806111821.27616.alexander.zarochentsev@sun.com>
References: <C4620704.5499%peter.braam@sun.com>
	<200806111821.27616.alexander.zarochentsev@sun.com>
Message-ID: <484FE2A7.9010004@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alexander Zarochentsev wrote:
>> * 3.6 provide a detailed explanation please
>> * GC thread is wrong mechanism this is what we have commit callbacks
>> for * Why not use the DLM, then we can simply keep the client waiting
>> ? the mechanism already exists for repack;
> 
> CoS is just an improved version of rep-ack, using persistent storage 
> instead of client replay queue?

AFAIU, there is another difference - rep-ack doesn't need to care about
"same client" optimization as usually ACK is received before next request
(or at least very soon after). so, cost of ACK for single client is very
small. in contrast the cost of sync is very high, thus we want this "same
client" optimization which can't be implemented without some changes to
LDLM, I think.

thanks, Alex
