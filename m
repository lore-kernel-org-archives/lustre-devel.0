From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 5 Mar 2016 03:14:38 +0000
Subject: [lustre-devel] Bug found: Missing lnetctl command on any recent
 daily built package
In-Reply-To: <56D9E0EB.1070508@llnl.gov>
References: <tencent_4A8CFD8250BEDB3A3649365E@qq.com>
	<56D9E0EB.1070508@llnl.gov>
Message-ID: <51102781-6DE8-418E-B236-F1ADAA287986@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 4, 2016, at 2:24 PM, Christopher J. Morrone wrote:

> I would not have thought that llmount.sh would require lnetctl.  If it
> does, then the LN_CONFIG_DLC function should be throwing an error not a
> warning.

llmount.sh does not appear to need lnetctl (I use the llmount.sh,
and I do not have lnetctl built). Also grep for lnetctl in lustre/tests
has no hits.

Bye,
    Oelg
