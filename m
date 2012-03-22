From: Robert Read <rread@whamcloud.com>
Date: Thu, 22 Mar 2012 10:28:11 -0700
Subject: [Lustre-devel] [wc-discuss] Some questions about Lustre test
	configuration
In-Reply-To: <F62E2618FCA29E42AB21F281C9511BB41377A43919@MX26A.corp.emc.com>
References: <F62E2618FCA29E42AB21F281C9511BB41377A43919@MX26A.corp.emc.com>
Message-ID: <165941E6-9AA2-490C-B5F1-04F75A8BE680@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,


On Mar 22, 2012, at 1:08 , <kelly.zhang@emc.com> <kelly.zhang@emc.com> wrote:

> Hi all,
>  
> I have some questions about Lustre test configuration, would somebody help on this?  Thanks a lot.
>  
> 1.       Seen from the test sets of Maloo, typically four nodes are used: ?Client1, Client2, MDS1, OSS(includes 7 OSTs)?.
> So in a normal regression testing, we can also follow this, right?
> When four nodes are used, what value do you set for the following two variables in file cfg/local.sh:
> mdsfailover_HOST  and ostfailover_HOST

In the this configuration, I believe the failover hosts should be set to nonfailover hosts:

mdsfailover_HOST=${mds_HOST}
ostfailover_HOST=${ost_HOST}

This will allow the recovery tests to do simulated failover by ummounting and and mounting the targets on the same node to trigger Lustre recovery.

>  
> 2.       I see that in the PDF ?Lustre 2.2 Test Plan?, these are some links introducing about the test configuration. Like the following one:
>  
> Regression Testing
> Use auster to run automated regression tests with the following configurations.
> http://wiki.whamcloud.com/display/ENG/Auster .


>  
>                 But we failed to access this kind of link.  Is this URL public to users outside Whamcloud?


It wasn't  (oops), but I just  moved it so it it is now accessible to everyone here:

http://wiki.whamcloud.com/display/PUB/Auster


cheers,
robert

>  
> Thanks & Best Regards,
> Kelly Zhang(EMC)
>  

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120322/6cdf2db1/attachment.htm>
