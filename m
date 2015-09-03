From: Ben Evans <bevans@cray.com>
Date: Thu, 3 Sep 2015 13:58:15 +0000
Subject: [lustre-devel] LU-6402 MODULE_AUTHOR changes
Message-ID: <D20DBB55.B1C%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

My personal preference would be for OpenSFS to be listed, since Lustre development is a community effort, rather than a product of any specific company.

For example, I?d have no problem with Intel?s name on their next-gen interconnect lnd code, or with Cray?s name on the GNI code, etc.  but the core parts of Lustre should belong to OpenSFS or EOFS.

-Ben Evans

From: lustre-devel <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>> on behalf of "Simmons, James A." <simmonsja at ornl.gov<mailto:simmonsja@ornl.gov>>
Date: Wednesday, September 2, 2015 at 5:29 PM
To: "lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>" <lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Subject: [lustre-devel] LU-6402 MODULE_AUTHOR changes

For the LU-6402 the modinfo is pretty stale so I send up a patch at http://review.whamcloud.com/#/c/16132. Andreas brought the topic of who
should the MODULE_AUTHOR be. Currently it is Sun Inc which is not the case. I changed it to Intel but not might not be the right choice anymore.
So what should the MODULE_AUTHOR be?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150903/fa4e0bad/attachment.htm>
