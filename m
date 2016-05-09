From: Levi, Jodi <jodi.levi@intel.com>
Date: Mon, 9 May 2016 16:23:52 +0000
Subject: [lustre-devel] Onyx Patching (Auto test outage) notification - May
	20th 2016
Message-ID: <D35615B7.5DAB%jodi.levi@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,
We are planning a quarterly maintenance window for our cluster that hosts our Auto test instances, Jenkins, and Gerrit. This outage is needed to complete some updates that include security related patching. Please see the planned schedule and impacts to users below.

May 20th 8am MT: Pause and drain all Onyx auto test queues (both instances) - Trevis auto test instances will continue testing
May 24th 8am MT: Patching all of Onyx (expected duration 6 hours) - No new tests will be consumed during this time, but currently running tests on Trevis will continue

NOTE: any tests that have not completed by 8am MT on Tuesday will be stopped (regardless of the remaining test time left) and we will restart them after the auto test instances are up

Notification will be sent again prior to starting maintenance and again when the maintenance is complete and all instances are back on line and testing resumes.

If you have any questions or concerns with this planned maintenance outage, please reply to Jodi Levi ? jodi.levi at intel.com<mailto:jodi.levi@intel.com>


Thank you!

Jodi Levi, PMP
Program Manager
Intel High Performance Data Division
Mobile: 303-241-1428
Email: jodi.levi at intel.com

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160509/b4dba1ce/attachment.htm>
