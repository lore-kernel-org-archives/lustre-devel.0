From: Ben Evans <Ben.Evans@terascala.com>
Date: Mon, 1 Jul 2013 18:06:08 +0000
Subject: [Lustre-devel] tunefs.lustre before mount
Message-ID: <2b233240c3104f958aeaf54f425bf265@BN1PR06MB215.namprd06.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Assuming I can get access to all the "correct" parameters, would there be a reason that performing a tunefs.lustre before each mount would be harmful?  It's the most straightforward way I can think of to force Lustre to have the correct configuration (ib addresses, etc.) at all times.

I don't think it should be an issue, I was just wondering if anyone had run into problems repeatedly running tunefs.lustre (1000s of times against each target)

-Ben Evans
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20130701/e03a4092/attachment.htm>
