From: =?utf-8?B?QnJpbmttYW5uLCBQcm9mLiBEci4gQW5kcsOp?= <brinkman@uni-mainz.de>
Date: Mon, 17 Apr 2017 12:32:58 +0000
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for rate-limiting
 Quality of Service (RLQOS)
In-Reply-To: <949ca9f8-c4a5-1413-abbb-4777189ba425@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
	<99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
	<3FFFCE73-97FE-4A10-8AC6-47D835CC6B3C@intel.com>
	<3BE4A898-D944-41F9-84C8-FE8DA80D0D65@datadirectnet.com>
	<949ca9f8-c4a5-1413-abbb-4777189ba425@ascar.io>
Message-ID: <E08AFD6D-2057-4CDC-8F2A-85AC18AA8203@uni-mainz.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear Yan Li,

I fully agree that your approach to learn a small rule-set is very interesting to optimize overall 
Lustre bandwidth. What I have not been able to fully understand from your paper is the cost of 
adaptation. What is happening in a cluster running many jobs at the same time applying very different 
access patterns (in very different combinations to different OSSes)? 

We have just started to collect these patterns. Might be interesting to apply different (machine learning)
algorithms on top of these patters going into different directions:

- Optimize overall bandwidth (like ASCAR is doing)
- Optimize bandwidth while supporting QoS rules for certain applications

Will you be at LUG? At least Tim from our team will participate and it might be a good opportunity to discuss
a joint approach.

Best Regards, 

Andr?

Am 14.04.17, 04:55 schrieb "Yan Li" <yanli@ascar.io>:

    On 03/24/2017 08:36 PM, Li Xi wrote:
    > > As you already know, we (DDN and also Prof. Andr? and Lingfang from Mainz University)
    > are working together on QoS, not only server side TBF policy of NRS, but also client
    > side QoS (https://jira.hpdd.intel.com/browse/LU-7982). And also, global QoS of Lustre
    > is under development. After a glance on the paper, I think your work looks different from
    > our approach. That is good, because these mechanisms could work together to improve
    > the service quality of Lustre in different ways for different requirements.
    > 
    > I have a few questions about LRQOS. I haven?t read all the details in the paper, so please
    > correct me if I am wrong.
    > 
    > 1) In my understanding, ASCAR/RLQOS is aimed at preventing congestion in the Lustre
    > client. Am I correct? Is ASCAR/RLQOS able to provide any bandwidth/IOPS guarantees
    > to each applications, or to each user, or job? There is an common use case of client side
    > QoS. For example, multiple users are sharing the same Lustre client. But one of the users
    > starts a very aggressive application which uses all the available bandwidth/IOPS and thus
    > cause very bad performance/latency to other users. So, what we (DDN) are currently working
    > on is to trying to isolate/balance performance between users/jobs. I am wondering whether
    > ASCAR/RLQOS is able to be combined with our patches (https://review.whamcloud.com/#/c/19896/,
    > https://review.whamcloud.com/#/c/19700/) to provide an even better solution.
    
    ASCAR/RLQOS can't do bandwidth allocation for jobs accessing the same
    OSC yet. It is theoretically possible to do that for jobs accessing
    different OSCs, by using different rulesets for different OSC, but we
    don't know what is the best way to design these rulesets for bandwidth
    allocation yet.
    
    I agree it would be beneficial if our development effort can be
    combined. The core idea of ASCAR/RLQOS is to use a predefined ruleset to
    manage existing parameters, and this idea can be applied to any
    parameters in addition to those used in QoS.
    
    > 2) It is mentioned in the paper that ASCAR/RLQOS is controlling max flight RPC of OSC to
    > prevent congestion. However, for cached I/O, we found that page cache limitation on client is
    > also affecting the throughputs of applications. Especially, when multiple different applications
    > are sharing limited page caches. One of big concern is, when max flight RPC is limited,
    > the page cache will be exhausted (for example, when multiple applications keep on writing
    > data), and this is a new type of congestion. I am not sure, do you think this kind of congestion
    > will cause any performance decline/problem to the application?
    
    Yes. If that's the concern we should also tune the page cache limitation
    in addition to mrif. But the effectiveness of this needs to be carefully
    evaluated.
    
    > 3) Have you considered implementing ASCAR/RLQOS on Lustre server side? As already
    > mentioned in the paper, sometimes, clients of Lustre could connect to the servers and send
    > requests without any self-restraint which is unfair to other clients which follows the control
    > of ASCAR/RLQOS. And unfortunately, it is hard to get all the clients under control since
    > Lustre clients could change a lot from time to time. However, if a similar mechanism is
    > implemented on server side, things becomes much easier. And that is part of the reason
    > why TBF was implemented on server side rather than client side. Maybe something
    > similar to ASCAR/RLQOS could be implemented on MDTs/OSTs too. What do you think?
    
    This is definitely an interesting idea. As I said earlier, the core idea
    of ASCAR/RLQOS is actually tuning parameters dynamically, and we can
    apply this rule-based control to any parameters on both the server
    and client side.
    
    > 4) In your paper, I/O patterns detection or work load classifier are mentioned. So do you know
    > is there any any good way to detect/describe the I/O pattern of a application? Understanding
    > the I/O patterns of applications are really important and helpful for QoS. But I guess it is
    > really difficult, comparing to the pattern detection on other systems, like network. However,
    > do you have any idea or direction that looks like the right way? Maybe something like
    > machine learning?
    
    Yes. We are experimenting deep reinforcement learning-based methods and
    have seen some good results. The best part of using deep learning is
    that we don't have to worry about feature selection. As to whether deep
    learning works in real world, it has to be evaluated thoroughly.
    
    
    Yan
    
