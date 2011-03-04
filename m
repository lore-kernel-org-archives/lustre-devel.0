From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Fri, 4 Mar 2011 12:22:14 +0300
Subject: [Lustre-devel] lustre 1.8+ issues with automounter
In-Reply-To: <9F9F3E45-4B9C-42F4-9D7F-000C70E4BAC9@whamcloud.com>
References: <4D706F39.2070807@gmail.com>
	<9F9F3E45-4B9C-42F4-9D7F-000C70E4BAC9@whamcloud.com>
Message-ID: <E0FFA139-8E84-44CB-9564-3F7DF0491719@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 4, 2011, at 09:39, Andreas Dilger wrote:

> On 2011-03-03, at 9:48 PM, Jeremy Filizetti wrote:
>> Ever since we moved from Lustre 1.6.6 to 1.8 I've seen issues with using
>> the automounter and Lustre.  I've finally got around to looking at what
>> the issue is, but I'm not quite sure what the correct way to resolve it
>> is.  I think the issue will remain in 2.0+ but I didn't look closely at
>> the code.
> 
> Interesting.  I've known about automount problems with Lustre for some time (probably a search in the list history would find a bunch), but nobody has every dug into the root cause.  Thanks for taking the time to investigate.
> 
Looks it is result of rq_no_resend flag for glimpse request, so it will failed (instead of put to delay list) and that error returned to caller.



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com




______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
