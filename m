From: Patrick Farrell <paf@cray.com>
Date: Tue, 30 Aug 2016 10:16:32 -0500
Subject: [lustre-devel] lnet_upcall on LBUG & LU-8418
Message-ID: <57C5A350.30302@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Currently, on LBUG, Lustre tries to call a usermode helper at 
'/usr/lib/lustre/lnet_upcall'.  This is for some sort of binary that a 
user would like executed before the LBUG itself (by default, a panic) 
happens.  Lustre does not include an lnet_upcall script, so by default, 
the call fails.

Unfortunately, in extremely low memory situations, the attempt to make 
this call can hang, resulting in a node which is in an invalid state but 
will not actually panic.  This is quite problematic as it can, for 
example, prevent failover or dump collection (for debugging purposes), 
depending on how a system is configured.

LU-8418 <https://jira.hpdd.intel.com/browse/LU-8418> (from Alexander 
Zarochentsev) is looking to disable this by default.  As Andreas Dilger 
pointed out in the patch review 
(http://review.whamcloud.com/#/c/21440/), this would break any existing 
users who had put their script in that location.

But I suspect no one is actually using this feature.

So:
Do you use (or know of anyone using) the lnet_upcall feature to call a 
binary before LBUG?  (I'm looking for end user uses; if a developer is 
using it, I think it's reasonable to ask them to set it manually.)

- Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160830/12864eb6/attachment.htm>
