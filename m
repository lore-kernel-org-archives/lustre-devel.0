From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 24 Aug 2011 12:12:46 -0700
Subject: [Lustre-devel] MRP-203 obdfilter not able to serve more then 32
	requests in parallel
In-Reply-To: <73AED5C780AE05478241DB067651A9210237875E@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237875E@XYUS-EX22.xyus.xyratex.com>
Message-ID: <73AED5C780AE05478241DB067651A92102378760@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Oleg.
cc'ing lustre-devel


On Aug 24, 2011, at 11:22 AM, Oleg Drokin wrote:


	Increasing number of dirs is fine by me, but it has implications for upgrading and downgrading.
	For example I think number of dirs is really hardcoded everywhere instead of using value in server data.
	Also if you want to change the value on existing OST, we need a rehash functionality,
	and then using older releases on such filesystems would lead to corruptions which also needs to be avoided somehow.



On Aug 24, 2011, at 11:06 AM, Nathan Rutman wrote:


		currently we have to use 32 directories for object in OST. but for large scale OST it isn't enough. 
		so we need to able to extend that number to ~1024 or more.

		
		

	This was brought up at LUG (presentation attached below) and my recollection is that Oleg had some strong opinions on this -- maybe not increasing the number of dirs but certainly on any locking changes.  Oleg -- did you have any objection to increasing the number of object directories?
	
	
	130-200_Ben_Evans_LUG ... - OLCF.ORNL.GOV <http://www.olcf.ornl.gov/wp-content/events/lug2011/4-13-2011/130-200_Ben_Evans_LUG-2011_Ben_Evans_V3.pptx> 
	
	
	




______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110824/8a126482/attachment.htm>
