From: Yan Li <yanli@ascar.io>
Date: Mon, 17 Apr 2017 09:46:03 -0700
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for rate-limiting
 Quality of Service (RLQOS)
In-Reply-To: <E08AFD6D-2057-4CDC-8F2A-85AC18AA8203@uni-mainz.de>
References: <cover.1490122510.git.yanli@ascar.io>
	<99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
	<3FFFCE73-97FE-4A10-8AC6-47D835CC6B3C@intel.com>
	<3BE4A898-D944-41F9-84C8-FE8DA80D0D65@datadirectnet.com>
	<949ca9f8-c4a5-1413-abbb-4777189ba425@ascar.io>
	<E08AFD6D-2057-4CDC-8F2A-85AC18AA8203@uni-mainz.de>
Message-ID: <7ca175f0-85b1-e80d-d67b-b5d49eeacd17@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 04/17/2017 05:32 AM, Brinkmann, Prof. Dr. Andr? wrote:
> I fully agree that your approach to learn a small rule-set is very interesting to optimize overall 
> Lustre bandwidth. What I have not been able to fully understand from your paper is the cost of 
> adaptation. What is happening in a cluster running many jobs at the same time applying very different 
> access patterns (in very different combinations to different OSSes)?

When there are many jobs, their aggregated  I/O pattern can usually be
treated as a mixed random read/write workload. The more jobs you have,
the more uniformly random the I/O pattern is. My experience is that they
are not that hard to optimize. The hardest to optimize are when only one
or two I/O job is running and they have a very special I/O pattern.

> We have just started to collect these patterns. Might be interesting to apply different (machine learning)
> algorithms on top of these patters going into different directions:
> 
> - Optimize overall bandwidth (like ASCAR is doing)

This is similar to what I'm working on. I've been systematically testing
many machine learning algorithms on bandwidth optimization, and some of
them have pretty good results. My problem is that all my workloads so
far are synthetic.

> - Optimize bandwidth while supporting QoS rules for certain
> applications

This is on my radar. I'll look into your design and implementation to
see how we can do something interesting together.

> Will you be at LUG? At least Tim from our team will participate and it might be a good opportunity to discuss
> a joint approach.

I'm not sure yet. Now I've graduated I need to find my own funding
source for travel.

--
Yan
