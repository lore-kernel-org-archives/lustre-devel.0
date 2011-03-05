From: Liang Zhen <liang@whamcloud.com>
Date: Sat, 5 Mar 2011 09:54:09 +0800
Subject: [Lustre-devel] LNetPoll  undefined
In-Reply-To: <8CDA8EC0A0C0017-A90-CEFA@webmail-d097.sysops.aol.com>
References: <8CDA8EC0A0C0017-A90-CEFA@webmail-d097.sysops.aol.com>
Message-ID: <7E84F671-5637-4253-95BB-6999A17F3C4E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ravi,

Which version of Lustre/LNet are you trying with? Are you trying to build some new code over LNet? Could you show us some example code if you don't mind?
btw, If you are trying this in kernel space, I would suggest to use eq_callback (LNetEQAlloc(...eq_callback)) instead of LNetEQPoll/LNetEQWait, which is better for performance. Polling is not good for performance because all EQs share one single waitq in LNet. 

Regards
Liang

On Mar 5, 2011, at 9:30 AM, Ravi wrote:

> Hello 
> 
> I am using LNetWait (blocking call ) on a particular event .After i recevie this event i break from the loop which waits for this event and proceed  but when another event is added into the event queue the system crashes.I thought LNetPoll would be better as  i can just  poll for that particular event without disturbing the event queue but when i make i get undefined.Any thoughts .
> 
> Thanks 
> Ravi 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110305/9b69428b/attachment.htm>
