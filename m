From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Tue, 17 Jun 2008 10:58:27 +0400
Subject: [Lustre-devel] Version based recovery
In-Reply-To: <C4753C2F.5AA0%peter.braam@sun.com>
References: <C4753C2F.5AA0%peter.braam@sun.com>
Message-ID: <op.ucvsadneatmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello, Peter

On Wed, 11 Jun 2008 18:24:15 +0400, Peter Braam <Peter.Braam@Sun.COM>  
wrote:

> Mike -
>
> This deserves some pretty serious thinking and I should not be the only  
> one
> to discuss this with you, because it is so complex.

is it worth to add CC to lustre-recovery@ mail list? It is right about  
recovery issues.

>
> OK - so the thing to try to be very clear about is if after encountering  
> a
> gap the recovery can ever switch back to non-VBR recovery.
>
> Also, it isn't clear what happens if the servers saw a few gaps, but  
> power
> down and back up.  It is possible that even when clients reconnect, they
> don't know anymore that there were gaps, yet it can affect sequence  
> number
> recovery.

Please see attached file with investigation for this use case. I am going  
to add this in HLD after discussion. There is the problem with switching  
back to ordinary recovery from VBR if recovery was interrupted and started  
again.

>
> If all clients and servers power off you can restart normal recovery.
>
> This raises the question if there is a point in keeping sequence  
> recovery if we have version recovery,

The sequence recovery is simple and proven way to go, that is why it is  
better to use it with VBR for additional checks.
The using only VBR leads to the following problems:
1) the replays may be done out of order so version checking can fail even  
when all clients are present. E.g. client1 does changes with version 1 and  
client2 - with version 2. If client2 will join recovery before the client2  
then the version mismatch will occur. The obvious solution is to wait for  
RECOVERY_TIMOUT if version is less than needed, i.e. some another client  
will set it probably. This gives us new problem:
2) waiting for needed version to arrive leads to multithreaded recovery.  
E.g. client1 waits for version N of object K, in the same time another  
client2 needs version A of object H, therefore there can be multiple  
replays waiting for needed version of different objects and we should  
handle that somehow. During sequence recovery we wait for needed  
transaction in per-server sequence, but with VBR multiple requests can  
waits needed versions because version sequences are per-objects.

This worth to be discussed as future approach for recovery, possibly, but  
using sequence recovery is simple way to start.

> because one missing client appears to kick you
> into VBR mode forever.  If you want to retain it, you'd have to record  
> the gaps and track how they are getting filled with VBR operations and  
> may
> close.

The epoches (boot cycle counter) are used to track which clients should  
participate in recovery. Missed client will affect the recovery only once  
when it was missed. After that it will have epoch in last_rcvd client_data  
less then server last epoch and will not be included in main recovery. If  
all clients with epoch equal to server last epoch are connected then  
ordinary recovery can be used. See section 3.1 in VBR HLD for details  
about epoch management.

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vbr_transactions.pdf
Type: application/pdf
Size: 60921 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080617/46830568/attachment.pdf>
