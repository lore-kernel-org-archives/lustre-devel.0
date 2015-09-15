From: Ben Evans <bevans@cray.com>
Date: Tue, 15 Sep 2015 20:53:01 +0000
Subject: [lustre-devel] adding IOCTL for ping
In-Reply-To: <55F88186.50803@llnl.gov>
References: <D21DABBC.C8F%jevans@cray.com> <55F88186.50803@llnl.gov>
Message-ID: <D21DFBEC.CA4%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You?re correct, targets and client Ids would probably be better.  I was
simply thinking that it would be a relatively straightforward piece of
code to write that could add some good flexibility into Lustre.  Combine
it with an "X is dead, evict it? IOCTL and you could probably do quite a
bit of good, especially if you?ve got a management system that is also
monitoring aliveness, locations of targets, etc.

-Ben Evans

On 9/15/15, 4:37 PM, "lustre-devel on behalf of Christopher J. Morrone"
<lustre-devel-bounces at lists.lustre.org on behalf of morrone2@llnl.gov>
wrote:

>Maybe there is just not enough detail in the proposal, but I am not
>seeing why associating this with NIDs is the right way to go.  I believe
>that the RAS work that would use the gossip protocol dealt, at least in
>part, with higher level concepts like targets.  The existing ptlrpc
>pinger pings targets, not NIDs.  That is one of the problematic design
>points of the existing system, that when N OSTs live on the same node
>clients need to send N pings to the same node.
>
>Chris
>
>On 09/15/2015 08:04 AM, Ben Evans wrote:
>> Would there be any interest in adding an IOCTL to update the ping
>> time/status for a particular NID?
>>
>> This should allow for implementation of a pinger in userspace which
>> updates the kernel on the status of various NIDs, and if I understand
>> the ping code well enough, would greatly curtail any pings that is sent
>> by the kernel.
>>
>> This might allow for things like Eric?s gossip implementation to simply
>> bolt on top of Lustre without any internal kernel changes, or for
>> integration of external monitoring systems to tell Lustre that failovers
>> have occurred, etc.
>>
>> -Ben Evans
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
