From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Mon, 16 Apr 2018 20:52:37 +0000
Subject: [lustre-devel] LNET Configuration Update/Reconciliation
In-Reply-To: <D6F62FA9.F7D1%jevans@cray.com>
References: <D6F62FA9.F7D1%jevans@cray.com>
Message-ID: <DM5PR09MB144900D1B60C2826F06EDA9984B00@DM5PR09MB1449.namprd09.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In theory, lnetctl itself is the exporter. Once modprobe.conf settings are loaded, lnetctl export will get you most of the way there (default values for tunables and such are exported as well). If you're already using lnetctl, it can export the current configuration (again, including tunables, etc).


As for migrating from lnetctl back to modprobe.conf, I wasn't planning on tackling that.


What I am trying to implement is a method of "reconciling" the current configuration with a newly imported one. So to start, let us assume lnet has some configuration x. Let's say you make changes to the YAML file (add a few new routes, remove a network, maybe remove a route) producing configuration y. I want to implement a feature in lnetctl that will take the currently loaded configuration (in this case, configuration x) and turn it into configuration y without taking down connections unless it's necessary.

Giuseppe
________________________________
From: Ben Evans <bevans@cray.com>
Sent: Friday, April 13, 2018 7:01:15 AM
To: Di Natale, Giuseppe; lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] LNET Configuration Update/Reconciliation

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180416/4bf11282/attachment.html>
