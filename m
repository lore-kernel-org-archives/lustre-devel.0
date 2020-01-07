From: NeilBrown <neilb@suse.de>
Date: Tue, 07 Jan 2020 15:05:47 +1100
Subject: [lustre-devel] Lustre upstreaming status.
In-Reply-To: <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87sglgg9ub.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
Message-ID: <87zhezdi78.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 07 2020, James Simmons wrote:
>
> I have been going over the patches from your backport tree to find
> missing patches and test for regressions. I think all regressions I
> saw was stomped out for everything for 2.12. I'm doing full regression
> right now. The only bug I see now is very unique to the linux client.
>
> 2020-01-06T16:24:58.006823-05:00 ninja81.ccs.ornl.gov kernel: RIP: 
> 0010:ll_dcompare+0x62/0xf0 [lustre]
> 2020-01-06T16:24:58.006880-05:00 ninja81.ccs.ornl.gov kernel: RAX: 
> 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000002
> 2020-01-06T16:24:58.006934-05:00 ninja81.ccs.ornl.gov kernel: RDX: 
> 0000000000000001 RSI: 0000000000000001 RDI: 00000000ffffffff
> 2020-01-06T16:24:58.006992-05:00 ninja81.ccs.ornl.gov kernel: Code: 85 c0 
> 89 c3 75 2d f6 05 c8 c7 c8 ff 20 74 09 f6 05 c2 c7 c8 ff
>  80 75 2b 41 f7 04 24 00 00 01 10 75 c2 49 8b 84 24 f8 00 00 00 <0f> b6 58 
> 0c 83 e3 01 eb b1 48 83 c4 08 bb 01 00 00 00 89 d8 5b 5
> d

The crashing code here is

  22:	49 8b 84 24 f8 00 00 	mov    0xf8(%r12),%rax
  29:	00 
  2a:*	0f b6 58 0c          	movzbl 0xc(%rax),%ebx		<-- trapping instruction
  2e:	83 e3 01             	and    $0x1,%ebx
  31:	eb b1                	jmp    0xffffffffffffffe4

The only place that could happen in ll_dcompare is the

        if (d_lustre_invalid(dentry))
                return 1;
call@the end.
ll_d2d(dentry) must be NULL.

in OpenSFS lustre, d_lustre_invalid() protects against that being NULL.
Linux/lustre lost that protection in

Commit 7126bc2e8d60 ("lustre: switch to use of ->d_init()")

because it really shouldn't need it.

Have you reported this to me before? It seems awfully familiar.

>
> This might be resolved with
>
> https://review.whamcloud.com/#/c/24175

That would certainly resolve this particular symptom.
I don't know if it is correct though ... maybe.

>
> I believe having it ready for LUG 2020 is a reasonable goal.

Sounds like a nice goal.


Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200107/5f656022/attachment.sig>
