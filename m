From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Wed, 17 May 2017 13:16:34 +0200
Subject: [lustre-devel] have df report a more up-to-date view of the
 filesystem
Message-ID: <9e5f3b8d-b5f5-ce10-2b35-e6f13b7de532@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi everyone,

In LU-8940 <https://jira.hpdd.intel.com/browse/LU-8940> I describe an 
issue I am having with df in Lustre's tests. In short, df/statfs can 
report outdated information about a Lustre filesystem; given enough 
time, its output gets correct. From what I understand, statfs cannot 
report an "always up-to-date" view of the filesystem as this would cost 
too much time and resources.

I would like to know what you guys think of having Lustre's statfs 
operation report a view of the filesystem /at least as new as when the 
last sync operation completed/?

My point being that users (and tests) would be able to run df --sync to 
get up-to-date information (at the cost of a sync operation, and maybe 
some accounting for statfs).

Regards,
Quentin

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170517/bb8336a2/attachment.htm>
