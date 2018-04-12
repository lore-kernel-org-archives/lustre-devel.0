From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Thu, 12 Apr 2018 19:53:47 +0000
Subject: [lustre-devel] LNET Configuration Update/Reconciliation
Message-ID: <DM5PR09MB14491E33B3A3054C9EC5CF1984BC0@DM5PR09MB1449.namprd09.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings Developers,


We are currently using modprobe.conf to configure routes, but we are hoping to reach a point where we can push out new LNET configurations to nodes and have lnetctl apply configuration changes on the fly.


It would be nice to have the ability to update or "reconcile" the difference between the loaded configuration and an updated configuration being imported. I was exploring how to implement such functionality in lnetctl. Would others find such functionality useful?


My current thought is that I'd implement this as a new lnetctl subcommand (i.e. "update"). Does that seem reasonable or would you suggest another interface?


Thanks,

Giuseppe
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180412/98606c7b/attachment.html>
