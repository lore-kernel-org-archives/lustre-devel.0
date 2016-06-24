From: Quentin BOUGET <quentin.bouget.ocre@cea.fr>
Date: Fri, 24 Jun 2016 16:50:49 +0200
Subject: [lustre-devel] HSM issues
In-Reply-To: <9F43A013-9D35-4F93-A153-61C098A426DC@fnal.gov>
References: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
	<9F43A013-9D35-4F93-A153-61C098A426DC@fnal.gov>
Message-ID: <576D48C9.3020503@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I am working on issue 4: Coordinator should sort incoming requests so 
that "restores" and "removes" are placed before "archives". Restores are 
the highest priority from user point of view, and removes are next from 
a space available point of

Here is the related ticket LU-8324: 
https://jira.hpdd.intel.com/browse/LU-8324

On Jun 23, 2016, at 7:10 PM, Nathan Rutman <nathan.rutman at seagate.com 
<mailto:nathan.rutman@seagate.com>> wrote:
> 4. Coordinator should sort incoming requests so that "restores" and 
> "removes" are placed before "archives". Restores are the highest 
> priority from user point of view, and removes are next from a space 
> available point of view.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160624/37cc0b83/attachment.htm>
