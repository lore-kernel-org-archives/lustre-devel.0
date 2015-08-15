From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 15 Aug 2015 00:07:22 +0000
Subject: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <D1F3DE3E.101528%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Coincidentally (or maybe that was what drove your investigations?), I'd just filed https://jira.hpdd.intel.com/browse/LU-7004 about this issue.  It looks like the "lctl set_param -P" feature needs more testing, and I've removed the deprecation warning for "lctl conf_param" for 2.8.

Cheers, Andreas
--
Andreas Dilger
Lustre Software Architect
Intel High Performance Data Division

On 2015/08/13, 4:43 PM, "lustre-devel on behalf of Di Natale, Giuseppe" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of dinatale2 at llnl.gov<mailto:dinatale2@llnl.gov>> wrote:

Greetings,

In an effort to change test-framework.sh to not utilize the deprecated conf_param option in lctl, I stumbled upon what appears to be inconsistent behavior between lctl's conf_param and set_param -P options. The permanent option test-framework.sh is attempting to change is jobid_var. When using conf_param, any changes to the property are written to /proc/fs/lustre/jobid_var within a short period of time. This is not the case with set_param -P. The change is never reflected nor is it stored in some other file within /proc. I started digging into the MGS logs and found that the behavior for both are different (the relevant segments of the logs are attached to this email and are named accordingly). In short, it appears that conf_param attempts to apply the changes to all the targets while set_param does not (it does not recognize it as a global property). Can someone offer any insight on why the behavior appears to be different or provide insight on if this is incorrect behavior?

Thanks,
Giuseppe Di Natale
