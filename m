From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Fri, 2 Oct 2015 17:03:44 +0200
Subject: [lustre-devel] Channel Bonding Debug Information
In-Reply-To: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
References: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
Message-ID: <560E9CD0.5010407@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi

As discussed at last Developer Summit, my concern is about transparent 
interface switching, without upper layer knowing it.
I'm not talking about a lot of interface details, others already talked 
about that. I thinking about error messages and admins which are not 
Lustre experts.

This is a typically timeout error message you can get on a Lustre 
client. You can see a lustre target (here MDT0000) and a NID, especially 
an IP address.

[4863147.960698] Lustre: 
25163:0:(client.c:1939:ptlrpc_expire_one_request()) @@@ Request sent has 
timed out for slow reply: [sent 1443794470/real 1443794470]  
req at ffff880612a00c00 x1509752994606324/t0(0) 
o38->lustre-MDT0000-mdc-ffff88062dea2000 at 10.2.10.13@o2ib:12/10 lens 
400/544 e 0 to 1 dl 1443794476 ref 1 fl Rpc:XN/0/ffffffff rc 0/-1

If this error is due to LNET taking another link, either on client side 
or server side and this link is sick/flacky/buggy, ... *this should not 
be silent*! Ideally this NID should be updated in this error message to 
reflect the route change.
I do not have a strong opinion on the way this error should be reported, 
but I just wanted the case where : the network error is reported only in 
debug message and this error message is displayed as-is, without any 
idea that LNET did some magic stuff that failed.



Aur?lien

Le 28/09/2015 21:30, Amir Shehata a ?crit :
> Hello,
>
> As a followup on the discussion in the LAD developer summit, regarding 
> ensuring that there is enough debug information provided as part of 
> the Channel Bonding solution, I'm sending this email to ask for ideas 
> on what type of debug information you would like to see.
>
> thanks
> amir
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151002/4f6a5726/attachment.htm>
