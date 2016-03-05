From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 5 Mar 2016 12:16:11 +0000
Subject: [lustre-devel] Bug found: Missing lnetctl command on
	any	recentdaily built package
In-Reply-To: <tencent_457D7F416B6B8DD22BD6CC15@qq.com>
References: <tencent_4A8CFD8250BEDB3A3649365E@qq.com>
	<56D9E0EB.1070508@llnl.gov>
	<51102781-6DE8-418E-B236-F1ADAA287986@intel.com>
	<tencent_457D7F416B6B8DD22BD6CC15@qq.com>
Message-ID: <81210C5B-0329-418A-9956-D9546EB09D32@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 5, 2016, at 1:08 AM, 10000 wrote:

> On Mar 5, 2016, at 11:14 AM, Drokin, Oleg wrote:
> 
>> llmount.sh does not appear to need lnetctl (I use the llmount.sh,
>> and I do not have lnetctl built). 
> 
> I would say it may be needed at some situation. I can repeat this situation at VirtualBox with the following steps:
...
> It seems successfully running "llmount.sh". Although these steps are producing at a virtual machine, I think the key point to truggle the bug is that you have two network card, and the hostname is set to the second rather than the first (at /etc/hosts or some other name resolving settings).

You are right that in the situation you describe llmount.sh does not work.
But since it does not call lnetctl, even if lnetctl was available, llmount.sh still would not work in your scenario. Also since llmount.sh loads and reloads the modules, you really
need those lnet module parameters.

> I will post it at jira also.

Thanks! the lnetctl building issue really needs to be fixed.

Bye,
    Oleg
