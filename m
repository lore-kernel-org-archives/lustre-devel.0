From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Thu, 13 Aug 2015 22:43:14 +0000
Subject: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <974262C966B9F640899A48EB96313E9A2B3C90@PRDEXMBX-08.the-lab.llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings,

In an effort to change test-framework.sh to not utilize the deprecated conf_param option in lctl, I stumbled upon what appears to be inconsistent behavior between lctl's conf_param and set_param -P options. The permanent option test-framework.sh is attempting to change is jobid_var. When using conf_param, any changes to the property are written to /proc/fs/lustre/jobid_var within a short period of time. This is not the case with set_param -P. The change is never reflected nor is it stored in some other file within /proc. I started digging into the MGS logs and found that the behavior for both are different (the relevant segments of the logs are attached to this email and are named accordingly). In short, it appears that conf_param attempts to apply the changes to all the targets while set_param does not (it does not recognize it as a global property). Can someone offer any insight on why the behavior appears to be different or provide insight on if this is incorrect behavior?

Thanks,
Giuseppe Di Natale
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150813/7954dcf2/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: set_param_log
Type: application/octet-stream
Size: 3081 bytes
Desc: set_param_log
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150813/7954dcf2/attachment.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: conf_param_log
Type: application/octet-stream
Size: 4383 bytes
Desc: conf_param_log
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150813/7954dcf2/attachment-0001.obj>
