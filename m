From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 19 Jan 2017 11:28:55 -0500
Subject: [lustre-devel] Proposal for JobID caching
In-Reply-To: <D4A64247.C54A%jevans@cray.com>
References: <D4A5356C.C519%jevans@cray.com>
	<6E2CFE03-A158-4D82-82BA-AF0A175AA358@intel.com>
	<D4A5542D.C521%jevans@cray.com>
	<0DF0E294-1740-4669-9389-5CE0ECC15AEE@intel.com>
	<D4A64247.C54A%jevans@cray.com>
Message-ID: <9F262189-77A8-4CF7-8EE3-C8D79E6FBD4B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jan 19, 2017, at 10:19 AM, Ben Evans wrote:

> 
> 
> On 1/18/17, 5:56 PM, "Oleg Drokin" <oleg.drokin@intel.com> wrote:
> 
>> 
>> On Jan 18, 2017, at 5:35 PM, Ben Evans wrote:
>> 
>>>> But if you do really run different jobs in the global namespace, we
>>>> probably can
>>>> probably just make the lctl to spawn a shell with commands that all
>>>> would
>>>> be marked as a particular job? Or we can probably trace the parent of
>>>> lctl and
>>>> mark that so that all its children become somehow marked too.
>>> 
>>> One of the things that came up during this is how do you handle a random
>>> user who logs into a compute node and runs something like rsync?  The
>>> more
>> 
>> Current scheme does not handle it either, unles you use nodelocal and
>> then their
>> actions would attribute to the job currently running (not super ideal as
>> well),
>> I imagine there's a legitimate reason for users to log into the nodes
>> running
>> unrelated jobs?
> 
> The current scheme does handle it, if you use the procname_uid setting.

But then that's the only thing it handles, you don't get the actual jobid
this way.
What you are looking for is a fallback if a command is not actually part
of any known job, I though, otherwise use the jobid that was somehow
detected.
Or were you thinking of somehow mapping this on management nodes then
from node+pid into known jobs?

>>> conditions we place around getting jobstats to function properly, the
>>> harder these types of behaviors are to track down.  One thing I was
>>> thinking was that if jobstats is enabled, that the fallback if no JobID
>>> can be found is to simply use the taskname_uid method, so an admin would
>>> see rsync.1234 pop up on your monitoring dashboard.
>> 
>> If you have every node into its own container, then the global namespace
>> could
>> be set to "unscheduledcommand-$hostname" or some such and every container
>> would get its own jobid.
> 
> or simply default to the existing procname_uid setting.

Yes, that too.
