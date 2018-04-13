From: Ben Evans <bevans@cray.com>
Date: Fri, 13 Apr 2018 14:01:15 +0000
Subject: [lustre-devel] LNET Configuration Update/Reconciliation
Message-ID: <D6F62FA9.F7D1%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In LU-4939, I'm working on exporting and importing the parameters set via lctl conf_param and set_param -P.  The output is in yaml, and I've got an importer working in a separate patch that has yet to be accepted upstream.

Would you consider having an exporter for the lnetctl and modprobe.conf settings into yaml so that you could migrate between the two methods of setting configuration?

From: lustre-devel <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>> on behalf of "Di Natale, Giuseppe" <dinatale2 at llnl.gov<mailto:dinatale2@llnl.gov>>
Date: Thursday, April 12, 2018 at 3:53 PM
To: "lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>" <lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Subject: [lustre-devel] LNET Configuration Update/Reconciliation


Greetings Developers,


We are currently using modprobe.conf to configure routes, but we are hoping to reach a point where we can push out new LNET configurations to nodes and have lnetctl apply configuration changes on the fly.


It would be nice to have the ability to update or "reconcile" the difference between the loaded configuration and an updated configuration being imported. I was exploring how to implement such functionality in lnetctl. Would others find such functionality useful?


My current thought is that I'd implement this as a new lnetctl subcommand (i.e. "update"). Does that seem reasonable or would you suggest another interface?


Thanks,

Giuseppe
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180413/2299f0a2/attachment.html>
