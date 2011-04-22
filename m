From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Fri, 22 Apr 2011 15:41:35 -0700
Subject: [Lustre-devel] Research on filesystem metadata operation
	distribution
In-Reply-To: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
References: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
Message-ID: <73AED5C780AE05478241DB067651A92102378482@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hmm - also 'uptime' would really be nice to have with these so we could estimate rough rates...

On Apr 21, 2011, at 11:40 AM, Andreas Dilger wrote:

> I'm trying to get some data about the relative distribution of MDS operations in the wild, and I'd be grateful if some people with production filesystems that have been running for at least a week could collect some simple stats and email them to me.  They can be collected by any regular user on the MDS node:
> 
>    lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
> 
> It would be useful to also include "lfs df" and "lfs df -i" information, as well as a brief description of what the filesystem is used for (scratch, home, project, archive, etc).
> 
> 
> 
> As a reminder, I'm also interested if some Lustre admins could run the "fsstats" tool from http://www.pdsi-scidac.org/fsstats/ and send me the output.  Sending the output to PDSI via their submission form may also produce some positive results.
> 
>    http://www.pdsi-scidac.org/fsstats/files/fsstats-1.4.5.tar.gz
> 
> 
> Thanks in advance for any data.  I've set replies to go only to lustre-devel, to avoid clogging the larger readership of lustre-discuss, but it may be useful for others to have this in a list archive and/or searchable via Google in the future so I don't necessarily want to keep it all to myself.
> 
> Cheers, Andreas
> --
> Andreas Dilger 
> Principal Engineer
> Whamcloud, Inc.
> 
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
