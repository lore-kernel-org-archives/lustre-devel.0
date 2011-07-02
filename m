From: Liang Zhen <liang@whamcloud.com>
Date: Sat, 2 Jul 2011 18:48:35 +0800
Subject: [Lustre-devel] NRS HLD
In-Reply-To: <1309448989.27038.5.camel@localhost.localdomain>
References: <24C12A32-1D42-4327-8F8F-B9D30471B8C8@gmail.com>
	<1309448989.27038.5.camel@localhost.localdomain>
Message-ID: <88C87A8C-8DB5-4602-863B-9B77FF93C0D1@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikitas,

It's a very interesting document, thanks for sharing these great ideas.
May I ask whether there are any tests/numbers based on OBRR description
in HLD? We always want to see numbers from these algorithms, unfortunately
there is no reliable testing result from the patch on BZ 13634.

We are actually considering about NRS as well, although we don't have a
formal design document like this HLD, but we'd like to share a few
preliminary ideas for discussion:

- Target Based Round Robin (TBRR) probably is something worth to have

  Briefly, it's just load balancing over OSTs to improve overall server
  performance.

- Fairness for clients and resource control for jobs

  I think they are similar to CBRR and UBRR described in your document
  though I didn't see too much detail about them in the HLD.
  Personally, I think they are important and we probably will do some tests
  for CBRR survey very soon.

  . Client-Based Round Robin (CBRR) can guarantee the server responses
    to all clients fairly, and get whole-cluster load balancing, improve
    concurrency of clients and jobs, and get better overall performance.

  . resource control for jobs, some users complained that a busy job will
    hog all resources on servers, and make the cluster not usable for other
    control command or sysadmin. So it might be helpful to support job
    resource control inside NRS.

- Layering NRS polices

  Of course, OBRR is very important policy for NRS, but it might be
  helpful to have multiple polices working at the same time, i.e:

  . bind OSTs on CPU partitions on NUMA system(please see more detail at
    http://jira.whamcloud.com/browse/LU-56)

  . Service threads on each CPU partition can do TBRR for bound OSTs. If
    there is no CPU partition (like current Lustre) or OSTs are not bound
    on CPU partitions, service threads just do round robin over all OSTs.

  . OBRR inside each OST

  . of course, these layers should be tunable.

- Overhead of layerd polices
  . there definitely will be some overhead for inserting/removing
    request from these queues (or whatever), so we want some very scalable
    algorithms to implement these polices.

Again, these are just some preliminary ideas, so we would appreciate any
comment and suggestion.

Thanks
Liang


On Jun 30, 2011, at 11:49 PM, Nikitas Angelinas wrote:

> Hi,
> 
> There is a slightly more up-to-date version of the HLD, which I am
> attaching.
> 
> 
> Thanks,
> Nikitas
> 
> On Wed, 2011-06-29 at 12:55 -0700, Nathan Rutman wrote:
>> Sharing with the community.  All comments welcome.
>> This HLD (high-level design) for a Network Request Scheduler is more
>> about infrastructure than algorithm.
>> 
>> 
>> 
>> 
>> We're actually in the DLD (detailed-level design) stage at the moment
>> (sorry it didn't occur to me to 
>> post this earlier).  I'll post the DLD after some minor revision.
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
> 
> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
> 
> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
> 
> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
> 
> 
> <HLD_of_Lustre_NRS.pdf>_______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
