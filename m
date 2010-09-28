From: Seger, Mark <mark.seger@hp.com>
Date: Tue, 28 Sep 2010 14:48:46 +0000
Subject: [Lustre-devel] How to tell when lustre is installed
Message-ID: <9FCE3A46FE7C8045A6207AE4B42E9F9A4EACDA280E@GVW1119EXC.americas.hpqcorp.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As many of you may know, collectl has been providing high-quality lustre performance stats from essentially day 1 of lustre and a large following of users find it to be a valuable tool.  I just learned that version 1.8.4 breaks collectl but I'm also sure it's a pretty minor problem to fix, but I'm not sure the best way is so I thought I'd ask the experts.

When collectl starts up, the default is to collect lustre stats and so it needs to know whether or not lustre is installed and if not, disable the collection of those stats.  This is further complicated because while lustre may be installed, it may not yet have been enabled or filesystems mounted on clients.  collectl IS smart enough to detect lustre starting up and immediately start monitoring so it's important to know if it's installed.

Currently, collectl can tell is lustre has been installed by just checking for the presence of /lib/modules/*/kernel/net/lustre.  This test is only performed when collectl first starts up.  Can someone tell me if there is a similar check I can do that will work for clients/servers on all Linux distros?  I'll keep the current test which is known to work on previous lustre versions and simply look somewhere else if this test fails.  I also know a lot more will be changed with lustre 2.0 so am only concerned with 1.8 at this time.

-mark

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100928/002ff8fd/attachment.htm>
