From: Peter Braam <peter_braam@xyratex.com>
Date: Wed, 24 Nov 2010 08:09:38 -0700
Subject: [Lustre-devel] OST pool administration (was RE: Stripe offset
	default)
In-Reply-To: <01b501cb8bdb$f3ff3ac0$dbfdb040$@com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
	<4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
	<01b501cb8bdb$f3ff3ac0$dbfdb040$@com>
Message-ID: <AANLkTimmfPc1FgiCGT-9QUf4uVsVz2cn9-aPAOabjfOk@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 24 November 2010 06:31, Eric Barton <eeb@whamcloud.com> wrote:

> Peter,
>
> > The  proposal for acl / Group / users violates Posix, and may lead
> > to results users don't expect.  Sgid directories and inheritance
> > on ACLs are safer I think.
>
> This should probably be in a separate thread since I was trying to make
> a case for improving the administration storage pools (the classic
> gold/silver/bronze scenarios) which is really different from the default
> file layout issue.
>
> If the default layout in a directory creates files in the "gold" OST
> pool but the user has no permissions for that pool, then returning
> EPERM on file creation would potentially be inconsistent with the
> permissions on the directory itself.  Is this what you meant by being
> inconsistent with Posix?  If so, I'm afraid I don't follow the point
> about sgid.
>
>
Group writeable directories with the sgid mode bit set, exceptionally
inherit permissions from the parent directory upon creation of new
subdirectories (assuming no explicit mode is passed).   So it automatically
descends down the tree, just like the striping attributes do.  I believe
POSIX ACLs have a similar inheritance option.

I have sympathy for the idea btw, but basic permission issues failing
because of it is something that needs some thought.



> I guess using per-pool quotas rather than permissions might be more
> natural.  I'd be interested to hear people's opinions...
>


That makes sense also, and perhaps 0 quota could be interpreted as a denial
to create also, without causing harm.

Peter


>
>          Cheers,
>                   Eric
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should
> only be used for the purpose for which it was sent by Xyratex. No further
> rights or licenses are granted to use such information. If you are not the
> intended recipient of this message, please notify the sender by return and
> delete it. You may not use, copy, disclose or rely on the information
> contained in it.
>
> Internet email is susceptible to data corruption, interception and
> unauthorised amendment for which Xyratex does not accept liability. While we
> have taken reasonable precautions to ensure that this email is free of
> viruses, Xyratex does not accept liability for the presence of any computer
> viruses in this email, nor for any losses caused as a result of viruses.
>
> Xyratex Technology Limited (03134912), Registered in England & Wales,
> Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>
> The Xyratex group of companies also includes, Xyratex Ltd, registered in
> Bermuda, Xyratex International Inc, registered in California, Xyratex
> (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd
> registered in The People's Republic of China and Xyratex Japan Limited
> registered in Japan.
> ______________________________________________________________________
>
>
>

______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101124/1932d6e4/attachment.htm>
