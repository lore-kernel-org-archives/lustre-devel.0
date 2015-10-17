From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 17 Oct 2015 11:59:41 +0200
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: ldlm_extent.c:
 replace IS_PO2 by is_power_of_2
In-Reply-To: <20151017054109.GC25392@kroah.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<ea0e738a41b54bc91dadc33d6d35a678174a9233.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<20151017054109.GC25392@kroah.com>
Message-ID: <20151017095941.GB29503@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Oct 16, 2015 at 10:41:09PM -0700, Greg KH wrote:
> On Sat, Oct 17, 2015 at 12:05:44AM +0200, Aya Mahfouz wrote:
> > Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
> > macros. In this case, it is LASSERT. Note that the replacement changes
> > the types involved, because the parameter of IS_PO2 is of type long
> > long and the return type is int, while the parameter of is_power_of_2
> > is of type long and the return type is bool. This, however, has no
> > impact, because the actual argument is always of type int, and the
> > return value is always used as a boolean.
> 
> All of this info about the types mean nothing for this patch :(
> 
Hmm, my problem is that I realized the difference of return types
between the macro IS_PO2 and is_power_of_2. I tested the bool
datatype with a user space program to see what I will get and I get
0s and 1s. I can do it with a simple kernel driver to see what
happens there too if you would like.

Kindly let me know what kind of information you would like to see in the
commit message.

-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
