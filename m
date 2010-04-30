From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Fri, 30 Apr 2010 17:14:07 -0400
Subject: [Lustre-devel] question about ldlm_server_glimpse_ast
In-Reply-To: <4BDB469E.4040005@ices.utexas.edu>
References: <w2je5fcbd181004291959wb9790719ic4dc3a2bd9b64eb@mail.gmail.com>
	<4BDAD47E.401@ices.utexas.edu>
	<B1CC7901-3220-4BD6-89EE-B37C825DCB03@oracle.com>
	<4BDB469E.4040005@ices.utexas.edu>
Message-ID: <EF06CB80-B231-4AAF-A11C-16CBF8BBF490@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 30, 2010, at 5:07 PM, John Hammond wrote:

> Are there any nonobvious ramifications of changing ldlm_timeout?  I noticed that it was set to 20 seconds (except for MDS's?) in 1.8.2. Also there is some suspect looking logic in obd_config.c and elsewhere to keep it from being set too high relative to obd_timeout:
> 
>    if (ldlm_timeout >= obd_timeout)
>        ldlm_timeout = max(obd_timeout / 3, 1U);
> 
> Does this mean that ldlm_timeout should not exceed 1/3 of obd_timeout?

ldlm_timeout should not be set too high, because if a client that holds a lock dies
this is for how long nobody will be able to get a conflicting lock.
Of course if your network might delay packets (roundtrip) for more than
ldlm_timeout, then you need to lift the limit.
1/3 is there so that if your network delay is potentially this big (and you do not
use AT), there should be enough time to do some processing still and then send a reply
to the client (obd_timeout is used for the client to determine when the reply should
come) before the client times out that request.

Also see the comment from Cory, that if you use AT it is all not controlled
by at_min setting instead and then is dynamically adjusted as the system detects your
network latency.

Bye,
    Oleg
