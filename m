From: kelly.zhang at emc.com <kelly.zhang@emc.com>
Date: Fri, 23 Mar 2012 08:55:06 -0400
Subject: [Lustre-devel] [wc-discuss] Some questions about Lustre test
	configuration
In-Reply-To: <165941E6-9AA2-490C-B5F1-04F75A8BE680@whamcloud.com>
References: <F62E2618FCA29E42AB21F281C9511BB41377A43919@MX26A.corp.emc.com>
	<165941E6-9AA2-490C-B5F1-04F75A8BE680@whamcloud.com>
Message-ID: <F62E2618FCA29E42AB21F281C9511BB41377A43A38@MX26A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Got it. Thank you so much, Robert.

Best Regards,
Kelly Zhang(EMC)

From: Robert Read [mailto:rread at whamcloud.com]
Sent: 2012?3?23? 1:28
To: Zhang, Kelly
Cc: wc-discuss at whamcloud.com; lustre-devel at lists.lustre.org; Tang, Haiying; Liu, Xuezhao; Peng, Tao
Subject: Re: [wc-discuss] Some questions about Lustre test configuration

Hi,


On Mar 22, 2012, at 1:08 , <kelly.zhang at emc.com<mailto:kelly.zhang@emc.com>> <kelly.zhang at emc.com<mailto:kelly.zhang@emc.com>> wrote:


Hi all,

I have some questions about Lustre test configuration, would somebody help on this?  Thanks a lot.

1.       Seen from the test sets of Maloo, typically four nodes are used: ?Client1, Client2, MDS1, OSS(includes 7 OSTs)?.
So in a normal regression testing, we can also follow this, right?
When four nodes are used, what value do you set for the following two variables in file cfg/local.sh:
mdsfailover_HOST  and ostfailover_HOST

In the this configuration, I believe the failover hosts should be set to nonfailover hosts:

mdsfailover_HOST=${mds_HOST}
ostfailover_HOST=${ost_HOST}

This will allow the recovery tests to do simulated failover by ummounting and and mounting the targets on the same node to trigger Lustre recovery.



2.       I see that in the PDF ?Lustre 2.2 Test Plan?, these are some links introducing about the test configuration. Like the following one:

Regression Testing
Use auster to run automated regression tests with the following configurations.
http://wiki.whamcloud.com/display/ENG/Auster .




                But we failed to access this kind of link.  Is this URL public to users outside Whamcloud?


It wasn't  (oops), but I just  moved it so it it is now accessible to everyone here:

http://wiki.whamcloud.com/display/PUB/Auster


cheers,
robert



Thanks & Best Regards,
Kelly Zhang(EMC)


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120323/09515863/attachment.htm>
