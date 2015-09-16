From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 16 Sep 2015 15:16:49 +0000
Subject: [lustre-devel] adding IOCTL for ping
In-Reply-To: <D21EE244.CB9%jevans@cray.com>
References: <D21DABBC.C8F%jevans@cray.com> <55F88186.50803@llnl.gov>
	<D21DFBEC.CA4%jevans@cray.com>
	<DB0C8A206669AC40B1C4E52A8584A6F614CF1BFA@CFWEX01.americas.cray.com>
	<D21EE244.CB9%jevans@cray.com>
Message-ID: <e27616ddad104a94a6d8f5d3208aee99@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>My understanding is that adding new proc interfaces is discouraged by
>upstream linux.

Please no new ioctls.

On 9/15/15, 5:12 PM, "Patrick Farrell" <paf@cray.com> wrote:

>Hmmm.  What about a proc interface instead?  This feels - to me - better
>suited to that, since it's a control that isn't part of the I/O path in
>any way.
>________________________________________
>From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of
>Ben Evans [bevans at cray.com]
>Sent: Tuesday, September 15, 2015 3:53 PM
>To: Christopher J. Morrone; lustre-devel at lists.lustre.org
>Subject: Re: [lustre-devel] adding IOCTL for ping
>
>You?re correct, targets and client Ids would probably be better.  I was
>simply thinking that it would be a relatively straightforward piece of
>code to write that could add some good flexibility into Lustre.  Combine
>it with an "X is dead, evict it? IOCTL and you could probably do quite a
>bit of good, especially if you?ve got a management system that is also
>monitoring aliveness, locations of targets, etc.
>
>-Ben Evans
>
>On 9/15/15, 4:37 PM, "lustre-devel on behalf of Christopher J. Morrone"
><lustre-devel-bounces at lists.lustre.org on behalf of morrone2@llnl.gov>
>wrote:
>
>>Maybe there is just not enough detail in the proposal, but I am not
>>seeing why associating this with NIDs is the right way to go.  I believe
>>that the RAS work that would use the gossip protocol dealt, at least in
>>part, with higher level concepts like targets.  The existing ptlrpc
>>pinger pings targets, not NIDs.  That is one of the problematic design
>>points of the existing system, that when N OSTs live on the same node
>>clients need to send N pings to the same node.
>>
>>Chris
>>
>>On 09/15/2015 08:04 AM, Ben Evans wrote:
>>> Would there be any interest in adding an IOCTL to update the ping
>>> time/status for a particular NID?
>>>
>>> This should allow for implementation of a pinger in userspace which
>>> updates the kernel on the status of various NIDs, and if I understand
>>> the ping code well enough, would greatly curtail any pings that is sent
>>> by the kernel.
>>>
>>> This might allow for things like Eric?s gossip implementation to simply
>>> bolt on top of Lustre without any internal kernel changes, or for
>>> integration of external monitoring systems to tell Lustre that
>>>failovers
>>> have occurred, etc.
>>>
>>> -Ben Evans
>>>
>>>
>>> _______________________________________________
>>> lustre-devel mailing list
>>> lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>>
>>
>>_______________________________________________
>>lustre-devel mailing list
>>lustre-devel at lists.lustre.org
>>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
