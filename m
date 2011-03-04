From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Date: Fri, 4 Mar 2011 08:47:59 +0300
Subject: [Lustre-devel] lustre 1.8+ issues with automounter
In-Reply-To: <4D706F39.2070807@gmail.com>
References: <4D706F39.2070807@gmail.com>
Message-ID: <FD878C30-2103-400A-A02D-C3745DBEBF1F@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 4, 2011, at 07:48, Jeremy Filizetti wrote:

> Ever since we moved from Lustre 1.6.6 to 1.8 I've seen issues with using
> the automounter and Lustre.  I've finally got around to looking at what
> the issue is, but I'm not quite sure what the correct way to resolve it
> is.  I think the issue will remain in 2.0+ but I didn't look closely at
> the code.  The issue is that lov_connect which calls lov_connect_obd is
> an asynchronous connect that does not wait for all OSCs to be connected
> before returning.  In the end lustre_fill_super can return before all
> OSCs have been set active so any file operations that caused the
> automount may return an error.  Many lov functions check to make sure
> the lov_tgt_desc ltd_active flag is 1 or return -EIO. 
> 
> 
you patch is wrong in case some OSC targets will be inaccessible (in maintenance, or network troubles).
In that case lov_connect will stick in waiting for infinity time, but that is don't expected behavior. 
Can you provide more details about what is situation confuses automount ?
or try to move
>>
        err = obd_statfs(obd, &osfs, cfs_time_current_64() - HZ, 0);                                                                  
        if (err)                                                                                                                      
                GOTO(out_mdc, err);                                                                                                   
>>
from current location to something after get root fid.

if FS mounted without lazystatfs option, obd_statfs will blocked until all connection requests is finished.
so you will have same behavior but without changes in obd_connect() code.



--------------------------------------------
Alexey Lyashkov
alexey_lyashkov at xyratex.com




______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
