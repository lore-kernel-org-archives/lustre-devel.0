From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 16 Oct 2015 22:41:09 -0700
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: ldlm_extent.c:
 replace IS_PO2 by is_power_of_2
In-Reply-To: <ea0e738a41b54bc91dadc33d6d35a678174a9233.1445032901.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<ea0e738a41b54bc91dadc33d6d35a678174a9233.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <20151017054109.GC25392@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 17, 2015 at 12:05:44AM +0200, Aya Mahfouz wrote:
> Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
> macros. In this case, it is LASSERT. Note that the replacement changes
> the types involved, because the parameter of IS_PO2 is of type long
> long and the return type is int, while the parameter of is_power_of_2
> is of type long and the return type is bool. This, however, has no
> impact, because the actual argument is always of type int, and the
> return value is always used as a boolean.

All of this info about the types mean nothing for this patch :(
