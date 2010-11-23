From: Peter Braam <peter_braam@xyratex.com>
Date: Tue, 23 Nov 2010 13:50:02 -0700
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
Message-ID: <4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The  proposal for acl / Group / users violates Posix, and may lead to results users don't expect.  Sgid directories and inheritance on ACLs are safer I think.

Peter

Sent from my iPad

On Nov 23, 2010, at 10:20, "Eric Barton" <eeb@whamcloud.com> wrote:

> 
> Nick Cardo at NERSC mentioned at the LUG, and again when I chatted
> with him at SC10, that setting the default stripe offset is positively
> dangerous.  I think he has a point.
> 
> Setting file layout precisely can be essential for applications that
> know precisely what they're doing and want to control how aggregate
> OST load is balanced.  But the default file layout is another matter
> entirely.  Setting the default to a fixed layout, or even just a fixed
> starting OST has got to be the most direct path to achieving OST load
> imbalance.
> 
> I believe, now that lfs setstripe uses options rather than positional
> parameters, that the risk of unintentional errors is much less.  But
> that still leaves the filesystem vulnerable to na?ve or malicious
> users.  So I propose that we should continue to check permissions
> normally when setting the default stripe _count_, but restrict the
> ability to set a specific default stripe _offset_ to the superuser.
> 
> Thoughts?
> 
> P.S. Do people also agree that setting user/group/ACL permissions on
> OST pools would be a Good Thing?
> 
>          Cheers,
>                   Eric
> 
> Eric Barton
> CTO Whamcloud, Inc.
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
> 
> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
> 
> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
> 
> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
> 
> 
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
